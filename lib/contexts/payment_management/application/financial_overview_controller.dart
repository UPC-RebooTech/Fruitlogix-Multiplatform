import 'package:flutter/foundation.dart';

import '../domain/financial_balance.dart';
import '../domain/invoice.dart';
import '../domain/invoice_repository.dart';
import 'invoice_reminder_service.dart';

enum OverviewStatus { idle, loading, ready, failure }

/// US36 — Loads the client's invoices once and shares them with the
/// dashboard and the Payments section.
///
/// Loading never blocks navigation: screens render immediately with a
/// loading indicator that is replaced by the formatted amounts.
class FinancialOverviewController extends ChangeNotifier {
  FinancialOverviewController({
    required InvoiceRepository repository,
    this.reminders,
    DateTime Function()? clock,
  })  : _repository = repository,
        _clock = clock ?? DateTime.now;

  final InvoiceRepository _repository;
  final DateTime Function() _clock;

  /// US70: evaluated after every successful load.
  final InvoiceReminderService? reminders;

  OverviewStatus _status = OverviewStatus.idle;
  List<Invoice> _invoices = const [];
  FinancialBalance _balance = FinancialBalance.empty;
  Object? _error;
  Future<void>? _inFlight;
  bool _disposed = false;

  OverviewStatus get status => _status;
  Object? get error => _error;
  FinancialBalance get balance => _balance;

  /// Outstanding first (closest due date first), then the rest, newest first.
  List<Invoice> get invoices => _invoices;

  bool get hasData => _status == OverviewStatus.ready ||
      (_status == OverviewStatus.loading && _invoices.isNotEmpty);

  /// Concurrent calls share the same request.
  Future<void> load() => _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    _status = OverviewStatus.loading;
    _error = null;
    _notify();
    try {
      final today = _clock();
      final fetched = await _repository.fetchMyInvoices();
      final effective = [for (final i in fetched) i.withEffectiveStatus(today)]
        ..sort(_byRelevance);
      _invoices = List.unmodifiable(effective);
      _balance = FinancialBalance.fromInvoices(effective, today: today);
      _status = OverviewStatus.ready;
      _notify();
      // Reminders must never break the dashboard.
      try {
        await reminders?.sync(effective, today: today);
      } catch (error, stack) {
        debugPrint('Invoice reminders sync failed: $error\n$stack');
      }
    } catch (error) {
      _error = error;
      _status = OverviewStatus.failure;
      _notify();
    }
  }

  static int _byRelevance(Invoice a, Invoice b) {
    if (a.isOutstanding != b.isOutstanding) return a.isOutstanding ? -1 : 1;
    return a.isOutstanding
        ? a.dueDate.compareTo(b.dueDate)
        : b.dueDate.compareTo(a.dueDate);
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
