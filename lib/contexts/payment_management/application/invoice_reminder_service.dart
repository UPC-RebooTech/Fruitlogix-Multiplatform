import 'package:flutter/foundation.dart';

import '../domain/invoice.dart';
import '../domain/invoice_reminder_policy.dart';

/// Text of one reminder, already localized.
typedef ReminderText = ({String title, String body});
typedef ReminderTextBuilder = ReminderText Function(Invoice invoice);

/// Port to the device notification system.
abstract interface class InvoiceReminderNotifier {
  /// Initializes the plugin and asks for permission. False when the user
  /// denied notifications or the platform has none.
  Future<bool> ensureReady();

  /// Push notification shown now.
  Future<void> showNow(Invoice invoice, ReminderText text);

  /// Push notification delivered at [at] (local wall-clock time), even if
  /// the app is closed.
  Future<void> schedule(Invoice invoice, ReminderText text, DateTime at);

  /// Withdraws a shown or scheduled reminder of this invoice.
  Future<void> cancel(int invoiceId);
}

/// Port to the saved reminder settings.
abstract interface class ReminderSettingsStore {
  Future<({bool enabled, int leadDays})> read();
  Future<void> write({required bool enabled, required int leadDays});

  /// Keys of reminders already shown, so each invoice is notified once.
  Future<Set<String>> readSent();
  Future<void> writeSent(Set<String> keys);
}

/// US70 — Keeps device reminders in line with the client's invoices.
class InvoiceReminderService extends ChangeNotifier {
  InvoiceReminderService({
    required InvoiceReminderNotifier notifier,
    required ReminderSettingsStore store,
  })  : _notifier = notifier,
        _store = store;

  final InvoiceReminderNotifier _notifier;
  final ReminderSettingsStore _store;

  bool _loaded = false;
  bool _enabled = true;
  int _leadDays = InvoiceReminderPolicy.defaultLeadDays;
  bool? _permissionGranted;
  List<Invoice> _upcoming = const [];
  List<Invoice> _lastInvoices = const [];

  /// Set by the UI with the current language before each sync.
  ReminderTextBuilder? textBuilder;

  bool get enabled => _enabled;
  int get leadDays => _leadDays;

  /// Null until the permission was requested.
  bool? get permissionGranted => _permissionGranted;

  /// Invoices currently inside the anticipation window (in-app banner).
  List<Invoice> get upcoming => _upcoming;

  Future<void> _ensureLoaded() async {
    if (_loaded) return;
    try {
      final saved = await _store.read();
      _enabled = saved.enabled;
      _leadDays = InvoiceReminderPolicy.allowedLeadDays.contains(saved.leadDays)
          ? saved.leadDays
          : InvoiceReminderPolicy.defaultLeadDays;
    } catch (_) {
      // Defaults.
    }
    _loaded = true;
  }

  Future<void> loadSettings() async {
    await _ensureLoaded();
    _notify();
  }

  Future<void> updateSettings({bool? enabled, int? leadDays}) async {
    await _ensureLoaded();
    _enabled = enabled ?? _enabled;
    if (leadDays != null &&
        InvoiceReminderPolicy.allowedLeadDays.contains(leadDays)) {
      _leadDays = leadDays;
    }
    _notify();
    try {
      await _store.write(enabled: _enabled, leadDays: _leadDays);
    } catch (_) {
      // Keep the in-memory choice.
    }
    // A new window may add or remove reminders.
    await sync(_lastInvoices, today: DateTime.now());
  }

  /// Scenario 1: reminds invoices inside the window and schedules the rest.
  /// Scenario 2: cancels reminders of invoices that were already paid.
  Future<void> sync(List<Invoice> invoices, {required DateTime today}) async {
    await _ensureLoaded();
    _lastInvoices = invoices;
    final plan = InvoiceReminderPolicy(leadDays: _leadDays)
        .evaluate(invoices, today: today);
    _upcoming = _enabled ? plan.toNotify : const [];
    _notify();

    final builder = textBuilder;
    final sent = await _readSent();

    // Cancelling never needs permission.
    for (final id in plan.toCancel) {
      await _notifier.cancel(id);
      sent.removeWhere((key) => key.startsWith('$id@'));
    }

    if (!_enabled) {
      // Reminders turned off: withdraw everything still pending.
      for (final invoice in [
        ...plan.toNotify,
        ...plan.toSchedule.map((s) => s.invoice),
      ]) {
        await _notifier.cancel(invoice.id);
      }
      sent.clear();
      await _writeSent(sent);
      return;
    }
    if (builder == null) {
      await _writeSent(sent);
      return;
    }

    final granted = _permissionGranted ??= await _notifier.ensureReady();
    if (!granted) {
      _notify();
      await _writeSent(sent);
      return;
    }

    for (final invoice in plan.toNotify) {
      final key = _key(invoice);
      if (sent.contains(key)) continue;
      // Drops the alarm scheduled earlier for this invoice, if any.
      await _notifier.cancel(invoice.id);
      await _notifier.showNow(invoice, builder(invoice));
      sent.add(key);
    }
    for (final reminder in plan.toSchedule) {
      await _notifier.schedule(reminder.invoice, builder(reminder.invoice), reminder.at);
    }
    await _writeSent(sent);
  }

  bool _disposed = false;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  /// The due date is part of the key: a rescheduled invoice is reminded again.
  static String _key(Invoice invoice) =>
      '${invoice.id}@${invoice.dueDate.toIso8601String().substring(0, 10)}';

  Future<Set<String>> _readSent() async {
    try {
      return {...await _store.readSent()};
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> _writeSent(Set<String> keys) async {
    try {
      await _store.writeSent(keys);
    } catch (_) {
      // Worst case a reminder is shown twice.
    }
  }
}
