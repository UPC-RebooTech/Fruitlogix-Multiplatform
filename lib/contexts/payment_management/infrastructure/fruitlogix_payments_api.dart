import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/api_errors.dart';
import '../../../shared/infrastructure/fruitlogix_api_config.dart';

enum PaymentApiFailure {
  network,
  unauthorized,
  notFound,
  server,
  unexpectedResponse,
}

class PaymentApiException implements Exception {
  const PaymentApiException(this.reason, [this.message]);
  final PaymentApiFailure reason;

  /// Message returned by the backend (e.g. a Stripe error), when present.
  final String? message;

  @override
  String toString() =>
      'PaymentApiException($reason${message == null ? '' : ': $message'})';
}

/// HTTP client of the Payment Management endpoints. Every call carries the
/// IAM JWT (the backend middleware rejects requests without it).
class FruitLogixPaymentsApi {
  FruitLogixPaymentsApi({
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

  /// `GET /api/v1/invoices`
  Future<Object?> getInvoices() => _send(
    () => _client.get(_baseUri.resolve('/api/v1/invoices'), headers: _headers),
  );

  /// `GET /api/v1/memberships/me`
  Future<Object?> getMyMembership() => _send(
    () => _client.get(
      _baseUri.resolve('/api/v1/memberships/me'),
      headers: _headers,
    ),
  );

  /// `POST /api/v1/payments/subscribe`
  Future<Object?> subscribe({
    required String email,
    required String name,
    required String planType,
  }) => _send(
    () => _client.post(
      _baseUri.resolve('/api/v1/payments/subscribe'),
      headers: _headers,
      body: jsonEncode({'email': email, 'name': name, 'planType': planType}),
    ),
  );

  Future<Object?> _send(Future<http.Response> Function() request) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on SocketException {
      throw const PaymentApiException(PaymentApiFailure.network);
    } on TimeoutException {
      throw const PaymentApiException(PaymentApiFailure.network);
    } on HandshakeException {
      throw const PaymentApiException(PaymentApiFailure.network);
    } on http.ClientException {
      throw const PaymentApiException(PaymentApiFailure.network);
    }

    final code = response.statusCode;
    // 401: missing, invalid or expired token (the shell signs out).
    if (code == 401) {
      throw const PaymentApiException(PaymentApiFailure.unauthorized);
    }
    // 404: it does not exist or it is not the user's.
    if (code == 404) {
      throw PaymentApiException(
        PaymentApiFailure.notFound,
        apiErrorMessage(response.body),
      );
    }
    if (code < 200 || code >= 300) {
      throw PaymentApiException(
        code >= 500
            ? PaymentApiFailure.server
            : PaymentApiFailure.unexpectedResponse,
        apiErrorMessage(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const PaymentApiException(PaymentApiFailure.unexpectedResponse);
    }
  }

  void close() => _client.close();
}
