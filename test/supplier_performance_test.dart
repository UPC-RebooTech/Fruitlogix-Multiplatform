import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/orders_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/supplier_performance.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/presentation/customer_orders_page.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/order_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/order_management_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

final today = DateTime(2026, 11, 24, 10);

class _FixedOrders implements OrderRepository {
  _FixedOrders(this.orders);
  final List<CommercialOrder> orders;

  @override
  Future<List<CommercialOrder>> fetchMyOrders() async => orders;

  @override
  Future<CommercialOrder> placeOrder(NewOrder order) => throw UnimplementedError();

  @override
  Future<Map<int, String>> fetchProducerNames() async => const {};
}
final mango = const DemoCatalogRepository().getProducts().first;

CommercialOrder order(
  String id,
  OrderStatus status, {
  required DateTime due,
  DateTime? completedAt,
  int? producerId = 1,
}) =>
    CommercialOrder(
      id: id,
      lines: [OrderLine(product: mango, quantity: 10)],
      deliveryAddress: 'Lima',
      deliveryDate: due,
      status: status,
      producerId: producerId,
      completedAt: completedAt,
    );

void main() {
  group('US24 · measureSupplierPerformance', () {
    test('on time, late, overdue and not counted', () {
      final report = measureSupplierPerformance([
        // Producer 1: delivered the same day (late in the day still counts).
        order('1', OrderStatus.delivered, due: DateTime(2026, 11, 10), completedAt: DateTime(2026, 11, 10, 23)),
        // Producer 1: delivered early.
        order('2', OrderStatus.delivered, due: DateTime(2026, 11, 12), completedAt: DateTime(2026, 11, 11)),
        // Producer 1: delivered a day late.
        order('3', OrderStatus.delivered, due: DateTime(2026, 11, 15), completedAt: DateTime(2026, 11, 16)),
        // Producer 2: still in preparation after its date → late.
        order('4', OrderStatus.preparing, due: DateTime(2026, 11, 20), producerId: 2),
        // Not counted: not yet due, cancelled, no producer, no completion date.
        order('5', OrderStatus.inTransit, due: DateTime(2026, 11, 24), producerId: 2),
        order('6', OrderStatus.cancelled, due: DateTime(2026, 11, 1)),
        order('7', OrderStatus.delivered, due: DateTime(2026, 11, 1), completedAt: DateTime(2026, 11, 1), producerId: null),
        order('8', OrderStatus.delivered, due: DateTime(2026, 11, 1)),
      ], today: today);

      expect(report.hasData, isTrue);
      expect(report.overall.onTime, 2);
      expect(report.overall.late, 2);
      expect(report.overall.onTimePercent, 50);
      final p1 = report.suppliers.first;
      expect((p1.producerId, p1.onTime, p1.late, p1.onTimePercent, p1.latePercent), (1, 2, 1, 67, 33));
      final p2 = report.suppliers.last;
      expect((p2.producerId, p2.onTime, p2.late, p2.onTimePercent), (2, 0, 1, 0));
    });

    test('scenario 2: nothing to measure', () {
      final report = measureSupplierPerformance([
        order('1', OrderStatus.pending, due: DateTime(2026, 12, 1)),
      ], today: today);
      expect(report.hasData, isFalse);
      expect(report.suppliers, isEmpty);
      expect(report.overall.onTimePercent, 0);
    });
  });

  test('completion date from the API: deliveredAt only (not updatedAt)', () {
    final delivered = OrderJsonParser.parse({
      'id': 3,
      'status': 'Delivered',
      'deliveryDueDate': '2026-11-30',
      'updatedAt': '2026-11-29T15:00:00+00:00',
    });
    // Without deliveredAt there is no completion date.
    expect(delivered.completedAt, isNull);

    final pending = OrderJsonParser.parse({
      'id': 4,
      'status': 'Pending',
      'deliveryDueDate': '2026-11-30',
      'updatedAt': '2026-11-29T15:00:00+00:00',
    });
    expect(pending.completedAt, isNull);

    final explicit = OrderJsonParser.parse({
      'id': 5,
      'status': 'Delivered',
      'deliveryDueDate': '2026-11-30',
      'deliveredAt': '2026-11-28T09:00:00Z',
      'updatedAt': '2026-12-02T15:00:00Z',
    });
    expect(explicit.completedAt!.toUtc(), DateTime.utc(2026, 11, 28, 9));
  });

  Widget app(OrderManagementModule module) => MaterialApp(
        theme: CosechaTheme.light,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CustomerShell(localeController: LocaleController(), orderModule: module),
      );

  testWidgets('US24 · scenario 1: compliance per producer in History', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(app(OrderManagementModule.demo(latency: Duration.zero)));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History (3)'));
    await tester.pumpAndSettle();

    // Demo: Agrícola San José on time (1/1), Fundo El Mango late (0/1).
    expect(find.text('COMPLIANCE BY PRODUCER'), findsOneWidget);
    expect(find.bySemanticsLabel('On time: 50 %'), findsOneWidget);
    expect(find.bySemanticsLabel('Late: 50 %'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Agrícola San José, 100 %, Meets, 1 of 1 on time')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Fundo El Mango, 0 %, Low, 0 of 1 on time · 1 late')),
      findsOneWidget,
    );
  });

  testWidgets('US24 · scenario 2: message when there are no statistics', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2000 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    // A client with one order still pending: nothing to measure yet.
    final controller = OrdersController(
      repository: _FixedOrders([
        order('9', OrderStatus.pending, due: DateTime.now().add(const Duration(days: 5))),
      ]),
    );
    await controller.load();
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(
        body: CustomerOrdersPage(orders: controller, onNewOrder: () {}),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('History (0)'));
    await tester.pumpAndSettle();
    expect(find.textContaining('No compliance statistics yet'), findsOneWidget);
    expect(find.text('No orders in your history yet'), findsOneWidget);
  });

  test('demo data feeds both scenarios', () async {
    final controller = OrdersController(repository: DemoOrderRepository(latency: Duration.zero));
    await controller.load();
    final report = measureSupplierPerformance(controller.orders, today: DateTime.now());
    expect(report.suppliers.map((s) => (s.producerId, s.onTime, s.late)), [(1, 1, 0), (2, 0, 1)]);
  });
}
