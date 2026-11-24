import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../application/invoice_reminder_service.dart';
import '../domain/invoice.dart';

/// US70 — Push reminders on the device (Android / iOS) with
/// flutter_local_notifications. The notification id is the invoice id, so
/// cancelling an invoice withdraws both a shown and a scheduled reminder.
class LocalInvoiceReminderNotifier implements InvoiceReminderNotifier {
  LocalInvoiceReminderNotifier({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _initialized;
  Future<bool>? _permission;

  /// FruitLogix bills in soles: reminders follow Peru's time zone.
  static const String timeZone = 'America/Lima';

  static const String _channelId = 'invoice_reminders';
  static const String _channelName = 'Invoice reminders';

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Plugin set-up without asking for permission (enough to cancel).
  Future<bool> _initialize() => _initialized ??= _setUp();

  Future<bool> _setUp() async {
    if (!isSupported) return false;
    try {
      tz_data.initializeTimeZones();
      tz.setLocalLocation(tz.getLocation(timeZone));
      await _plugin.initialize(
        settings: const InitializationSettings(
          android: AndroidInitializationSettings('@mipmap/ic_launcher'),
          iOS: DarwinInitializationSettings(
            requestAlertPermission: false,
            requestBadgePermission: false,
            requestSoundPermission: false,
          ),
        ),
      );
      return true;
    } catch (error) {
      debugPrint('Notifications unavailable: $error');
      return false;
    }
  }

  @override
  Future<bool> ensureReady() => _permission ??= _requestPermission();

  Future<bool> _requestPermission() async {
    if (!await _initialize()) return false;
    try {
      if (Platform.isAndroid) {
        final android = _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
        return await android?.requestNotificationsPermission() ?? true;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      return await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
          false;
    } catch (error) {
      debugPrint('Notification permission request failed: $error');
      return false;
    }
  }

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Invoices close to their due date',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.reminder,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<void> showNow(Invoice invoice, ReminderText text) => _plugin.show(
        id: invoice.id,
        title: text.title,
        body: text.body,
        notificationDetails: _details,
        payload: 'invoice:${invoice.id}',
      );

  @override
  Future<void> schedule(Invoice invoice, ReminderText text, DateTime at) =>
      _plugin.zonedSchedule(
        id: invoice.id,
        title: text.title,
        body: text.body,
        scheduledDate: tz.TZDateTime(
          tz.local, at.year, at.month, at.day, at.hour, at.minute),
        notificationDetails: _details,
        // Inexact: no special "exact alarm" permission needed for a reminder.
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        payload: 'invoice:${invoice.id}',
      );

  /// Scenario 2: works even before (or without) notification permission,
  /// so a reminder scheduled earlier is withdrawn once the invoice is paid.
  @override
  Future<void> cancel(int invoiceId) async {
    if (!await _initialize()) return;
    await _plugin.cancel(id: invoiceId);
  }
}

/// Platforms without notifications (desktop, web, tests).
class NoopInvoiceReminderNotifier implements InvoiceReminderNotifier {
  @override
  Future<bool> ensureReady() async => false;

  @override
  Future<void> showNow(Invoice invoice, ReminderText text) async {}

  @override
  Future<void> schedule(Invoice invoice, ReminderText text, DateTime at) async {}

  @override
  Future<void> cancel(int invoiceId) async {}
}
