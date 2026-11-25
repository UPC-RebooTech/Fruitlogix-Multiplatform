import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/shipment.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/delivery_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/logistics_module.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/presentation/delay_alert_banner.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

void main() {
  test('cold-chain certificate from the tracking logs', () {
    final readings = DeliveryJsonParser.readings([
      {'temperature': 7.8, 'humidity': 88, 'timestamp': '2026-11-25T13:00:00Z'},
      {'temperature': 3.8, 'humidity': 86, 'timestamp': '2026-11-25T04:00:00Z'},
      {'temperature': 4.4, 'humidity': 87, 'timestamp': '2026-11-25T09:30:00Z'},
      {'humidity': 80},
    ]);
    expect(readings.map((r) => r.temperatureC), [3.8, 4.4, 7.8]);
    final certificate = ColdChainCertificate.fromReadings(readings)!;
    expect(certificate.readingsCount, 3);
    expect(certificate.minTempC, 3.8);
    expect(certificate.maxTempC, 7.8);
    expect(certificate.averageTempC, closeTo(5.33, 0.01));
    // 7.8 °C is above the 1–6 °C target range.
    expect(certificate.inRangeCount, 2);
    expect(certificate.isCompliant, isFalse);
    expect(certificate.monitored, const Duration(hours: 9));
    expect(ColdChainCertificate.fromReadings(const []), isNull);
  });

  test('the latest delay event carries the reason', () {
    final shipment = DeliveryShipment(
      id: '7',
      trackingNumber: 'TRK-0007',
      orderId: 'ORD-0041',
      status: ShipmentStatus.delayed,
      events: DeliveryJsonParser.events([
        {'type': 'Dispatched', 'occurredAt': '2026-11-25T07:30:00Z'},
        {'type': 'Delayed', 'note': 'Tráfico en Panamericana', 'occurredAt': '2026-11-25T10:00:00Z'},
        {'type': 'Delayed', 'note': 'Control SENASA', 'occurredAt': '2026-11-25T12:00:00Z'},
      ]),
    );
    expect(shipment.latestDelay!.note, 'Control SENASA');
  });

  testWidgets('delay banner shows the reported reason and the ETA', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: DelayAlertBanner(
          delay: TrackingEventItem(
            time: '',
            description: '',
            isCompleted: true,
            type: DeliveryEventType.delayed,
            note: 'Control SENASA',
            occurredAt: DateTime(2026, 11, 25, 14, 30),
          ),
          eta: '25 November 2026 · 4:30 PM',
        ),
      ),
    ));
    expect(find.text('Delay in transit'), findsOneWidget);
    expect(find.text('Control SENASA'), findsOneWidget);
    expect(find.text('Current ETA: 25 November 2026 · 4:30 PM'), findsOneWidget);
  });

  testWidgets('Tracking opens the cold-chain certificate of the trip', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(
        localeController: LocaleController(),
        logisticsModule: LogisticsModule.demo(latency: Duration.zero),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();

    await tester.tap(find.textContaining('View cold-chain certificate'));
    await tester.pumpAndSettle();
    expect(find.text('Cold-chain certificate'), findsOneWidget);
    expect(find.text('100% in range'), findsOneWidget);
    expect(find.text('5 of 5 readings inside the target range'), findsOneWidget);
    expect(find.text('5.3 °C'), findsOneWidget);
  });
}
