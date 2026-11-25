import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/order_history_filter.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/orders_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/order_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/order_management_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

final products = const DemoCatalogRepository().getProducts();

CommercialOrder order(
  String id,
  OrderStatus status,
  DateTime delivery, {
  int? producerId,
  int productId = 1,
}) =>
    CommercialOrder(
      id: id,
      lines: [OrderLine(product: products.firstWhere((p) => p.id == productId), quantity: 10)],
      deliveryAddress: 'Lima',
      deliveryDate: delivery,
      status: status,
      producerId: producerId,
    );

/// Orders work, producer names fail (e.g. 403): the history still loads.
class _NoProducers extends DemoOrderRepository {
  _NoProducers() : super(latency: Duration.zero);

  @override
  Future<Map<int, String>> fetchProducerNames() => throw Exception('403');
}

void main() {
  final history = [
    order('1036', OrderStatus.delivered, DateTime(2026, 11, 14), producerId: 1, productId: 3),
    order('1031', OrderStatus.cancelled, DateTime(2026, 11, 3), productId: 5),
    order('1027', OrderStatus.delivered, DateTime(2026, 10, 16), producerId: 2),
  ];

  group('US08 · OrderHistoryFilter', () {
    test('no filter keeps everything', () {
      expect(OrderHistoryFilter.none.apply(history), hasLength(3));
      expect(OrderHistoryFilter.none.isActive, isFalse);
    });

    test('search by code or product, ignoring case and accents', () {
      expect(const OrderHistoryFilter(query: 'ord-1031').apply(history).single.id, '1031');
      expect(const OrderHistoryFilter(query: '1027').apply(history).single.id, '1027');
      expect(const OrderHistoryFilter(query: 'HASS').apply(history).single.id, '1036');
      expect(const OrderHistoryFilter(query: 'mangó').apply(history).single.id, '1027');
    });

    test('status, producer and inclusive date range', () {
      expect(
        const OrderHistoryFilter(status: OrderStatus.delivered).apply(history).map((o) => o.id),
        ['1036', '1027'],
      );
      expect(const OrderHistoryFilter(producerId: 2).apply(history).single.id, '1027');
      expect(
        OrderHistoryFilter(from: DateTime(2026, 11, 3), to: DateTime(2026, 11, 14, 8))
            .apply(history)
            .map((o) => o.id),
        ['1036', '1031'],
      );
    });

    test('combined filters with no match (scenario 2)', () {
      expect(
        const OrderHistoryFilter(status: OrderStatus.cancelled, producerId: 1).apply(history),
        isEmpty,
      );
    });

    test('copyWith can clear a value', () {
      final filtered = const OrderHistoryFilter(status: OrderStatus.delivered, producerId: 2);
      final cleared = filtered.copyWith(status: () => null);
      expect(cleared.status, isNull);
      expect(cleared.producerId, 2);
    });
  });

  test('producer names from GET /api/v1/producers', () {
    expect(
      OrderJsonParser.parseProducerNames([
        {'id': 1, 'fullName': 'Ana Pérez', 'legalName': 'Agrícola San José SAC'},
        {'id': 2, 'fullName': 'Luis Quispe', 'legalName': ''},
        {'id': 3},
        'oops',
      ]),
      {1: 'Agrícola San José SAC', 2: 'Luis Quispe'},
    );
    expect(OrderJsonParser.parseProducerNames(null), isEmpty);
  });

  test('order JSON keeps the producerId', () {
    final parsed = OrderJsonParser.parse({
      'id': 3,
      'producerId': 1,
      'status': 'Delivered',
      'deliveryDueDate': '2026-11-30',
    });
    expect(parsed.producerId, 1);
    expect(parsed.status, OrderStatus.delivered);
  });

  group('US07 · OrdersController history', () {
    test('finished orders and producer names', () async {
      final controller = OrdersController(repository: DemoOrderRepository(latency: Duration.zero));
      await controller.load();
      expect(controller.history.map((o) => o.code), ['ORD-1036', 'ORD-1031', 'ORD-1027']);
      expect(controller.activeOrders.map((o) => o.code), ['ORD-1040', 'ORD-1042']);
      expect(controller.producerNames[1], 'Agrícola San José');
    });

    test('without producer names the orders still load', () async {
      final OrderRepository repository = _NoProducers();
      final controller = OrdersController(repository: repository);
      await controller.load();
      expect(controller.status, OrdersStatus.ready);
      expect(controller.history, hasLength(3));
      expect(controller.producerNames, isEmpty);
    });
  });

  testWidgets('US07/US08: history tab with search, filters and empty results', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
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
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    // Active tab by default.
    expect(find.text('ORD-1042'), findsOneWidget);
    expect(find.text('ORD-1036'), findsNothing);

    // History (US07): finished orders with date, status and producer.
    await tester.tap(find.text('History (3)'));
    await tester.pumpAndSettle();
    expect(find.text('3 orders'), findsOneWidget);
    expect(find.text('ORD-1036'), findsOneWidget);
    expect(find.text('Agrícola San José'), findsWidgets);

    // US08: search.
    await tester.enterText(find.byType(TextField), 'grapes');
    await tester.pumpAndSettle();
    expect(find.text('2 orders'), findsOneWidget);
    expect(find.text('ORD-1036'), findsNothing);

    // + status filter (filters are one tap away).
    expect(find.widgetWithText(InkWell, 'Cancelled'), findsNothing);
    await tester.tap(find.textContaining('Filters'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(InkWell, 'Cancelled').first);
    await tester.pumpAndSettle();
    expect(find.text('1 order'), findsOneWidget);
    expect(find.text('ORD-1031'), findsOneWidget);

    // + producer with no match → scenario 2 message.
    await tester.tap(find.widgetWithText(InkWell, 'Fundo El Mango'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Filters (2)'), findsOneWidget);
    expect(find.text('No orders match these filters'), findsOneWidget);

    // Clear filters.
    await tester.tap(find.text('Clear filters').first);
    await tester.pumpAndSettle();
    expect(find.text('3 orders'), findsOneWidget);
  });
}
