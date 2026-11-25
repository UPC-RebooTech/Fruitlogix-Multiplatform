import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/api_errors.dart';
import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum LogisticsApiFailure {
  network,
  unauthorized,
  notFound,

  /// 409: the current state does not allow it (e.g. reception of an order
  /// that is not in transit, not enough stock, too many photos).
  conflict,

  /// 403: the client's role cannot do this action.
  forbidden,
  server,
  unexpectedResponse,
}

class LogisticsApiException implements Exception {
  const LogisticsApiException(this.reason, [this.message]);

  final LogisticsApiFailure reason;
  final String? message;

  @override
  String toString() =>
      'LogisticsApiException($reason${message == null ? '' : ': $message'})';
}

/// HTTP client of the Logistics & Monitoring endpoints. Every call carries
/// the IAM JWT.
class FruitLogixLogisticsApi {
  FruitLogixLogisticsApi({
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
    'Authorization': 'Bearer ${_token()}',
  };

  /// `GET /api/v1/deliveries` — the client's deliveries (filtered by the
  /// platform with the JWT).
  Future<Object?> getDeliveries() => _send(
    () =>
        _client.get(_baseUri.resolve('/api/v1/deliveries'), headers: _headers),
  );

  /// `GET /api/v1/tracking-logs?deliveryId={id}`
  Future<Object?> getTrackingLogs(int deliveryId) => _send(
    () => _client.get(
      _baseUri
          .resolve('/api/v1/tracking-logs')
          .replace(queryParameters: {'deliveryId': '$deliveryId'}),
      headers: _headers,
    ),
  );

  /// `GET /api/v1/deliveries/{id}/events` — milestones and checkpoints.
  Future<Object?> getDeliveryEvents(int deliveryId) => _send(
    () => _client.get(
      _baseUri.resolve('/api/v1/deliveries/$deliveryId/events'),
      headers: _headers,
    ),
  );

  /// `GET /api/v1/deliveries/arrivals?since=` — arrivals at the client's
  /// warehouse (geofence or manual), newest first.
  Future<Object?> getArrivals({DateTime? since}) => _send(
    () => _client.get(
      _baseUri
          .resolve('/api/v1/deliveries/arrivals')
          .replace(
            queryParameters: since == null
                ? null
                : {'since': since.toUtc().toIso8601String()},
          ),
      headers: _headers,
    ),
  );

  /// `GET /api/v1/orders/{id}/traceability` — harvest → inspection →
  /// dispatch → reception → invoice (US72).
  Future<Object?> getTraceability(int orderId) => _send(
    () => _client.get(
      _baseUri.resolve('/api/v1/orders/$orderId/traceability'),
      headers: _headers,
    ),
  );

  /// `GET /api/v1/profiles/me` — the client's profile, with `warehouse`
  /// (US65). 404 while the client has not created it.
  Future<Object?> getMyProfile() => _send(
    () => _client.get(_baseUri.resolve('/api/v1/profiles/me'), headers: _headers),
  );

  /// `PUT /api/v1/profiles/me/warehouse` — `{ latitude, longitude, radiusKm }`.
  Future<Object?> putWarehouse(Map<String, Object?> body) => _send(
    () => _client.put(
      _baseUri.resolve('/api/v1/profiles/me/warehouse'),
      headers: {..._headers, 'Content-Type': 'application/json'},
      body: jsonEncode(body),
    ),
  );

  /// `POST /api/v1/orders/{orderId}/reception` —
  /// `{ rating?, comment, hasIncidence, sealAndTemperatureOk }`.
  Future<Object?> confirmReception(int orderId, Map<String, Object?> body) =>
      _send(
        () => _client.post(
          _baseUri.resolve('/api/v1/orders/$orderId/reception'),
          headers: {..._headers, 'Content-Type': 'application/json'},
          body: jsonEncode(body),
        ),
      );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const LogisticsApiException(LogisticsApiFailure.network);
    } on http.ClientException {
      throw const LogisticsApiException(LogisticsApiFailure.network);
    } catch (error) {
      // SocketException/HandshakeException without importing dart:io (web).
      throw LogisticsApiException(LogisticsApiFailure.network, '$error');
    }

    final code = response.statusCode;
    // 401: missing, invalid or expired token (the shell signs out).
    if (code == 401) {
      throw const LogisticsApiException(LogisticsApiFailure.unauthorized);
    }
    // 404: it does not exist or it is not the user's.
    if (code == 409 || code == 403) {
      throw LogisticsApiException(
        code == 409 ? LogisticsApiFailure.conflict : LogisticsApiFailure.forbidden,
        apiErrorMessage(response.body),
      );
    }
    if (code == 404) {
      throw LogisticsApiException(
        LogisticsApiFailure.notFound,
        apiErrorMessage(response.body),
      );
    }
    if (code < 200 || code >= 300) {
      throw LogisticsApiException(
        code >= 500
            ? LogisticsApiFailure.server
            : LogisticsApiFailure.unexpectedResponse,
        apiErrorMessage(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const LogisticsApiException(LogisticsApiFailure.unexpectedResponse);
    }
  }

  void close() => _client.close();
}
