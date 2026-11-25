
import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/api_errors.dart';
import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum OrderApiFailure {
  network,
  unauthorized,
  notFound,
  conflict,
  forbidden,
  invalid,
  server,
  unexpectedResponse,
}

class OrderApiException implements Exception {
  const OrderApiException(this.reason, [this.message]);

  final OrderApiFailure reason;
  final String? message;

  @override
  String toString() =>
      'OrderApiException($reason${message == null ? '' : ': $message'})';
}

/// Order Management transport. The supplied client can be SessionGuardClient.
/// Responses are decoded here; DTO conversion remains in Infrastructure.
class FruitLogixOrdersApi {
  FruitLogixOrdersApi({
    required String Function() token,
    http.Client? client,
    Uri? baseUri,
  }) : _token = token,
       _client = client ?? http.Client(),
       _baseUri = baseUri ?? Uri.parse(fruitLogixApiUrl);

  final String Function() _token;
  final http.Client _client;
  final Uri _baseUri;
  static const Duration _timeout = Duration(seconds: 60);

  Map<String, String> get _headers {
    final token = _token().trim();
    if (token.isEmpty) {
      throw const OrderApiException(OrderApiFailure.unauthorized);
    }
    return {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Uri _uri(String route) => _baseUri.resolve(route);

  /// GET /api/v1/orders/client/{clientId}
  Future<Object?> getClientOrders(int clientId) => _send(
    () => _client.get(
      _uri('/api/v1/orders/client/$clientId'),
      headers: _headers,
    ),
  );

  /// GET /api/v1/orders/{id}
  Future<Object?> getOrder(int orderId) => _send(
    () => _client.get(_uri('/api/v1/orders/$orderId'), headers: _headers),
  );

  /// POST /api/v1/orders — CreateOrderResource
  Future<Object?> createOrder(Map<String, Object?> body) => _send(
    () => _client.post(
      _uri('/api/v1/orders'),
      headers: _headers,
      body: jsonEncode(body),
    ),
  );

  /// PUT /api/v1/orders/{id} — UpdateOrderResource
  Future<Object?> updateOrder(int orderId, Map<String, Object?> body) => _send(
    () => _client.put(
      _uri('/api/v1/orders/$orderId'),
      headers: _headers,
      body: jsonEncode(body),
    ),
  );

  /// PATCH /api/v1/orders/{id}/cancel — CancelOrderResource
  Future<Object?> cancelOrder(int orderId, Map<String, Object?> body) => _send(
    () => _client.patch(
      _uri('/api/v1/orders/$orderId/cancel'),
      headers: _headers,
      body: jsonEncode(body),
    ),
  );

  /// GET /api/v1/producers
  Future<Object?> getProducers() => _send(
    () => _client.get(_uri('/api/v1/producers'), headers: _headers),
  );

  /// Existing Flutter catalog route. It is NOT present in the attached
  /// OpenAPI specification; a 404 is surfaced rather than silently replaced
  /// with demo products.
  Future<Object?> getProducts({bool available = true}) => _send(
    () => _client.get(
      _uri('/api/v1/products').replace(
        queryParameters: {'available': available.toString()},
      ),
      headers: _headers,
    ),
  );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on OrderApiException {
      rethrow;
    } on TimeoutException {
      throw const OrderApiException(OrderApiFailure.network);
    } on http.ClientException {
      throw const OrderApiException(OrderApiFailure.network);
    } catch (error) {
      throw OrderApiException(OrderApiFailure.network, error.toString());
    }

    final code = response.statusCode;
    if (code < 200 || code >= 300) {
      final message = apiErrorMessage(response.body);
      final reason = switch (code) {
        400 || 422 => OrderApiFailure.invalid,
        401 => OrderApiFailure.unauthorized,
        403 => OrderApiFailure.forbidden,
        404 => OrderApiFailure.notFound,
        409 => OrderApiFailure.conflict,
        >= 500 => OrderApiFailure.server,
        _ => OrderApiFailure.unexpectedResponse,
      };
      throw OrderApiException(reason, message);
    }

    if (response.bodyBytes.isEmpty) return null;
    try {
      final text = utf8.decode(response.bodyBytes).trim();
      return text.isEmpty ? null : jsonDecode(text);
    } on FormatException {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
  }

  void close() => _client.close();
}
