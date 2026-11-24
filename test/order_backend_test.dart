import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/orders_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/fruitlogix_orders_api.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/http_order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/order_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/order_management_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

final products = const DemoCatalogRepository().getProducts();
final mango = products.firstWhere((p) => p.id == 1); // S/ 4.50
final avocado = products.firstWhere((p) => p.id == 3); // S/ 7.50

NewOrder newOrder() => NewOrder(
      lines: [
        OrderLine(product: mango, quantity: 10),
        OrderLine(product: avocado, quantity: 3),
      ],
      deliveryAddress: '  Av. Arequipa 123, Lince ',
      deliveryDate: DateTime(2026, 12, 15, 18, 30),
      notes: ' Unload before 9 ',
    );

void main() {
  group('NewOrder validation', () {
    final today = DateTime(2026, 11, 23);
    test('needs lines, an address and a date from today on', () {
      expect(
        NewOrder(lines: const [], deliveryAddress: 'x', deliveryDate: today).validate(today: today),
        OrderDraftError.noLines,
      );
      expect(
        NewOrder(lines: [OrderLine(product: mango, quantity: 1)], deliveryAddress: ' ', deliveryDate: today)
            .validate(today: today),
        OrderDraftError.missingAddress,
      );
      expect(
        NewOrder(
          lines: [OrderLine(product: mango, quantity: 1)],
          deliveryAddress: 'Lima',
          deliveryDate: today.subtract(const Duration(days: 1)),
        ).validate(today: today),
        OrderDraftError.pastDeliveryDate,
      );
      expect(newOrder().validate(today: today), isNull);
    });
  });

  group('OrderJsonParser', () {
    test('builds CreateOrderResource', () {
      final body = OrderJsonParser.toCreateBody(newOrder(), clientId: 7);
      expect(body, {
        'commercialClientId': 7,
        'deliveryDueDate': '2026-12-15', // Swagger format: date (DateOnly)
        'deliveryAddress': 'Av. Arequipa 123, Lince',
        'totalAmount': 67.5,
        'notes': 'Unload before 9',
        'items': [
          {'productId': 1, 'productName': 'Mango Kent', 'quantityKg': 10, 'unitPrice': 4.5, 'subtotal': 45.0},
          {'productId': 3, 'productName': 'Hass avocado', 'quantityKg': 3, 'unitPrice': 7.5, 'subtotal': 22.5},
        ],
      });
    });

    test('real response of GET /api/v1/orders (platform API)', () {
      final orders = OrderJsonParser.parseList(jsonDecode('''
[
  {"id": 3, "commercialClientId": 361, "producerId": 1, "status": "InPreparation",
   "deliveryDueDate": "2026-11-30", "deliveryAddress": "Lima Central Hub - Av. Argentina 3090, Callao",
   "totalAmount": 94000, "notes": "Cliente: Tambo | Pallets estimados: 16", "cancellationReason": null,
   "items": [{"id": 3, "productId": 1, "productName": "Palta Hass", "quantityKg": 10000, "unitPrice": 9.4, "subtotal": 94000}],
   "createdAt": "2026-11-13T07:05:27+00:00", "updatedAt": "2026-11-13T07:30:22+00:00"},
  {"id": 5, "commercialClientId": 105, "producerId": null, "status": "Pending",
   "deliveryDueDate": "2026-11-16", "deliveryAddress": "Mercado Mayorista Santa Anita, Pabellón A, Lima",
   "totalAmount": 103.2, "notes": null, "cancellationReason": null,
   "items": [{"id": 5, "productId": 2, "productName": "Uva Red Globe", "quantityKg": 12, "unitPrice": 8.6, "subtotal": 103.2}],
   "createdAt": "2026-11-13T13:53:46+00:00", "updatedAt": "2026-11-13T13:53:46+00:00"}
]'''));
      expect(orders.map((o) => o.code), ['ORD-0003', 'ORD-0005']);
      expect(orders.first.status, OrderStatus.preparing);
      expect(orders.first.deliveryDate, DateTime(2026, 11, 30));
      expect(orders.first.total, 94000);
      expect(orders.first.lines.single.quantity, 10000);
      expect(orders.last.status, OrderStatus.pending);
      expect(orders.last.notes, isNull);
    });

    test('statuses in different spellings', () {
      expect(OrderJsonParser.parseStatus('PENDING'), OrderStatus.pending);
      expect(OrderJsonParser.parseStatus('ProducerAssigned'), OrderStatus.preparing);
      expect(OrderJsonParser.parseStatus('in_transit'), OrderStatus.inTransit);
      expect(OrderJsonParser.parseStatus('En ruta'), OrderStatus.inTransit);
      expect(OrderJsonParser.parseStatus('DELIVERED'), OrderStatus.delivered);
      expect(OrderJsonParser.parseStatus('Cancelado'), OrderStatus.cancelled);
      expect(OrderJsonParser.parseStatus(5), OrderStatus.rejected);
      expect(OrderJsonParser.parseStatus(null), OrderStatus.pending);
    });

    test('parses orders and items, skipping malformed ones', () {
      final orders = OrderJsonParser.parseList({
        'data': [
          {
            'id': 57,
            'commercialClientId': 7,
            'deliveryDueDate': '2026-12-15T12:00:00Z',
            'deliveryAddress': 'Lince',
            'totalAmount': '67.50',
            'status': 'IN_TRANSIT',
            'notes': '',
            'items': [
              {'productId': 1, 'productName': 'Mango Kent', 'quantityKg': 10.0, 'unitPrice': 4.5, 'subtotal': 45},
              {'productId': 3, 'productName': 'Hass avocado', 'quantityKg': 3, 'subtotal': 22.5},
            ],
          },
          {'deliveryAddress': 'no id'},
        ],
      });
      final order = orders.single;
      expect(order.code, 'ORD-0057');
      expect(order.status, OrderStatus.inTransit);
      expect(order.total, 67.5);
      expect(order.notes, isNull);
      expect(order.lines.map((l) => (l.product.name, l.quantity, l.product.price)), [
        ('Mango Kent', 10, 4.5),
        ('Hass avocado', 3, 7.5), // unit price derived from the subtotal
      ]);
      expect(order.productSummary, 'Mango Kent · Hass avocado');
    });
  });

  group('HttpOrderRepository', () {
    late List<http.Request> requests;

    HttpOrderRepository repository(Future<http.Response> Function(http.Request) handler) {
      requests = [];
      return HttpOrderRepository(
        clientId: 7,
        api: FruitLogixOrdersApi(
          token: () => 'jwt',
          baseUri: Uri.parse('https://api.test'),
          client: MockClient((request) {
            requests.add(request);
            return handler(request);
          }),
        ),
      );
    }

    test("reads the client's orders with the JWT", () async {
      final repo = repository((_) async => http.Response(
            jsonEncode([
              {'id': 57, 'commercialClientId': 7, 'deliveryDueDate': '2026-12-15T12:00:00Z', 'status': 'PENDING'},
              {'id': 58, 'commercialClientId': 9, 'deliveryDueDate': '2026-12-16T12:00:00Z', 'status': 'PENDING'},
            ]),
            200,
          ));
      final orders = await repo.fetchMyOrders();
      expect(requests.single.url.path, '/api/v1/orders/client/7');
      expect(requests.single.headers['Authorization'], 'Bearer jwt');
      expect(orders.map((o) => o.id), ['57']); // never another client's order
    });

    test('no orders yet (404) is an empty list', () async {
      final repo = repository((_) async => http.Response('', 404));
      expect(await repo.fetchMyOrders(), isEmpty);
    });

    test('places the order and returns the created one', () async {
      final repo = repository((request) async => http.Response(
            jsonEncode({'id': 60, 'deliveryDueDate': '2026-12-15T12:00:00Z', 'status': 'PENDING'}),
            201,
          ));
      final created = await repo.placeOrder(newOrder());
      final sent = requests.single;
      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/orders');
      expect(jsonDecode(sent.body)['commercialClientId'], 7);
      expect(created.code, 'ORD-0060');
    });

    test('201 without body: takes the newest order of the client', () async {
      final repo = repository((request) async => request.method == 'POST'
          ? http.Response('', 201)
          : http.Response(
              jsonEncode([
                {'id': 57, 'deliveryDueDate': '2026-12-01T12:00:00Z'},
                {'id': 61, 'deliveryDueDate': '2026-12-15T12:00:00Z'},
              ]),
              200,
            ));
      expect((await repo.placeOrder(newOrder())).id, '61');
    });

    test('validation errors keep the backend message', () async {
      final repo = repository((_) async => http.Response(
            jsonEncode({'title': 'One or more validation errors occurred.', 'errors': {'Items': ['At least one item is required']}}),
            400,
          ));
      await expectLater(
        repo.placeOrder(newOrder()),
        throwsA(isA<OrderApiException>()
            .having((e) => e.reason, 'reason', OrderApiFailure.invalid)
            .having((e) => e.message, 'message', 'At least one item is required')),
      );
    });

    test('expired session', () async {
      final repo = repository((_) async => http.Response('Invalid token', 500));
      await expectLater(
        repo.fetchMyOrders(),
        throwsA(isA<OrderApiException>()
            .having((e) => e.reason, 'reason', OrderApiFailure.unauthorized)),
      );
    });
  });

  group('OrdersController', () {
    test('counts active and in-transit orders, adds new ones on top', () async {
      final controller = OrdersController(
        repository: DemoOrderRepository(latency: Duration.zero),
      );
      await controller.load();
      expect(controller.status, OrdersStatus.ready);
      expect(controller.activeCount, 2);
      expect(controller.inTransitCount, 1);
      final created = await controller.placeOrder(NewOrder(
        lines: [OrderLine(product: mango, quantity: 5)],
        deliveryAddress: 'Lince',
        deliveryDate: DateTime.now().add(const Duration(days: 2)),
      ));
      expect(controller.orders.first, same(created));
      expect(controller.activeCount, 3);
    });

    test('a failed load keeps the error for the screen', () async {
      final controller = OrdersController(
        repository: HttpOrderRepository(
          clientId: 7,
          api: FruitLogixOrdersApi(
            token: () => 'jwt',
            baseUri: Uri.parse('https://api.test'),
            client: MockClient((_) async => http.Response('boom', 503)),
          ),
        ),
      );
      await controller.load();
      expect(controller.status, OrdersStatus.failure);
      expect(controller.error, isA<OrderApiException>());
    });
  });

  testWidgets('Home counts the orders and the catalog places a new one', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(
        localeController: LocaleController(),
        orderModule: OrderManagementModule.demo(latency: Duration.zero),
      ),
    ));
    await tester.pumpAndSettle();

    // Home: active orders from the order data (demo: ORD-1042, ORD-1040).
    expect(find.bySemanticsLabel(RegExp(r'^Active orders: 2$')), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp(r'^In transit: 1$')), findsOneWidget);
    expect(find.text('ORD-1042'), findsOneWidget);

    // Catalog → review → place.
    await tester.tap(find.text('Catalog'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Add Mango Kent'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review order'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).first, 'Av. Arequipa 123, Lince');
    await tester.tap(find.byIcon(Icons.calendar_month_outlined));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(TextButton).last); // date picker OK
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField).last, 'Unload before 9');
    await tester.tap(find.text('Save order'));
    await tester.pumpAndSettle();

    // Orders tab shows it first, with its notes.
    expect(find.text('ORD-1043'), findsOneWidget);
    expect(find.text('Unload before 9'), findsOneWidget);
    expect(find.text('Order placed'), findsOneWidget);
  });
}
