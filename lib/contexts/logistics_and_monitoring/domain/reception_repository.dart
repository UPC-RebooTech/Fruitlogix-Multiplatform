import 'shipment.dart';

/// Records the reception of a delivery and the client's rating (US35).
abstract interface class ReceptionRepository {
  Future<void> confirm(DeliveryShipment shipment, ReceptionReport report);
}
