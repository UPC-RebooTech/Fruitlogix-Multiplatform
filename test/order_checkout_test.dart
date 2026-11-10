import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/cart_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/in_memory_order_repository.dart';

void main() {
  test('Cart can be checked out into a new commercial order', () {
    final cart = CartController(const DemoCatalogRepository().getProducts());
    final selected = cart.products.first;
    cart.add(selected);
    final before = InMemoryOrderRepository.instance.orders.length;
    final order = InMemoryOrderRepository.instance.placeOrder(
      lines: cart.lines,
      deliveryAddress: 'Lima Central Hub',
      deliveryDate: DateTime(2026, 12, 15),
    );
    expect(order.lines.single.product.id, selected.id);
    expect(order.total, selected.price);
    expect(InMemoryOrderRepository.instance.orders.length, before + 1);
    cart.clear();
    expect(cart.itemCount, 0);
    cart.dispose();
  });
}
