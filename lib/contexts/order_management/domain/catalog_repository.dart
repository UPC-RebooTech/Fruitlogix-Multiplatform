import 'fruit_product.dart';

/// Contract for accessing products relevant to Order Management.
abstract interface class CatalogRepository {
  /// Active products with stock, for the client's catalog.
  Future<List<FruitProduct>> fetchProducts();
}
