import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/order_history_filter.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/orders_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/order_edit.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';

void main() {
  final tomorrow = DateTime.now().add(const Duration(days: 1));
  final mango = const DemoCatalogRepository().getProducts().first;

  NewOrder draft() => NewOrder(
        lines: [OrderLine(product: mango, quantity: 2)],
        deliveryAddress: 'Lima',
        deliveryDate: tomorrow,
      );

  test('create, edit and cancel update orders and history', () async {
    final controller = OrdersController(
      repository: DemoOrderRepository(latency: Duration.zero),
    );
    addTearDown(controller.dispose);
    await controller.load();

    final created = await controller.placeOrder(draft());
    expect(controller.findById(created.id)?.status, OrderStatus.pending);
    expect(controller.submitting, isFalse);

    final changed = await controller.updateOrder(
      created,
      OrderUpdate(
        orderId: created.id,
        deliveryDate: tomorrow,
        deliveryAddress: 'Callao',
        notes: 'Deliver early',
      ),
    );
    expect(changed.deliveryAddress, 'Callao');
    expect(controller.findById(created.id)?.notes, 'Deliver early');
    expect(controller.mutating, isFalse);

    final cancelled = await controller.cancelOrder(
      changed,
      OrderCancellation(orderId: created.id, reason: 'Duplicated order'),
    );
    expect(cancelled.status, OrderStatus.cancelled);
    expect(controller.activeOrders.any((o) => o.id == created.id), isFalse);
    expect(controller.history.any((o) => o.id == created.id), isTrue);
    expect(
      controller.filteredHistory(
        const OrderHistoryFilter(status: OrderStatus.cancelled),
      ).any((o) => o.id == created.id),
      isTrue,
    );
  });

  test('non-pending orders cannot be edited again', () async {
    final controller = OrdersController(
      repository: DemoOrderRepository(latency: Duration.zero),
    );
    addTearDown(controller.dispose);
    final created = await controller.placeOrder(draft());
    final cancelled = await controller.cancelOrder(
      created,
      OrderCancellation(orderId: created.id),
    );
    await expectLater(
      controller.updateOrder(
        cancelled,
        OrderUpdate(
          orderId: created.id,
          deliveryDate: tomorrow,
          deliveryAddress: 'Lima',
        ),
      ),
      throwsStateError,
    );
    expect(controller.findById(created.id)?.status, OrderStatus.cancelled);
  });

  test('order progress can be refreshed without replacing unrelated orders', () async {
    final controller = OrdersController(
      repository: DemoOrderRepository(latency: Duration.zero),
    );
    addTearDown(controller.dispose);
    await controller.load();
    final originalCount = controller.orders.length;
    final first = controller.orders.first;
    final refreshed = await controller.refreshOrderById(first.id);
    expect(refreshed?.id, first.id);
    expect(controller.orders.length, originalCount);
  });
}
