import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum OrderApiFailure {
  network,
  unauthorized,
  notFound,
  invalid,
  server,
  unexpectedResponse,
}

class OrderApiException implements Exception {
  const OrderApiException(this.reason, [this.message]);

  final OrderApiFailure reason;

  /// Message returned by the backend (validation errors), when present.
  final String? message;

  @override
  String toString() =>
      'OrderApiException($reason${message == null ? '' : ': $message'})';
}

/// HTTP client of the Order Management endpoints. Every call carries the
/// IAM JWT.
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

  /// Render free instances can take a while to wake up.
  static const Duration _timeout = Duration(seconds: 60);

  Map<String, String> get _headers => {
    'Accept': 'application/json',
    'Content-Type': 'application/json',
    'Authorization': 'Bearer ${_token()}',
  };

  /// `GET /api/v1/orders/client/{clientId}`
  Future<Object?> getClientOrders(int clientId) => _send(
    () => _client.get(
      _baseUri.resolve('/api/v1/orders/client/$clientId'),
      headers: _headers,
    ),
  );

  /// `POST /api/v1/orders` — `CreateOrderResource`.
  Future<Object?> createOrder(Map<String, Object?> body) => _send(
    () => _client.post(
      _baseUri.resolve('/api/v1/orders'),
      headers: _headers,
      body: jsonEncode(body),
    ),
  );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const OrderApiException(OrderApiFailure.network);
    } on http.ClientException {
      throw const OrderApiException(OrderApiFailure.network);
    } catch (error) {
      // SocketException/HandshakeException (dart:io is not imported so the
      // client also compiles for the web).
      throw OrderApiException(OrderApiFailure.network, '$error');
    }

    final code = response.statusCode;
    if (code == 401 || code == 403) {
      throw const OrderApiException(OrderApiFailure.unauthorized);
    }
    // A client without orders may get a 404 instead of an empty list.
    if (code == 404) throw const OrderApiException(OrderApiFailure.notFound);
    // The IAM middleware throws on a missing/invalid token, which surfaces
    // as a 500 with an "invalid token" message.
    if (code >= 500 && response.body.toLowerCase().contains('token')) {
      throw const OrderApiException(OrderApiFailure.unauthorized);
    }
    if (code == 400 || code == 422) {
      throw OrderApiException(
        OrderApiFailure.invalid,
        _messageOf(response.body),
      );
    }
    if (code < 200 || code >= 300) {
      throw OrderApiException(
        code >= 500
            ? OrderApiFailure.server
            : OrderApiFailure.unexpectedResponse,
        _messageOf(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
  }

  /// `message`, the first validation error (more useful than the generic
  /// ProblemDetails title "One or more validation errors occurred."),
  /// then `detail`/`title`.
  static String? _messageOf(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is! Map) return null;
      if (decoded['message'] is String) return decoded['message'] as String;
      final errors = decoded['errors'];
      if (errors is Map && errors.isNotEmpty) {
        final first = errors.values.first;
        if (first is List && first.isNotEmpty) return '${first.first}';
      }
      for (final key in ['detail', 'title']) {
        if (decoded[key] is String) return decoded[key] as String;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  void close() => _client.close();
}
