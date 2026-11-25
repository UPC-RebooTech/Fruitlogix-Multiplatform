import 'fruit_product.dart';

/// Read-only catalog port for Order Management.
///
/// Caching and HTTP transport belong to Infrastructure, not Domain.
abstract interface class CatalogRepository {
  Future<List<FruitProduct>> fetchProducts();
}
