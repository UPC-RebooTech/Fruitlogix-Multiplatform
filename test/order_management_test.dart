import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/application/cart_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/infrastructure/demo_catalog_repository.dart';

void main() {
  test('Cart computes quantities and totals for demo products', () {
    final catalog = const DemoCatalogRepository().getProducts();
    final cart = CartController(catalog);
    cart.add(catalog[0]);
    cart.add(catalog[0]);
    cart.add(catalog[2]);
    expect(cart.itemCount, 3);
    expect(cart.total, 16.5); // 2 x 4.50 + 1 x 7.50
    cart.remove(catalog[0]);
    expect(cart.total, 12);
    cart.clear();
    expect(cart.itemCount, 0);
    cart.dispose();
  });
}
