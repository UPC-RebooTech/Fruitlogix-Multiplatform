import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/in_memory_order_repository.dart';

void main() {
  test('Demo catalog includes products for commercial customers', () {
    final products = const DemoCatalogRepository().getProducts();
    expect(products, isNotEmpty);
    expect(products.every((p) => p.price > 0 && p.stock >= 0), isTrue);
  });

  test('In-memory repository registers order and calculates totals', () {
    final product = const DemoCatalogRepository().getProducts().first;
    final repo = InMemoryOrderRepository.instance;
    final before = repo.orders.length;
    final order = repo.placeOrder(
      lines: [OrderLine(product: product, quantity: 2)],
      deliveryAddress: 'Lima, Peru',
      deliveryDate: DateTime(2026, 12, 10),
    );
    expect(order.total, product.price * 2);
    expect(order.status, 'PENDING');
    expect(repo.orders.length, before + 1);
  });
}
