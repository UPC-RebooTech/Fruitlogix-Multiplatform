import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../domain/geofence.dart';

/// Localized title and body of an arrival notification.
typedef ArrivalText = ({String title, String body});

/// US65 — "A truck entered your warehouse zone" on the phone.
abstract interface class ArrivalNotifier {
  /// Asks for notification permission once; false when unavailable.
  Future<bool> ensureReady();
  Future<void> show(ArrivalRecord arrival, ArrivalText text);
}

/// Local notifications (Android / iOS), on their own "Arrivals" channel.
/// Same plugin set-up as the invoice reminders (Payment Management).
class LocalArrivalNotifier implements ArrivalNotifier {
  LocalArrivalNotifier({FlutterLocalNotificationsPlugin? plugin})
      : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;
  Future<bool>? _ready;

  static bool get isSupported =>
      !kIsWeb && (Platform.isAndroid || Platform.isIOS);

  /// Kept apart from invoice ids (which are small integers).
  static const int _idOffset = 700000000;

  static const NotificationDetails _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'warehouse_arrivals',
      'Warehouse arrivals',
      channelDescription: 'Trucks entering the zone around your warehouse',
      importance: Importance.high,
      priority: Priority.high,
      category: AndroidNotificationCategory.status,
    ),
    iOS: DarwinNotificationDetails(),
  );

  @override
  Future<bool> ensureReady() => _ready ??= _setUp();

  Future<bool> _setUp() async {
    if (!isSupported) return false;
    try {
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
      debugPrint('Arrival notifications unavailable: $error');
      return false;
    }
  }

  @override
  Future<void> show(ArrivalRecord arrival, ArrivalText text) async {
    if (!await ensureReady()) return;
    await _plugin.show(
      id: _idOffset + arrival.deliveryId.hashCode.abs() % 100000000,
      title: text.title,
      body: text.body,
      notificationDetails: _details,
      payload: 'arrival:${arrival.deliveryId}',
    );
  }
}

/// Desktop, web and tests. Records what would be shown.
class NoopArrivalNotifier implements ArrivalNotifier {
  final List<ArrivalText> shown = [];

  @override
  Future<bool> ensureReady() async => false;

  @override
  Future<void> show(ArrivalRecord arrival, ArrivalText text) async => shown.add(text);
}
