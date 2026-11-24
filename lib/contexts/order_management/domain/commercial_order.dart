import 'fruit_product.dart';

/// Lifecycle of a commercial order as seen by the client.
enum OrderStatus {
  /// Registered, waiting for the distributor.
  pending,

  /// Accepted / a producer was assigned and the goods are being prepared.
  preparing,

  /// Dispatched and on its way.
  inTransit,

  /// Received by the client.
  delivered,

  /// Cancelled by the client or the distributor.
  cancelled,

  /// Rejected by the distributor.
  rejected;

  /// Still expected by the client (counts as "active").
  bool get isActive =>
      this == pending || this == preparing || this == inTransit;
}

class OrderLine {
  const OrderLine({required this.product, required this.quantity});

  /// Catalog product. Orders read from the API carry only the id, name and
  /// unit price of each item.
  final FruitProduct product;

  /// Quantity in the product unit (kg).
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
    this.notes,
    this.createdAt,
    this.producerId,
    double? totalAmount,
  }) : _totalAmount = totalAmount;

  /// Producer assigned by the distributor; null while unassigned.
  final int? producerId;

  /// Platform id (`57`) or demo id (`1042`).
  final String id;
  final List<OrderLine> lines;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final OrderStatus status;
  final String? notes;
  final DateTime? createdAt;
  final double? _totalAmount;

  /// Display code: `ORD-1042`.
  String get code {
    final numeric = int.tryParse(id);
    return numeric == null ? id : 'ORD-${numeric.toString().padLeft(4, '0')}';
  }

  /// The amount registered by the platform, or the sum of the lines.
  double get total =>
      _totalAmount ?? lines.fold<double>(0, (sum, line) => sum + line.subtotal);

  /// "Mango Kent · Hass avocado".
  String get productSummary =>
      lines.map((line) => line.product.name).join(' · ');
}

/// Why a [NewOrder] cannot be placed.
enum OrderDraftError { noLines, missingAddress, pastDeliveryDate }

/// An order the client is about to place from the catalog.
class NewOrder {
  const NewOrder({
    required this.lines,
    required this.deliveryAddress,
    required this.deliveryDate,
    this.notes,
  });

  final List<OrderLine> lines;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final String? notes;

  double get total => lines.fold<double>(0, (sum, line) => sum + line.subtotal);

  /// First problem found, or null when the order can be placed.
  OrderDraftError? validate({DateTime? today}) {
    if (lines.isEmpty || lines.any((line) => line.quantity <= 0)) {
      return OrderDraftError.noLines;
    }
    if (deliveryAddress.trim().isEmpty) return OrderDraftError.missingAddress;
    final now = today ?? DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    final delivery = DateTime(
      deliveryDate.year,
      deliveryDate.month,
      deliveryDate.day,
    );
    if (delivery.isBefore(day)) return OrderDraftError.pastDeliveryDate;
    return null;
  }
}
