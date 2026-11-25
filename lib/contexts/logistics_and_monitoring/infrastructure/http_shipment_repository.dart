import '../domain/shipment.dart';
import '../domain/shipment_repository.dart';
import 'delivery_json_parser.dart';
import 'fruitlogix_logistics_api.dart';

/// Deliveries of the client's orders in the platform API.
///
/// One `GET /api/v1/deliveries` (already filtered by the platform), then the
/// latest reading and the events of each delivery. The client's orders give
/// the order code and items shown with each delivery.
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
    final id = DeliveryJsonParser.idOf(json);
    final (reading, events) = id == null
        ? (null, null)
        : await (
            _optional(() async =>
                DeliveryJsonParser.latestReading(await api.getTrackingLogs(id))),
            _optional(() async =>
                DeliveryJsonParser.events(await api.getDeliveryEvents(id))),
          ).wait;
    try {
      return DeliveryJsonParser.parse(
        json,
        order: order,
        telemetry: reading,
        events: events ?? const [],
      );
    } on FormatException {
      throw const LogisticsApiException(LogisticsApiFailure.unexpectedResponse);
    }
  }

  /// Readings and events are extras: without them the delivery still shows.
  static Future<T?> _optional<T>(Future<T?> Function() load) async {
    try {
      return await load();
    } on LogisticsApiException catch (error) {
      if (error.reason == LogisticsApiFailure.unauthorized) rethrow;
      return null;
    } on FormatException {
      return null;
    }
  }
}
