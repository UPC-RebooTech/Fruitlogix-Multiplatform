import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/iam/infrastructure/fruitlogix_auth_api.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/geofence.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/lot_timeline.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/platform_arrivals.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/infrastructure/traceability_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/cart_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/http_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/order_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/profiles_management/domain/commercial_client_profile.dart';
import 'package:fruitlogix_multiplatform/contexts/profiles_management/infrastructure/http_commercial_client_profile_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/fruitlogix_quality_api.dart';
import 'package:fruitlogix_multiplatform/shared/infrastructure/api_errors.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// A JWT that expires in 2099 (the app checks `exp` only).
String jwt() {
  String part(Object json) =>
      base64Url.encode(utf8.encode(jsonEncode(json))).replaceAll('=', '');
  return '${part({'alg': 'none'})}.${part({'exp': 4102444800})}.sig';
}

FruitLogixAuthApi auth(Map<String, Object?> signIn) => FruitLogixAuthApi(
  baseUri: Uri.parse('https://api.test'),
  client: MockClient((request) async {
    if (request.url.path.endsWith('sign-up')) {
      expect(jsonDecode(request.body)['role'], 'CommercialClient');
      return http.Response('{"message":"ok"}', 200);
    }
    return http.Response(jsonEncode(signIn), 200);
  }),
);

