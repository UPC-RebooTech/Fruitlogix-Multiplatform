import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/application/arrivals_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/geofence.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/shipment.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/arrival_notifier.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/arrivals_store.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/delivery_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/warehouse_locator.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/logistics_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

const warehouse = GeoPoint(-12.0600, -77.0300);
const zone3 = WarehouseZone(center: warehouse, radiusKm: 3);

/// About 1.4 km from [warehouse].
const near = GeoPoint(-12.0712, -77.0251);

/// Piura, ~860 km away.
const far = GeoPoint(-5.1945, -80.6328);

DeliveryShipment truck(
  String id, {
  GeoPoint? at = near,
  ShipmentStatus status = ShipmentStatus.inTransit,
  bool received = false,
}) =>
    DeliveryShipment(
      id: id,
      trackingNumber: 'TRK-$id',
      orderId: 'ORD-$id',
      status: status,
      isReceived: received,
      driverName: 'Luis Ramírez',
      vehiclePlate: 'ABC-123',
      telemetry: at == null
          ? null
          : TelemetryLog(temperatureC: 4, humidityPercent: 80, position: at),
    );

class FailingLocator implements WarehouseLocator {
  const FailingLocator(this.reason);
  final LocationFailure reason;

  @override
  Future<GeoPoint> currentPosition() async => throw LocationException(reason);
}

ArrivalsController controllerWith({
  WarehouseZone? zone,
  ArrivalNotifier? notifier,
  WarehouseLocator locator = const FixedWarehouseLocator(warehouse),
}) =>
    ArrivalsController(
      store: InMemoryArrivalsStore(zone: zone),
      notifier: notifier ?? NoopArrivalNotifier(),
      locator: locator,
      clock: () => DateTime(2026, 11, 24, 14, 20),
    )..textBuilder = (a) => (title: 'Arriving ${a.orderCode}', body: '${a.distanceKm}');

