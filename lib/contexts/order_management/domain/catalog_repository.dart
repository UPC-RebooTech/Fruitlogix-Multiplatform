import 'fruit_product.dart';

/// Contract for accessing products relevant to Order Management.
abstract interface class CatalogRepository {
  List<FruitProduct> getProducts();
}