void main() {
  group('IAM with roles', () {
    test('a commercial client signs in and keeps the role', () async {
      final session = await auth({
        'id': 12,
        'username': 'cliente1',
        'token': jwt(),
        'role': 'CommercialClient',
      }).signIn(username: 'cliente1', password: 'x');
      expect(session.role, 'CommercialClient');
      expect(session.toJson()['role'], 'CommercialClient');
    });

    test('producers and distributors are sent to their app', () async {
      await expectLater(
        auth({
          'id': 9,
          'username': 'productor1',
          'token': jwt(),
          'role': 'Producer',
        }).signIn(username: 'productor1', password: 'x'),
        throwsA(isA<AuthApiException>()
            .having((e) => e.reason, 'reason', AuthFailure.wrongRole)),
      );
    });

    test('sign-up sends the CommercialClient role', () async {
      await auth(const {}).signUp(username: 'nuevo', password: 'clave1234');
    });
  });

  group('Errors', () {
    test('message, validation error, detail or plain string', () {
      expect(apiErrorMessage('{"message":"Order must be in transit"}'), 'Order must be in transit');
      expect(
        apiErrorMessage('{"title":"One or more","errors":{"role":["Rol no válido"]}}'),
        'Rol no válido',
      );
      expect(apiErrorMessage('{"title":"Unauthorized","detail":"Token expired"}'), 'Token expired');
      expect(apiErrorMessage('"Order with id 5 not found."'), 'Order with id 5 not found.');
      expect(apiErrorMessage('not json'), isNull);
    });

    test('a 401 signs out once; a 403 does not', () async {
      var expired = 0;
      final client = SessionGuardClient(
        onUnauthorized: () => expired++,
        inner: MockClient((request) async =>
            http.Response('', request.url.path == '/forbidden' ? 403 : 401)),
      );
      await client.get(Uri.parse('https://api.test/forbidden'));
      expect(expired, 0);
      await client.get(Uri.parse('https://api.test/a'));
      await client.get(Uri.parse('https://api.test/b'));
      expect(expired, 1);
    });
  });

  group('Orders', () {
    test('Rejected and DeliveredWithIncidence, reception and producer name', () {
      final order = OrderJsonParser.parse({
        'id': 41,
        'status': 'DeliveredWithIncidence',
        'deliveryDueDate': '2026-12-05',
        'producerName': 'Juan Pérez',
        'batchId': 3,
        'deliveredAt': '2026-11-26T10:15:00+00:00',
        'reception': {'rating': null, 'comment': 'Cajas golpeadas', 'hasIncidence': true, 'sealAndTemperatureOk': false},
      });
      expect(order.status, OrderStatus.deliveredWithIncidence);
      expect(order.status.isDelivered, isTrue);
      expect(order.producerName, 'Juan Pérez');
      expect(order.batchId, 3);
      expect(order.reception!.rating, isNull);
      expect(order.reception!.sealAndTemperatureOk, isFalse);

      final rejected = OrderJsonParser.parse({
        'id': 42,
        'status': 'Rejected',
        'deliveryDueDate': '2026-12-05',
        'cancellationReason': 'Sin stock de calibre 8',
      });
      expect(rejected.status, OrderStatus.rejected);
      expect(rejected.cancellationReason, 'Sin stock de calibre 8');
    });

    test('catalog: products of /products, minimum per order, one producer', () {
      final products = HttpCatalogRepository.parseList([
        {'id': 3, 'producerId': 2, 'producerName': 'Juan Pérez', 'name': 'Mango Kent', 'fruitType': 'Mango', 'unitPrice': 4.5, 'availableKg': 1200, 'minOrderKg': 50, 'isActive': true},
        {'id': 4, 'producerId': 5, 'name': 'Palta Hass', 'fruitType': 'Palta', 'unitPrice': 7, 'availableKg': 30, 'minOrderKg': 40, 'isActive': true},
        {'id': 5, 'producerId': 2, 'name': 'Old', 'unitPrice': 1, 'availableKg': 9, 'isActive': false},
      ]);
      expect(products.map((p) => p.id), [3, 4]);
      final cart = CartController(products);
      expect(cart.add(products.first), CartAddResult.added);
      expect(cart.quantityFor(3), 50);
      // Another producer cannot join the order.
      expect(cart.add(products.last), CartAddResult.otherProducer);
      cart.remove(products.first);
      expect(cart.quantityFor(3), 0);
      // Minimum 40 kg but only 30 kg left.
      expect(cart.add(products.last), CartAddResult.outOfStock);
    });
  });

  test('traceability: stages, lot result and not applicable', () {
    final timeline = TraceabilityJsonParser.parse({
      'orderId': 41,
      'batchId': 3,
      'stages': [
        {'stage': 'Harvest', 'status': 'Completed', 'occurredAt': '2026-11-20T00:00:00+00:00', 'responsible': 'Juan Pérez', 'details': {'batchStatus': 'Approved'}},
        {'stage': 'Inspection', 'status': 'Completed', 'occurredAt': null, 'responsible': null, 'details': {}},
        {'stage': 'Dispatch', 'status': 'Pending', 'details': {}},
        {'stage': 'Reception', 'status': 'NotApplicable', 'details': {}},
        {'stage': 'Invoice', 'status': 'NotApplicable', 'details': {}},
      ],
    }, orderCode: 'ORD-0041');
    expect(timeline.lotCode, 'LOT-0003');
    expect(timeline.events.map((e) => e.state), [
      TraceState.done,
      TraceState.done,
      TraceState.pending,
      TraceState.notApplicable,
      TraceState.notApplicable,
    ]);
    expect(timeline.events.first.responsible, 'Juan Pérez');
    expect(timeline.events[1].inspectionResult, InspectionResult.approved);
    expect(timeline.applicableCount, 3);
  });

  test('US65: warehouse of the profile and arrivals detected by the platform', () {
    final zone = PlatformArrivalsStore.zoneOf({'latitude': -12.06, 'longitude': -77.03, 'radiusKm': 0.5})!;
    expect(zone.radiusKm, 0.5);
    expect(PlatformArrivalsStore.zoneOf(null), isNull);
    final arrival = PlatformArrivalDetector.parse(
      {'deliveryId': 7, 'orderId': 41, 'arrivedAt': '2026-11-26T09:58:00+00:00', 'latitude': -12.0605, 'longitude': -77.0301, 'source': 'Geofence'},
      zone: zone,
      shipments: const {},
    )!;
    expect(arrival.deliveryId, '7');
    expect(arrival.orderCode, 'ORD-0041');
    expect(arrival.distanceKm, lessThan(0.1));
    final manual = PlatformArrivalDetector.parse(
      {'deliveryId': 8, 'orderId': 42, 'arrivedAt': '2026-11-26T09:58:00+00:00', 'source': 'Manual'},
      zone: zone,
      shipments: const {},
    )!;
    expect(manual.distanceKm, isNull);
    expect(const GeoPoint(-12.06, -77.03).isValid, isTrue);
  });

  group('Profile /profiles/me', () {
    test('404 opens an empty form prefilled from this phone; PUT sends every field', () async {
      final requests = <http.Request>[];
      final client = MockClient((request) async {
        requests.add(request);
        if (request.method == 'GET') return http.Response('', 404);
        final body = jsonDecode(request.body) as Map;
        return http.Response(jsonEncode({...body, 'id': 4, 'userId': 12}), 200);
      });
      const local = CommercialClientProfile(
        id: 'iam-user-12',
        fullName: 'Ana Ruiz',
        businessName: 'Frutas del Norte SAC',
        email: 'ana@empresa.pe',
        phone: '+51 999 888 777',
        taxId: '20123456789',
      );
      final repo = await HttpCommercialClientProfileRepository.open(
        userId: 12,
        username: 'ana',
        token: () => 'jwt',
        client: client,
        baseUri: Uri.parse('https://api.test'),
        fallback: local,
      );
      expect(repo.current.businessName, 'Frutas del Norte SAC');
      await repo.save(local);
      expect(requests.last.method, 'PUT');
      expect(requests.last.url.path, '/api/v1/profiles/me');
      expect(jsonDecode(requests.last.body), {
        'businessName': 'Frutas del Norte SAC',
        'ruc': '20123456789',
        'contactName': 'Ana Ruiz',
        'email': 'ana@empresa.pe',
        'phone': '+51 999 888 777',
        'address': '',
      });
    });

    test('a profile with empty contact data greets the client by username', () async {
      final repo = await HttpCommercialClientProfileRepository.open(
        userId: 12,
        username: 'cliente1',
        token: () => 'jwt',
        baseUri: Uri.parse('https://api.test'),
        // Created by PUT /profiles/me/warehouse: no contact data yet.
        client: MockClient((_) async => http.Response(
              jsonEncode({'id': 4, 'userId': 12, 'businessName': '', 'contactName': '', 'ruc': '', 'email': '', 'phone': ''}),
              200,
            )),
      );
      expect(repo.current.fullName, 'cliente1');
      expect(repo.current.firstName, 'cliente1');
    });

    test('a rejected value shows the platform message', () async {
      final repo = await HttpCommercialClientProfileRepository.open(
        userId: 12,
        username: 'ana',
        token: () => 'jwt',
        baseUri: Uri.parse('https://api.test'),
        client: MockClient((request) async => request.method == 'GET'
            ? http.Response('', 404)
            : http.Response('{"message":"El RUC debe tener 11 dígitos."}', 400)),
      );
      await expectLater(
        repo.save(const CommercialClientProfile(
          id: 'iam-user-12',
          fullName: 'Ana Ruiz',
          businessName: 'Frutas',
          email: 'ana@empresa.pe',
          phone: '999888777',
          taxId: '20123456789',
        )),
        throwsA(isA<ProfileApiException>()
            .having((e) => e.message, 'message', 'El RUC debe tener 11 dígitos.')),
      );
    });
  });

  test('evidence type from the first bytes (the platform checks it)', () {
    expect(FruitLogixQualityApi.imageContentType([0x89, 0x50, 0x4E, 0x47, 0]).subtype, 'png');
    expect(
      FruitLogixQualityApi.imageContentType([0x52, 0x49, 0x46, 0x46, 0, 0, 0, 0, 0x57, 0x45, 0x42, 0x50]).subtype,
      'webp',
    );
    expect(FruitLogixQualityApi.imageContentType([0xFF, 0xD8, 0xFF]).extension, 'jpg');
  });
}
