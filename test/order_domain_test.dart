import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';

void main() {
  test('Demo catalog includes products for commercial customers', () {
    final products = const DemoCatalogRepository().getProducts();
    expect(products, isNotEmpty);
    expect(products.every((p) => p.price > 0 && p.stock >= 0), isTrue);
  });

  test('Demo repository registers order and calculates totals', () async {
    final product = const DemoCatalogRepository().getProducts().first;
    final repo = DemoOrderRepository(latency: Duration.zero);
    final before = (await repo.fetchMyOrders()).length;
    final order = await repo.placeOrder(NewOrder(
      lines: [OrderLine(product: product, quantity: 2)],
      deliveryAddress: 'Lima, Peru',
      deliveryDate: DateTime.now().add(const Duration(days: 7)),
    ));
    expect(order.total, product.price * 2);
    expect(order.status, OrderStatus.pending);
    expect(order.code, 'ORD-1043');
    expect((await repo.fetchMyOrders()).length, before + 1);
  });
}
