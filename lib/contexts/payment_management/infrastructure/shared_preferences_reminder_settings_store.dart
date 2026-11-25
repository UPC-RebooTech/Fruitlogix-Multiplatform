import 'package:shared_preferences/shared_preferences.dart';

import '../application/invoice_reminder_service.dart';
import '../domain/invoice_reminder_policy.dart';

/// Reminder settings saved on the device, per signed-in user.
class SharedPreferencesReminderSettingsStore implements ReminderSettingsStore {
  SharedPreferencesReminderSettingsStore({
    required int userId,
    SharedPreferencesAsync? preferences,
  })  : _prefix = 'invoice_reminders_${userId}_',
        _preferences = preferences ?? SharedPreferencesAsync();

  final String _prefix;
  final SharedPreferencesAsync _preferences;

  @override
  Future<({bool enabled, int leadDays})> read() async => (
        enabled: await _preferences.getBool('${_prefix}enabled') ?? true,
        leadDays: await _preferences.getInt('${_prefix}lead_days') ??
            InvoiceReminderPolicy.defaultLeadDays,
      );

  @override
  Future<void> write({required bool enabled, required int leadDays}) async {
    await _preferences.setBool('${_prefix}enabled', enabled);
    await _preferences.setInt('${_prefix}lead_days', leadDays);
  }

  @override
  Future<Set<String>> readSent() async =>
      (await _preferences.getStringList('${_prefix}sent'))?.toSet() ?? <String>{};

  @override
  Future<void> writeSent(Set<String> keys) =>
      _preferences.setStringList('${_prefix}sent', keys.toList());
}

/// In-memory settings (no session / tests).
class InMemoryReminderSettingsStore implements ReminderSettingsStore {
  bool _enabled = true;
  int _leadDays = InvoiceReminderPolicy.defaultLeadDays;
  Set<String> _sent = {};

  @override
  Future<({bool enabled, int leadDays})> read() async =>
      (enabled: _enabled, leadDays: _leadDays);

  @override
  Future<void> write({required bool enabled, required int leadDays}) async {
    _enabled = enabled;
    _leadDays = leadDays;
  }

  @override
  Future<Set<String>> readSent() async => {..._sent};

  @override
  Future<void> writeSent(Set<String> keys) async => _sent = {...keys};
}
