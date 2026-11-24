import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum LogisticsApiFailure {
  network,
  unauthorized,
  notFound,
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

  /// `GET /api/v1/deliveries` — every delivery (not filtered by client).
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
    if (code == 401 || code == 403) {
      throw const LogisticsApiException(LogisticsApiFailure.unauthorized);
    }
    if (code == 404) {
      throw const LogisticsApiException(LogisticsApiFailure.notFound);
    }
    // The IAM middleware throws on a missing/invalid token (500 + "token").
    if (code >= 500 && response.body.toLowerCase().contains('token')) {
      throw const LogisticsApiException(LogisticsApiFailure.unauthorized);
    }
    if (code < 200 || code >= 300) {
      throw LogisticsApiException(
        code >= 500
            ? LogisticsApiFailure.server
            : LogisticsApiFailure.unexpectedResponse,
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
