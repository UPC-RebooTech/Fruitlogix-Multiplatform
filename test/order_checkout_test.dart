import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/cart_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_order_repository.dart';

void main() {
  test('Cart can be checked out into a new commercial order', () async {
    final cart = CartController(const DemoCatalogRepository().getProducts());
    final selected = cart.products.first;
    cart.add(selected);
    final repository = DemoOrderRepository(latency: Duration.zero);
    final before = (await repository.fetchMyOrders()).length;
    final order = await repository.placeOrder(NewOrder(
      lines: cart.lines,
      deliveryAddress: 'Lima Central Hub',
      deliveryDate: DateTime.now().add(const Duration(days: 3)),
    ));
    expect(order.lines.single.product.id, selected.id);
    expect(order.total, selected.price);
    expect((await repository.fetchMyOrders()).length, before + 1);
    cart.clear();
    expect(cart.itemCount, 0);
    cart.dispose();
  });
}