void main() {
  group('Geofence', () {
    test('haversine distance and zone membership', () {
      expect(warehouse.distanceKmTo(near), closeTo(1.36, 0.05));
      expect(zone3.contains(near), isTrue);
      expect(const WarehouseZone(center: warehouse, radiusKm: 1).contains(near), isFalse);
      expect(zone3.contains(far), isFalse);
      expect(const GeoPoint(0, 0).isValid, isFalse);
      expect(const GeoPoint(91, 0).isValid, isFalse);
    });

    test('US65: only trucks on their way and inside the zone, once each', () {
      final found = detectArrivals(
        zone: zone3,
        shipments: [
          truck('1'),
          truck('2', at: far),
          truck('3', at: null),
          truck('4', status: ShipmentStatus.scheduled),
          truck('5', status: ShipmentStatus.delivered),
          truck('6', received: true),
          truck('7'),
        ],
        alreadyRecorded: {'7'},
        now: DateTime(2026, 11, 24, 14, 20),
      );
      expect(found.map((a) => a.deliveryId), ['1']);
      expect(found.single.orderCode, 'ORD-1');
      expect(found.single.distanceKm, closeTo(1.36, 0.05));
      expect(found.single.driverName, 'Luis Ramírez');
    });

    test('zone and arrival survive JSON; broken values are ignored', () {
      expect(WarehouseZone.fromJson(zone3.toJson())!.radiusKm, 3);
      expect(WarehouseZone.fromJson(zone3.toJson())!.center, warehouse);
      expect(WarehouseZone.fromJson({'lat': 1, 'lng': 2, 'radiusKm': 0}), isNull);
      expect(WarehouseZone.fromJson('nope'), isNull);

      final arrival = detectArrivals(
        zone: zone3,
        shipments: [truck('1')],
        alreadyRecorded: const {},
        now: DateTime(2026, 11, 24, 14, 20),
      ).single;
      final back = ArrivalRecord.fromJson(arrival.toJson())!;
      expect(back.deliveryId, '1');
      expect(back.arrivedAt, DateTime(2026, 11, 24, 14, 20));
      expect(back.vehiclePlate, 'ABC-123');
      expect(ArrivalRecord.fromJson({'deliveryId': 1}), isNull);
    });

    test('the truck position comes from the latest tracking log', () {
      final reading = DeliveryJsonParser.latestReading([
        {'temperature': 4, 'humidity': 80, 'timestamp': '2026-11-24T18:00:00Z', 'latitude': 0, 'longitude': 0},
        {'temperature': 5, 'humidity': 82, 'timestamp': '2026-11-24T19:00:00Z', 'latitude': -12.07, 'longitude': '-77.02'},
      ])!;
      expect(reading.position, const GeoPoint(-12.07, -77.02));
      final noGps = DeliveryJsonParser.latestReading([
        {'temperature': 4, 'humidity': 80, 'latitude': 0, 'longitude': 0},
      ])!;
      expect(noGps.position, isNull);
    });
  });

  group('ArrivalsController', () {
    test('no zone: nothing is detected (scenario 2 without set-up)', () async {
      final notifier = NoopArrivalNotifier();
      final controller = controllerWith(notifier: notifier);
      expect(await controller.check([truck('1')]), isEmpty);
      expect(controller.arrivals, isEmpty);
      expect(notifier.shown, isEmpty);
    });

    test('a truck entering the zone is recorded and notified once', () async {
      final notifier = NoopArrivalNotifier();
      final controller = controllerWith(zone: zone3, notifier: notifier);
      // Two refreshes at once (timer + pull to refresh).
      await Future.wait([
        controller.check([truck('1')]),
        controller.check([truck('1')]),
      ]);
      await controller.check([truck('1'), truck('2', at: far)]);
      expect(controller.arrivals.map((a) => a.deliveryId), ['1']);
      expect(notifier.shown.map((t) => t.title), ['Arriving ORD-1']);
    });

    test('set the zone at the current position, change radius, remove it', () async {
      final store = InMemoryArrivalsStore();
      final controller = ArrivalsController(
        store: store,
        notifier: NoopArrivalNotifier(),
        locator: const FixedWarehouseLocator(warehouse),
      );
      await controller.setZoneAtCurrentPosition(1);
      expect((await store.loadZone())!.center, warehouse);
      expect(await controller.check([truck('1')]), isEmpty); // 1.4 km > 1 km
      await controller.changeRadius(3);
      expect((await store.loadZone())!.radiusKm, 3);
      expect(await controller.check([truck('1')]), hasLength(1));

      await controller.clearZone();
      expect(controller.zone, isNull);
      expect(await store.loadZone(), isNull);
      // The arrivals already recorded are kept.
      expect(controller.arrivals, hasLength(1));
    });

    test('location problems are reported and the zone stays unset', () async {
      final controller = controllerWith(
        locator: const FailingLocator(LocationFailure.denied),
      );
      await expectLater(
        controller.setZoneAtCurrentPosition(3),
        throwsA(isA<LocationException>()),
      );
      expect(controller.zone, isNull);
      expect(controller.locating, isFalse);
    });
  });

  Future<void> openTracking(WidgetTester tester, LogisticsModule logistics) async {
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(
        localeController: LocaleController(),
        logisticsModule: logistics,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();
  }

  testWidgets('US65 scenario 1: a truck inside the zone shows in the arrivals list',
      (tester) async {
    final notifier = NoopArrivalNotifier();
    final logistics = LogisticsModule.demo(
      zone: zone3,
      notifier: notifier,
      latency: Duration.zero,
    );
    await openTracking(tester, logistics);

    expect(find.text('ARRIVALS AT YOUR WAREHOUSE'), findsOneWidget);
    expect(find.text('3 km around your warehouse · alerts on'), findsOneWidget);
    expect(find.text('Luis Ramírez · ABC-123'), findsOneWidget);
    expect(find.text('1.4 km away'), findsOneWidget);
    expect(notifier.shown.single.title, 'Truck arriving · ORD-1042');
    expect(
      notifier.shown.single.body,
      'Luis Ramírez entered your warehouse zone (1.4 km).',
    );
  });

  testWidgets('US65 scenario 2: set the zone; no truck inside means no arrivals',
      (tester) async {
    final logistics = LogisticsModule.demo(latency: Duration.zero);
    await openTracking(tester, logistics);

    expect(
      find.text('Not set · set it to get an alert when a truck arrives'),
      findsOneWidget,
    );
    await tester.tap(find.text('Warehouse zone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('1 km'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use my current location'));
    await tester.pumpAndSettle();

    expect(find.text('Warehouse zone saved'), findsOneWidget);
    expect(find.text('No arrivals yet'), findsOneWidget);
    expect(logistics.arrivals.arrivals, isEmpty);

    // A wider radius catches the truck 1.4 km away at once.
    await tester.tap(find.text('Warehouse zone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('3 km').last);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save radius'));
    await tester.pumpAndSettle();
    expect(find.text('No arrivals yet'), findsNothing);
    expect(find.text('Luis Ramírez · ABC-123'), findsOneWidget);
  });

  testWidgets('US65: denied location is explained in the sheet', (tester) async {
    final logistics = LogisticsModule.demo(
      latency: Duration.zero,
      locator: const FailingLocator(LocationFailure.deniedForever),
    );
    await openTracking(tester, logistics);

    await tester.tap(find.text('Warehouse zone'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Use my current location'));
    await tester.pumpAndSettle();
    expect(
      find.text('Location is blocked for FruitLogix. Allow it in your phone settings.'),
      findsOneWidget,
    );
    expect(logistics.arrivals.zone, isNull);
  });
}
