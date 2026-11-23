import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum QualityApiFailure { network, unauthorized, notFound, server, unexpectedResponse }

class QualityApiException implements Exception {
  const QualityApiException(this.reason, [this.message]);

  final QualityApiFailure reason;

  /// Message returned by the backend, when present.
  final String? message;

  @override
  String toString() =>
      'QualityApiException($reason${message == null ? '' : ': $message'})';
}

/// HTTP client of the Quality Management endpoints. Every call carries the
/// IAM JWT.
class FruitLogixQualityApi {
  FruitLogixQualityApi({
    required String Function() token,
    http.Client? client,
    Uri? baseUri,
  })  : _token = token,
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

  /// `GET /api/v1/incidents`
  Future<Object?> getIncidents() => _send(
        () => _client.get(_baseUri.resolve('/api/v1/incidents'), headers: _headers),
      );

  /// `POST /api/v1/incidents` — `{ batchId, description, evidenceUrls }`.
  Future<Object?> createIncident({
    required int batchId,
    required String description,
    List<String> evidenceUrls = const [],
  }) =>
      _send(
        () => _client.post(
          _baseUri.resolve('/api/v1/incidents'),
          headers: _headers,
          body: jsonEncode({
            'batchId': batchId,
            'description': description,
            'evidenceUrls': evidenceUrls,
          }),
        ),
      );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const QualityApiException(QualityApiFailure.network);
    } on http.ClientException {
      throw const QualityApiException(QualityApiFailure.network);
    } catch (error) {
      // SocketException/HandshakeException (dart:io is not used so the
      // client also compiles for the web).
      throw QualityApiException(QualityApiFailure.network, '$error');
    }

    final code = response.statusCode;
    if (code == 401 || code == 403) {
      throw const QualityApiException(QualityApiFailure.unauthorized);
    }
    if (code == 404) throw const QualityApiException(QualityApiFailure.notFound);
    // The IAM middleware throws on a missing/invalid token, which surfaces
    // as a 500 with an "invalid token" message.
    if (code >= 500 && response.body.toLowerCase().contains('token')) {
      throw const QualityApiException(QualityApiFailure.unauthorized);
    }
    if (code < 200 || code >= 300) {
      throw QualityApiException(
        code >= 500 ? QualityApiFailure.server : QualityApiFailure.unexpectedResponse,
        _messageOf(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const QualityApiException(QualityApiFailure.unexpectedResponse);
    }
  }

  static String? _messageOf(String body) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['message'] is String) {
        return decoded['message'] as String;
      }
      if (decoded is Map && decoded['title'] is String) {
        return decoded['title'] as String;
      }
    } on FormatException {
      return null;
    }
    return null;
  }

  void close() => _client.close();
}
