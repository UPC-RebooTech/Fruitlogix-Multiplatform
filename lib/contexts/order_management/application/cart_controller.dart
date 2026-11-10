import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';
import '../domain/fruit_product.dart';

/// UI-independent application state for the current commercial order.
class CartController extends ChangeNotifier {
  CartController(this.products);

  final List<FruitProduct> products;
  final Map<int, int> _quantities = {};

  int quantityFor(int productId) => _quantities[productId] ?? 0;

  int get itemCount => _quantities.values.fold<int>(0, (a, b) => a + b);

  List<OrderLine> get lines => products
      .where((product) => quantityFor(product.id) > 0)
      .map((product) => OrderLine(
            product: product,
            quantity: quantityFor(product.id),
          ))
      .toList(growable: false);

  double get total => lines.fold<double>(0, (sum, line) => sum + line.subtotal);

  void add(FruitProduct product) {
    final current = quantityFor(product.id);
    if (current >= product.stock) return;
    _quantities[product.id] = current + 1;
    notifyListeners();
  }

  void remove(FruitProduct product) {
    final current = quantityFor(product.id);
    if (current <= 0) return;
    if (current == 1) {
      _quantities.remove(product.id);
    } else {
      _quantities[product.id] = current - 1;
    }
    notifyListeners();
  }

  void clear() {
    _quantities.clear();
    notifyListeners();
  }
}
