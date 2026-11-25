import 'commercial_order.dart';

/// Reasons why an order mutation must not be sent to the API.
enum OrderMutationError {
  differentOrder,
  notPending,
  missingAddress,
  pastDeliveryDate,
}

/// Editable fields exposed by the backend's UpdateOrderResource.
///
/// The deployed contract does not accept a replacement `items` array. Thus
/// changing quantities or products is intentionally not represented here.
class OrderUpdate {
  const OrderUpdate({
    required this.orderId,
    required this.deliveryDate,
    required this.deliveryAddress,
    this.notes,
  });

  final String orderId;
  final DateTime deliveryDate;
  final String deliveryAddress;
  final String? notes;

  factory OrderUpdate.fromOrder(CommercialOrder order) => OrderUpdate(
    orderId: order.id,
    deliveryDate: order.deliveryDate,
    deliveryAddress: order.deliveryAddress,
    notes: order.notes,
  );

  OrderMutationError? validateAgainst(
    CommercialOrder current, {
    DateTime? today,
  }) {
    if (orderId != current.id) return OrderMutationError.differentOrder;
    if (!current.canEdit) return OrderMutationError.notPending;
    if (deliveryAddress.trim().isEmpty) {
      return OrderMutationError.missingAddress;
    }
    final now = today ?? DateTime.now();
    final firstDay = DateTime(now.year, now.month, now.day);
    final dueDate = DateTime(
      deliveryDate.year,
      deliveryDate.month,
      deliveryDate.day,
    );
    if (dueDate.isBefore(firstDay)) {
      return OrderMutationError.pastDeliveryDate;
    }
    return null;
  }

  /// Useful for local demos; remote updates must use the server's response.
  CommercialOrder applyTo(CommercialOrder current, {DateTime? today}) {
    final error = validateAgainst(current, today: today);
    if (error != null) throw StateError('Invalid order update: $error');
    final cleanNotes = notes?.trim();
    return current.copyWith(
      deliveryAddress: deliveryAddress.trim(),
      deliveryDate: deliveryDate,
      notes: cleanNotes,
      clearNotes: cleanNotes == null || cleanNotes.isEmpty,
    );
  }
}

/// Cancellation of a pending order by its Commercial Client.
class OrderCancellation {
  const OrderCancellation({required this.orderId, this.reason});

  final String orderId;
  final String? reason;

  OrderMutationError? validateAgainst(CommercialOrder current) {
    if (orderId != current.id) return OrderMutationError.differentOrder;
    if (!current.canCancel) return OrderMutationError.notPending;
    return null;
  }

  /// Useful for local demos; remote cancellations use the server's response.
  CommercialOrder applyTo(CommercialOrder current) {
    final error = validateAgainst(current);
    if (error != null) throw StateError('Invalid cancellation: $error');
    final cleanReason = reason?.trim();
    return current.copyWith(
      status: OrderStatus.cancelled,
      cancellationReason: cleanReason,
      clearCancellationReason: cleanReason == null || cleanReason.isEmpty,
    );
  }
}
