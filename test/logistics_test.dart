import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/application/shipments_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/shipment.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/delivery_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/demo_shipment_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/fruitlogix_logistics_api.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/http_shipment_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/phone_dialer.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/logistics_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const order7 = ShipmentOrderRef(orderId: 7, orderCode: 'ORD-0007', itemsSummary: 'Mango Kent');

Map<String, Object?> delivery(int id, int orderId, {String status = 'InTransit'}) => {
      'id': id,
      'orderId': orderId,
      'driverName': 'Luis Ramírez',
      'driverPhone': '+51 987 111 222',
      'vehiclePlate': 'ABC-123',
      'vehicleType': 'Reefer truck',
      'routeOrigin': 'Piura',
      'routeDestination': 'Lima',
      'routeDistanceKm': 980,
      'estimatedTimeOfArrival': '2026-11-24T20:45:00Z',
      'currentStatus': status,
    };

/// JSON answer encoded as UTF-8, like the platform API ("Ramírez").
http.Response json(Object? body) => http.Response.bytes(
      utf8.encode(jsonEncode(body)),
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );

class FakeDialer implements PhoneDialer {
  FakeDialer({this.result = true});
  final bool result;
  final List<String> dialed = [];

  @override
  Future<bool> dial(String phoneNumber) async {
    dialed.add(phoneNumber);
    return result;
  }
}

void main() {
  group('DeliveryJsonParser', () {
    test('statuses in different spellings', () {
      expect(DeliveryJsonParser.parseStatus('Scheduled'), ShipmentStatus.scheduled);
      expect(DeliveryJsonParser.parseStatus('DISPATCHED'), ShipmentStatus.dispatched);
      expect(DeliveryJsonParser.parseStatus('In_Transit'), ShipmentStatus.inTransit);
      expect(DeliveryJsonParser.parseStatus('Delayed'), ShipmentStatus.delayed);
      expect(DeliveryJsonParser.parseStatus('Entregado'), ShipmentStatus.delivered);
      expect(DeliveryJsonParser.parseStatus(null), ShipmentStatus.scheduled);
    });

    test('DeliveryResource with the order code of Orders', () {
      final shipment = DeliveryJsonParser.parse(delivery(12, 7), order: order7);
      expect(shipment.trackingNumber, 'TRK-0012');
      expect(shipment.orderId, 'ORD-0007');
      expect(shipment.itemsSummary, 'Mango Kent');
      expect(shipment.driverName, 'Luis Ramírez');
      expect(shipment.canCallDriver, isTrue);
      expect(shipment.estimatedArrival!.toUtc(), DateTime.utc(2026, 11, 24, 20, 45));
      expect(shipment.status, ShipmentStatus.inTransit);
    });

    test('latest tracking log wins', () {
      final reading = DeliveryJsonParser.latestReading([
        {'deliveryId': 12, 'timestamp': '2026-11-24T10:00:00Z', 'temperature': 5.1, 'humidity': 80},
        {'deliveryId': 12, 'timestamp': '2026-11-24T12:00:00Z', 'temperature': 4.2, 'humidity': 86},
        {'deliveryId': 12, 'timestamp': '2026-11-24T11:00:00Z', 'temperature': 6.0, 'humidity': 70},
      ]);
      expect(reading!.temperatureC, 4.2);
      expect(DeliveryJsonParser.latestReading(const []), isNull);
    });
  });

  group('HttpShipmentRepository', () {
    late List<http.Request> requests;

    HttpShipmentRepository repository(
      Future<http.Response> Function(http.Request) handler, {
      List<ShipmentOrderRef> orders = const [order7],
    }) {
      requests = [];
      return HttpShipmentRepository(
        clientOrders: () async => orders,
        api: FruitLogixLogisticsApi(
          token: () => 'jwt',
          baseUri: Uri.parse('https://api.test'),
          client: MockClient((request) {
            requests.add(request);
            return handler(request);
          }),
        ),
      );
    }

    test("keeps only the deliveries of the client's orders, with their reading", () async {
      final repo = repository((request) async => request.url.path == '/api/v1/deliveries'
          ? json([delivery(12, 7), delivery(13, 99)])
          : http.Response(
              jsonEncode([
                {'deliveryId': 12, 'timestamp': '2026-11-24T12:00:00Z', 'temperature': 4.2, 'humidity': 86},
              ]),
              200,
            ));
      final shipments = await repo.fetchMyShipments();
      expect(shipments.map((s) => s.trackingNumber), ['TRK-0012']);
      expect(shipments.single.telemetry!.temperatureC, 4.2);
      final logs = requests.last;
      expect(logs.url.path, '/api/v1/tracking-logs');
      expect(logs.url.queryParameters, {'deliveryId': '12'});
      expect(logs.headers['Authorization'], 'Bearer jwt');
      // Never asks for readings of other clients' deliveries.
      expect(requests.where((r) => r.url.path == '/api/v1/tracking-logs'), hasLength(1));
    });

    test('a delivery without readings (404) still shows', () async {
      final repo = repository((request) async => request.url.path == '/api/v1/deliveries'
          ? json([delivery(12, 7)])
          : http.Response('', 404));
      final shipments = await repo.fetchMyShipments();
      expect(shipments.single.telemetry, isNull);
    });

    test('a client without orders does not call the API', () async {
      final repo = repository((_) async => http.Response('[]', 200), orders: const []);
      expect(await repo.fetchMyShipments(), isEmpty);
      expect(requests, isEmpty);
    });
  });

  test('ShipmentsController: most relevant first, reception kept locally', () async {
    final controller = ShipmentsController(
      repository: DemoShipmentRepository(latency: Duration.zero),
    );
    await controller.load();
    expect(controller.shipments.map((s) => s.orderId), ['ORD-1042', 'ORD-1040']);
    controller.markAsReceived('demo-1', notes: 'ok');
    expect(controller.shipments.first.isReceived, isTrue);
    expect(controller.shipments.first.shipmentProgress, 1);
  });

  testWidgets('US38/US77: driver, vehicle and call button in Tracking', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1800 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final dialer = FakeDialer(result: false);
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(
        localeController: LocaleController(),
        logisticsModule: LogisticsModule.demo(dialer: dialer, latency: Duration.zero),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tracking'));
    await tester.pumpAndSettle();

    expect(find.text('Driver and vehicle'.toUpperCase()), findsOneWidget);
    expect(find.text('Luis Ramírez'), findsOneWidget);
    expect(find.text('ABC-123'), findsOneWidget);

    await tester.tap(find.text('Call driver'));
    await tester.pumpAndSettle();
    expect(dialer.dialed, ['+51 987 111 222']);
    // The phone app could not open: the client is told.
    expect(find.text("We couldn't open the phone app"), findsOneWidget);

    // The scheduled delivery has no driver yet and no call button.
    await tester.tap(find.text('ORD-1040'));
    await tester.pumpAndSettle();
    expect(find.text("A driver hasn't been assigned yet"), findsOneWidget);
    expect(find.text('Call driver'), findsNothing);
  });
}
