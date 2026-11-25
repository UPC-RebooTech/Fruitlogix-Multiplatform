import 'commercial_order.dart';

/// Read and creation port for the signed-in Commercial Client.
///
/// Retained unchanged at the method-signature level so current demo and HTTP
/// adapters, controllers, and existing widget tests keep compiling.
abstract interface class OrderRepository {
  Future<List<CommercialOrder>> fetchMyOrders();
  Future<CommercialOrder> placeOrder(NewOrder order);
  Future<Map<int, String>> fetchProducerNames();
}
