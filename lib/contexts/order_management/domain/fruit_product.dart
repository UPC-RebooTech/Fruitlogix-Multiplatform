/// Product representation used by the Order Management bounded context.
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

  /// Filter group: the fruit type in the platform (`Mango`), or the demo
  /// group (`Fruits`, `Vegetables`).
  final String category;

  /// Price per [unit] (per kg in the platform).
  final double price;

  /// Available quantity (`availableKg`).
  final int stock;
  final String unit;

  /// Smallest quantity per order (`minOrderKg`).
  final int minQuantity;

  /// Producer that sells it. An order can only have one producer.
  final int? producerId;
  final String? producerName;
  final String? imageUrl;
}
