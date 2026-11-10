import 'fruit_product.dart';

class OrderLine {
  const OrderLine({required this.product, required this.quantity});

  final FruitProduct product;
  final int quantity;

  double get subtotal => product.price * quantity;
}

class CommercialOrder {
  CommercialOrder({
    required this.id,
    required this.lines,
    required this.deliveryAddress,
    required this.deliveryDate,
    required this.status,
  });

  final String id;
  final List<OrderLine> lines;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final String status;

  double get total => lines.fold<double>(0, (sum, line) => sum + line.subtotal);
}
