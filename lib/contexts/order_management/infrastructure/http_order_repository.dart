
import '../domain/commercial_order.dart';
import '../domain/order_edit.dart';
import '../domain/order_mutation_repository.dart';
import 'fruitlogix_orders_api.dart';
import 'order_json_parser.dart';
import 'order_mutation_json.dart';

/// Remote adapter for the signed-in Commercial Client.
/// The authenticated IAM userId, not an ID entered in a form, is the clientId.
class HttpOrderRepository implements OrderMutationRepository {
  HttpOrderRepository({required this.api, required this.clientId});

  final FruitLogixOrdersApi api;
  final int clientId;

  @override
  Future<List<CommercialOrder>> fetchMyOrders() async {
    final Object? body;
    try {
      body = await api.getClientOrders(clientId);
    } on OrderApiException catch (error) {
      if (error.reason == OrderApiFailure.notFound) return const [];
      rethrow;
    }
    try {
      final raw = switch (body) {
        List() => body,
        Map() => body['data'] ?? body['items'] ?? body['orders'],
        null => const [],
        _ => null,
      };
      if (raw is! List) throw const FormatException('Invalid order list');
      final visible = <Object?>[];
      for (final item in raw) {
        if (item is! Map) continue;
        final owner = OrderJsonParser.clientIdOf(item);
        if (owner == null || owner == clientId) visible.add(item);
      }
      return OrderJsonParser.parseList(visible);
    } on FormatException {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
  }

  @override
  Future<CommercialOrder> placeOrder(NewOrder order) async {
    final validation = order.validate();
    if (validation != null) throw ArgumentError('Invalid order: $validation');

    final body = await api.createOrder(
      OrderJsonParser.toCreateBody(order, clientId: clientId),
    );

    final direct = _parseSingleOrNull(body);
    if (direct != null) {
      if (direct.id.isNotEmpty) return direct;
    }

    // The OpenAPI contract specifies 201 without a response schema.
    // Accept a read-back only if one order matches the requested delivery
    // day and address, instead of assuming the newest order belongs to us.
    final candidates = (await fetchMyOrders()).where((candidate) {
      final requested = order.deliveryDate;
      final delivered = candidate.deliveryDate;
      final sameDay = requested.year == delivered.year &&
          requested.month == delivered.month &&
          requested.day == delivered.day;
      final knownAddress = candidate.deliveryAddress.trim();
      final sameAddress = knownAddress.isEmpty ||
          knownAddress == order.deliveryAddress.trim();
      return sameDay && sameAddress;
    }).toList();

    if (candidates.length == 1) return candidates.single;
    throw const OrderApiException(OrderApiFailure.unexpectedResponse);
  }

  @override
  Future<Map<int, String>> fetchProducerNames() async =>
      OrderJsonParser.parseProducerNames(await api.getProducers());

  /// Returns null if this order does not appear in the current client's list.
  /// A direct GET is never trusted as proof of ownership on its own.
  @override
  Future<CommercialOrder?> fetchOrderById(String orderId) async {
    final numericId = _id(orderId);
    final own = await fetchMyOrders();
    if (!own.any((order) => order.id == orderId)) return null;

    final body = await api.getOrder(numericId);
    final json = _singleMap(body);
    final owner = OrderJsonParser.clientIdOf(json);
    if (owner != null && owner != clientId) {
      throw const OrderApiException(OrderApiFailure.forbidden);
    }
    if (!_hasStatus(json)) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    final order = _parseSingleOrNull(json);
    if (order == null || order.id != orderId) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    return order;
  }

  @override
  Future<CommercialOrder> updateOrder(
    CommercialOrder current,
    OrderUpdate changes,
  ) async {
    final localError = changes.validateAgainst(current);
    if (localError != null) throw StateError('Invalid update: $localError');
    final latest = await fetchOrderById(current.id);
    if (latest == null) {
      throw const OrderApiException(OrderApiFailure.notFound);
    }
    final serverError = changes.validateAgainst(latest);
    if (serverError != null) {
      throw const OrderApiException(OrderApiFailure.conflict);
    }

    final result = await api.updateOrder(
      _id(current.id),
      OrderMutationJson.update(latest, changes),
    );
    final updated = await _readMutationResult(current.id, result);
    final expectedDate = changes.deliveryDate;
    final actualDate = updated.deliveryDate;
    if (updated.deliveryAddress.trim() != changes.deliveryAddress.trim() ||
        actualDate.year != expectedDate.year ||
        actualDate.month != expectedDate.month ||
        actualDate.day != expectedDate.day) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    return updated;
  }

  @override
  Future<CommercialOrder> cancelOrder(
    CommercialOrder current,
    OrderCancellation cancellation,
  ) async {
    final localError = cancellation.validateAgainst(current);
    if (localError != null) throw StateError('Invalid cancellation: $localError');
    final latest = await fetchOrderById(current.id);
    if (latest == null) {
      throw const OrderApiException(OrderApiFailure.notFound);
    }
    final serverError = cancellation.validateAgainst(latest);
    if (serverError != null) {
      throw const OrderApiException(OrderApiFailure.conflict);
    }

    final result = await api.cancelOrder(
      _id(current.id),
      OrderMutationJson.cancel(cancellation),
    );
    final changed = await _readMutationResult(current.id, result);
    if (changed.status != OrderStatus.cancelled) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    return changed;
  }

  Future<CommercialOrder> _readMutationResult(
    String expectedId,
    Object? body,
  ) async {
    // Some 200 responses contain only an ID; they are not complete orders.
    // Read again instead of treating a missing status as Pending.
    final parsed = _parseCompleteOrNull(body);
    if (parsed != null && parsed.id == expectedId) return parsed;
    final refreshed = await fetchOrderById(expectedId);
    if (refreshed == null) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    return refreshed;
  }

  static int _id(String orderId) {
    final value = int.tryParse(orderId);
    if (value == null || value <= 0) {
      throw ArgumentError.value(orderId, 'orderId', 'Expected numeric ID');
    }
    return value;
  }

  static Map<dynamic, dynamic> _singleMap(Object? body) {
    final value = body is Map
        ? (body['data'] ?? body['order'] ?? body)
        : null;
    if (value is! Map) {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
    return value;
  }

  static bool _hasStatus(Map<dynamic, dynamic> json) =>
      json['status'] != null ||
      json['orderStatus'] != null ||
      json['currentStatus'] != null;

  static CommercialOrder? _parseCompleteOrNull(Object? body) {
    if (body == null) return null;
    try {
      final json = _singleMap(body);
      if (!_hasStatus(json)) return null;
      return OrderJsonParser.parse(json);
    } on OrderApiException {
      return null;
    } on FormatException {
      return null;
    }
  }

  static CommercialOrder? _parseSingleOrNull(Object? body) {
    if (body == null) return null;
    try {
      final json = _singleMap(body);
      return OrderJsonParser.parse(json);
    } on OrderApiException {
      return null;
    } on FormatException {
      return null;
    }
  }
}
