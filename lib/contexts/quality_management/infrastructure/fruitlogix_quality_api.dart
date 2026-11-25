import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart' as http_parser;

import '../../../shared/infrastructure/api_errors.dart';
import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum QualityApiFailure {
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

  /// `GET /api/v1/incidents`
  Future<Object?> getIncidents() => _send(
    () => _client.get(_baseUri.resolve('/api/v1/incidents'), headers: _headers),
  );

  /// `POST /api/v1/files` — one image (`file`, JPG/PNG/WEBP, up to 5 MB).
  /// Returns `{ url, fileName, sizeBytes, contentType }`.
  Future<Object?> uploadImage(List<int> bytes, {required String fileName}) =>
      _send(() async {
        final type = imageContentType(bytes);
        final request =
            http.MultipartRequest('POST', _baseUri.resolve('/api/v1/files'))
              ..headers.addAll({
                'Accept': 'application/json',
                'Authorization': 'Bearer ${_token()}',
              })
              ..files.add(
                http.MultipartFile.fromBytes(
                  'file',
                  bytes,
                  filename: '$fileName.${type.extension}',
                  contentType: http_parser.MediaType('image', type.subtype),
                ),
              );
        return http.Response.fromStream(await _client.send(request));
      });

  /// Type from the first bytes (the platform checks that the name, the
  /// declared type and the content match). Photos are JPEG by default.
  static ({String subtype, String extension}) imageContentType(
    List<int> bytes,
  ) {
    bool starts(List<int> magic, [int offset = 0]) {
      if (bytes.length < offset + magic.length) return false;
      for (var i = 0; i < magic.length; i++) {
        if (bytes[offset + i] != magic[i]) return false;
      }
      return true;
    }
    if (starts(const [0x89, 0x50, 0x4E, 0x47])) {
      return (subtype: 'png', extension: 'png');
    }
    if (starts(const [0x52, 0x49, 0x46, 0x46]) &&
        starts(const [0x57, 0x45, 0x42, 0x50], 8)) {
      return (subtype: 'webp', extension: 'webp');
    }
    return (subtype: 'jpeg', extension: 'jpg');
  }

  /// `POST /api/v1/incidents` —
  /// `{ batchId, orderId?, description, evidenceUrls }` (up to 5 URLs).
  Future<Object?> createIncident({
    required int batchId,
    required String description,
    int? orderId,
    List<String> evidenceUrls = const [],
  }) => _send(
    () => _client.post(
      _baseUri.resolve('/api/v1/incidents'),
      headers: _headers,
      body: jsonEncode({
        'batchId': batchId,
        'orderId': ?orderId,
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
    // 401: missing, invalid or expired token (the shell signs out).
    if (code == 401) {
      throw const QualityApiException(QualityApiFailure.unauthorized);
    }
    // 404: it does not exist or it is not the user's.
    if (code == 409 || code == 403) {
      throw QualityApiException(
        code == 409 ? QualityApiFailure.conflict : QualityApiFailure.forbidden,
        apiErrorMessage(response.body),
      );
    }
    if (code == 404) {
      throw QualityApiException(
        QualityApiFailure.notFound,
        apiErrorMessage(response.body),
      );
    }
    if (code < 200 || code >= 300) {
      throw QualityApiException(
        code >= 500
            ? QualityApiFailure.server
            : QualityApiFailure.unexpectedResponse,
        apiErrorMessage(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const QualityApiException(QualityApiFailure.unexpectedResponse);
    }
  }

  void close() => _client.close();
}
