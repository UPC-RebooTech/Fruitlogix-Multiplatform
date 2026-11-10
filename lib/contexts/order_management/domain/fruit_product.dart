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
  });

  final int id;
  final String name;
  final String description;
  final String category;
  final double price;
  final int stock;
  final String unit;
}
