import 'commercial_order.dart';

/// Contract for registering and consulting the signed-in client's orders.
abstract interface class OrderRepository {
  /// The client's orders.
  Future<List<CommercialOrder>> fetchMyOrders();

  /// Registers [order]. Throws [ArgumentError] when it is not valid.
  Future<CommercialOrder> placeOrder(NewOrder order);
}
