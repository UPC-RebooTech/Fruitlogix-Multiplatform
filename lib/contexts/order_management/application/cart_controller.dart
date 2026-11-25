import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';
import '../domain/fruit_product.dart';

/// Why a product could not be added.
enum CartAddResult { added, outOfStock, otherProducer }

/// UI-independent application state for the current commercial order.
class CartController extends ChangeNotifier {
  CartController(this._products);

  List<FruitProduct> _products;
  final Map<int, int> _quantities = {};

  List<FruitProduct> get products => _products;

  /// New catalog (e.g. after loading it): keeps the quantities of the
  /// products that are still there, within their new stock.
  void replaceProducts(List<FruitProduct> products) {
    _products = products;
    final byId = {for (final p in products) p.id: p};
    _quantities.removeWhere(
      (id, quantity) =>
          byId[id] == null ||
          quantity > byId[id]!.stock ||
          quantity < byId[id]!.minQuantity,
    );
    notifyListeners();
  }

  /// Producer of the products already in the cart (one producer per order).
  int? get producerId => lines
      .map((line) => line.product.producerId)
      .firstWhere((id) => id != null, orElse: () => null);

  int quantityFor(int productId) => _quantities[productId] ?? 0;

  int get itemCount => _quantities.values.fold<int>(0, (a, b) => a + b);

  List<OrderLine> get lines => products
      .where((product) => quantityFor(product.id) > 0)
      .map(
        (product) =>
            OrderLine(product: product, quantity: quantityFor(product.id)),
      )
      .toList(growable: false);

  double get total => lines.fold<double>(0, (sum, line) => sum + line.subtotal);

  /// The first unit jumps to the product's minimum order quantity.
  CartAddResult add(FruitProduct product) {
    final current = quantityFor(product.id);
    final producer = producerId;
    if (current == 0 &&
        producer != null &&
        product.producerId != null &&
        product.producerId != producer) {
      return CartAddResult.otherProducer;
    }
    final next = current == 0 ? product.minQuantity : current + 1;
    if (next > product.stock) return CartAddResult.outOfStock;
    _quantities[product.id] = next;
    notifyListeners();
    return CartAddResult.added;
  }

  /// Below the minimum order quantity the product leaves the cart.
  void remove(FruitProduct product) {
    final current = quantityFor(product.id);
    if (current <= 0) return;
    if (current - 1 < product.minQuantity) {
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
