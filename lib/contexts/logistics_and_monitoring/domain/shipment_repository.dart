import 'shipment.dart';

/// Deliveries of the signed-in Commercial Client's orders.
abstract interface class ShipmentRepository {
  /// With their latest cold-chain reading.
  Future<List<DeliveryShipment>> fetchMyShipments();
}
