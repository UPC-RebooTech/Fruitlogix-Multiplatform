/// Product information visible to a Commercial Client.
///
/// The server is the source of truth for stock and price. Values in this
/// object are a snapshot taken when the catalog was last refreshed.
class FruitProduct {
  const FruitProduct({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'kg',
    this.minQuantity = 1,
    this.producerId,
    this.producerName,
    this.imageUrl,
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final String unit;
  final int minQuantity;
  final int? producerId;
  final String? producerName;
  final String? imageUrl;

  /// Whether the product can be selected for a new commercial order.
  bool get isOrderable =>
      id > 0 &&
      name.trim().isNotEmpty &&
      price.isFinite &&
      price > 0 &&
      minQuantity > 0 &&
      stock >= minQuantity;

  /// Checks an integer quantity against the catalog's latest stock snapshot.
  bool allowsQuantity(int quantity) =>
      isOrderable && quantity >= minQuantity && quantity <= stock;
}
