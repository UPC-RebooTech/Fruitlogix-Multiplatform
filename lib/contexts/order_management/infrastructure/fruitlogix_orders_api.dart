import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/api_errors.dart';
import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum OrderApiFailure {
  network,
  unauthorized,
  notFound,

  /// 409: the current state does not allow it (e.g. reception of an order
  /// that is not in transit, not enough stock, too many photos).
  conflict,

  /// 403: the client's role cannot do this action.
  forbidden,
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

  /// `GET /api/v1/producers` — names for the history producer filter.
  Future<Object?> getProducers() => _send(
    () => _client.get(_baseUri.resolve('/api/v1/producers'), headers: _headers),
  );

  /// `GET /api/v1/products?available=true` — the catalog (active products
  /// with stock).
  Future<Object?> getProducts({bool available = true}) => _send(
    () => _client.get(
      _baseUri
          .resolve('/api/v1/products')
          .replace(queryParameters: {'available': '$available'}),
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
    // 401: missing, invalid or expired token (the shell signs out).
    if (code == 401) {
      throw const OrderApiException(OrderApiFailure.unauthorized);
    }
    // A client without orders may get a 404 instead of an empty list.
    // 404: it does not exist or it is not the user's.
    if (code == 409 || code == 403) {
      throw OrderApiException(
        code == 409 ? OrderApiFailure.conflict : OrderApiFailure.forbidden,
        apiErrorMessage(response.body),
      );
    }
    if (code == 404) {
      throw OrderApiException(
        OrderApiFailure.notFound,
        apiErrorMessage(response.body),
      );
    }
    if (code == 400 || code == 422) {
      throw OrderApiException(
        OrderApiFailure.invalid,
        apiErrorMessage(response.body),
      );
    }
    if (code < 200 || code >= 300) {
      throw OrderApiException(
        code >= 500
            ? OrderApiFailure.server
            : OrderApiFailure.unexpectedResponse,
        apiErrorMessage(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const OrderApiException(OrderApiFailure.unexpectedResponse);
    }
  }

  void close() => _client.close();
}
