import '../domain/commercial_order.dart';
import '../domain/order_repository.dart';
import 'fruitlogix_orders_api.dart';
import 'order_json_parser.dart';

/// Orders of the signed-in Commercial Client in the platform API.
///
/// The backend identifies the client with the IAM user id
/// (`commercialClientId == user.id`), as Payment Management does.
class HttpOrderRepository implements OrderRepository {
  HttpOrderRepository({required this.api, required this.clientId});

  final FruitLogixOrdersApi api;
  final int clientId;

  @override
  Future<List<CommercialOrder>> fetchMyOrders() async {
    final Object? body;
    try {
      body = await api.getClientOrders(clientId);
    } on OrderApiException catch (error) {
      // Some backends answer 404 when the client has no orders yet.
      if (error.reason == OrderApiFailure.notFound) return const [];
      rethrow;
    }
    return _mine(body);
  }

  @override
  Future<CommercialOrder> placeOrder(NewOrder order) async {
    final problem = order.validate();
    if (problem != null) throw ArgumentError('Invalid order: $problem');

    final body = await api.createOrder(
      OrderJsonParser.toCreateBody(order, clientId: clientId),
    );
    if (body is Map) {
      try {
        return OrderJsonParser.parse(body);
      } on FormatException {
        // Fall through: look for it in the list.
      }
    }
    // 201 without a usable body: the newest order of the client is ours.
    final orders = await fetchMyOrders();
    if (orders.isEmpty) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    orders.sort(
      (a, b) => (int.tryParse(b.id) ?? 0).compareTo(int.tryParse(a.id) ?? 0),
    );
    return orders.first;
  }

  @override
  Future<Map<int, String>> fetchProducerNames() async =>
      OrderJsonParser.parseProducerNames(await api.getProducers());

  List<CommercialOrder> _mine(Object? body) {
    try {
      final raw = switch (body) {
        List() => body,
        Map() => body['data'] ?? body['items'] ?? body['orders'],
        _ => body,
      };
      // Defensive: keep only this client's orders when the API says whose
      // each order is.
      final filtered = raw is List
          ? [
              for (final item in raw)
                if (item is! Map ||
                    OrderJsonParser.clientIdOf(item) == null ||
                    OrderJsonParser.clientIdOf(item) == clientId)
                  item,
            ]
          : raw;
      return OrderJsonParser.parseList(filtered);
    } on FormatException {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
  }
}
