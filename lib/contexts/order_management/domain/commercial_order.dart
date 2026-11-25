import 'fruit_product.dart';

/// Lifecycle of an order as shown to the Commercial Client.
enum OrderStatus {
  pending,
  preparing,
  inTransit,
  delivered,
  deliveredWithIncidence,
  cancelled,
  rejected;

  bool get isActive =>
      this == pending || this == preparing || this == inTransit;

  bool get isDelivered => this == delivered || this == deliveredWithIncidence;

  bool get isFinished => !isActive;

  /// Only a not-yet-processed order can be changed from the client app.
  /// The backend has the final authority over this transition.
  bool get allowsClientEdit => this == pending;

  bool get allowsClientCancellation => this == pending;
}

/// Reception information provided by Logistics & Monitoring.
class OrderReception {
  const OrderReception({
    this.rating,
    this.comment,
    this.hasIncidence = false,
    this.sealAndTemperatureOk,
    this.receivedAt,
  });

  final int? rating;
  final String? comment;
  final bool hasIncidence;
  final bool? sealAndTemperatureOk;
  final DateTime? receivedAt;
}

/// A line in a commercial order; product and quantity are a single unit.
class OrderLine {
  const OrderLine({required this.product, required this.quantity});

  final FruitProduct product;
  final int quantity;

  double get subtotal => product.price * quantity;
}

/// Client-side read model of the Order aggregate.
///
/// Products and prices on completed orders are historical snapshots; they
/// must not be replaced by today's prices from the catalog.
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
    this.completedAt,
    this.producerName,
    this.batchId,
    this.cancellationReason,
    this.reception,
    double? totalAmount,
  }) : _totalAmount = totalAmount;

  final String id;
  final List<OrderLine> lines;
  final String deliveryAddress;
  final DateTime deliveryDate;
  final OrderStatus status;
  final String? notes;
  final DateTime? createdAt;
  final int? producerId;
  final DateTime? completedAt;
  final String? producerName;
  final int? batchId;
  final String? cancellationReason;
  final OrderReception? reception;
  final double? _totalAmount;

  String get code {
    final number = int.tryParse(id);
    return number == null ? id : 'ORD-${number.toString().padLeft(4, '0')}';
  }

  double get total =>
      _totalAmount ?? lines.fold<double>(0, (sum, line) => sum + line.subtotal);

  String get productSummary =>
      lines.map((line) => line.product.name).join(' · ');

  bool get canEdit => status.allowsClientEdit;
  bool get canCancel => status.allowsClientCancellation;

  /// Produces a fresh snapshot without altering the API-loaded order.
  CommercialOrder copyWith({
    String? deliveryAddress,
    DateTime? deliveryDate,
    OrderStatus? status,
    String? notes,
    bool clearNotes = false,
    String? cancellationReason,
    bool clearCancellationReason = false,
  }) => CommercialOrder(
    id: id,
    lines: List<OrderLine>.unmodifiable(lines),
    deliveryAddress: deliveryAddress ?? this.deliveryAddress,
    deliveryDate: deliveryDate ?? this.deliveryDate,
    status: status ?? this.status,
    notes: clearNotes ? null : (notes ?? this.notes),
    createdAt: createdAt,
    producerId: producerId,
    completedAt: completedAt,
    producerName: producerName,
    batchId: batchId,
    cancellationReason: clearCancellationReason
        ? null
        : (cancellationReason ?? this.cancellationReason),
    reception: reception,
    totalAmount: _totalAmount,
  );
}

/// Validation errors of a new order, independent of UI language.
enum OrderDraftError {
  noLines,
  missingAddress,
  pastDeliveryDate,
  invalidProduct,
  duplicateProduct,
  outOfStock,
  mixedProducers,
}

/// An order being composed by a signed-in Commercial Client.
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

  OrderDraftError? validate({DateTime? today}) {
    if (lines.isEmpty || lines.any((line) => line.quantity <= 0)) {
      return OrderDraftError.noLines;
    }
    if (deliveryAddress.trim().isEmpty) return OrderDraftError.missingAddress;

    final now = today ?? DateTime.now();
    final startOfToday = DateTime(now.year, now.month, now.day);
    final deliveryDay = DateTime(
      deliveryDate.year,
      deliveryDate.month,
      deliveryDate.day,
    );
    if (deliveryDay.isBefore(startOfToday)) {
      return OrderDraftError.pastDeliveryDate;
    }

    final productIds = <int>{};
    final producerIds = <int>{};
    for (final line in lines) {
      final product = line.product;
      if (product.id <= 0 || !product.price.isFinite || product.price <= 0) {
        return OrderDraftError.invalidProduct;
      }
      if (!productIds.add(product.id)) return OrderDraftError.duplicateProduct;
      if (!product.allowsQuantity(line.quantity)) {
        return OrderDraftError.outOfStock;
      }
      if (product.producerId != null) producerIds.add(product.producerId!);
    }
    if (producerIds.length > 1) return OrderDraftError.mixedProducers;
    return null;
  }
}
