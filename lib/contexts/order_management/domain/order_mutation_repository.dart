import 'commercial_order.dart';
import 'order_edit.dart';
import 'order_repository.dart';

/// Extended port for backend-supported updates and cancellations.
///
/// Infrastructure must verify that the order belongs to the current session
/// and let the server authorize every write. DELETE is intentionally absent:
/// a cancelled order should remain visible in the client's history.
abstract interface class OrderMutationRepository implements OrderRepository {
  Future<CommercialOrder?> fetchOrderById(String orderId);

  Future<CommercialOrder> updateOrder(
    CommercialOrder current,
    OrderUpdate changes,
  );

  Future<CommercialOrder> cancelOrder(
    CommercialOrder current,
    OrderCancellation cancellation,
  );
}
