import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';
import '../domain/order_repository.dart';

/// Session-only demo orders; nothing is sent to the real backend.
class InMemoryOrderRepository extends ChangeNotifier implements OrderRepository {
  InMemoryOrderRepository._();

  static final InMemoryOrderRepository instance = InMemoryOrderRepository._();

  final List<CommercialOrder> _orders = [];
  int _nextOrderNumber = 1043;

  @override
  List<CommercialOrder> get orders => List.unmodifiable(_orders.reversed);

  @override
  CommercialOrder placeOrder({
    required List<OrderLine> lines,
    required String deliveryAddress,
    required DateTime deliveryDate,
  }) {
    if (lines.isEmpty) throw ArgumentError('At least one product is required.');
    if (deliveryAddress.trim().isEmpty) throw ArgumentError('Delivery address is required.');
    final order = CommercialOrder(
      id: 'ORD-${_nextOrderNumber++}',
      lines: List.unmodifiable(lines),
      deliveryAddress: deliveryAddress.trim(),
      deliveryDate: deliveryDate,
      status: 'PENDING',
    );
    _orders.add(order);
    notifyListeners();
    return order;
  }
}
