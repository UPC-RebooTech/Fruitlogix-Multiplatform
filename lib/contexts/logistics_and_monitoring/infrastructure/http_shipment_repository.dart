import '../domain/shipment.dart';
import '../domain/shipment_repository.dart';
import 'delivery_json_parser.dart';
import 'fruitlogix_logistics_api.dart';

/// Deliveries of the client's orders in the platform API.
///
/// `GET /api/v1/deliveries` returns every client's deliveries, so only the
/// ones whose `orderId` belongs to the signed-in client are kept.
class HttpShipmentRepository implements ShipmentRepository {
  HttpShipmentRepository({required this.api, required this.clientOrders});

  final FruitLogixLogisticsApi api;
  final ClientOrdersLookup clientOrders;

  @override
  Future<List<DeliveryShipment>> fetchMyShipments() async {
    final orders = {
      for (final order in await clientOrders()) order.orderId: order,
    };
    if (orders.isEmpty) return const [];

    final List<Map<dynamic, dynamic>> deliveries;
    try {
      deliveries = DeliveryJsonParser.list(await api.getDeliveries());
    } on FormatException {
      throw const LogisticsApiException(LogisticsApiFailure.unexpectedResponse);
    }

    final mine = [
      for (final json in deliveries)
        if (orders.containsKey(DeliveryJsonParser.orderIdOf(json))) json,
    ];
    return Future.wait([
      for (final json in mine)
        _withReading(json, orders[DeliveryJsonParser.orderIdOf(json)]!),
    ]);
  }

  Future<DeliveryShipment> _withReading(
    Map<dynamic, dynamic> json,
    ShipmentOrderRef order,
  ) async {
    TelemetryLog? reading;
    final id = DeliveryJsonParser.idOf(json);
    if (id != null) {
      try {
        reading = DeliveryJsonParser.latestReading(
          await api.getTrackingLogs(id),
        );
      } on LogisticsApiException catch (error) {
        // A delivery without readings may answer 404; others still show.
        if (error.reason == LogisticsApiFailure.unauthorized) rethrow;
      } on FormatException {
        reading = null;
      }
    }
    try {
      return DeliveryJsonParser.parse(json, order: order, telemetry: reading);
    } on FormatException {
      throw const LogisticsApiException(LogisticsApiFailure.unexpectedResponse);
    }
  }
}
