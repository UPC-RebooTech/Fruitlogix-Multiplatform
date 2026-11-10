import 'commercial_order.dart';

/// Contract for registering and consulting commercial orders.
abstract interface class OrderRepository {
  List<CommercialOrder> get orders;

  CommercialOrder placeOrder({
    required List<OrderLine> lines,
    required String deliveryAddress,
    required DateTime deliveryDate,
  });
}
