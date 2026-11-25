import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../domain/auth_session.dart';

enum AuthFailure {
  invalidCredentials,
  usernameTakenOrInvalid,

  /// The account is a Producer or Distributor (they use the Kotlin app).
  wrongRole,
  network,
  server,
  unexpectedResponse,
}

class AuthApiException implements Exception {
  const AuthApiException(this.reason);
  final AuthFailure reason;
}

/// IAM-only calls. Uses the deployed Render API, not a localhost endpoint.
class FruitLogixAuthApi {
  FruitLogixAuthApi({http.Client? client, Uri? baseUri})
    : _client = client ?? http.Client(),
      _baseUri =
          baseUri ?? Uri.parse('https://rebootech-fruitlogix-api.onrender.com');

  final http.Client _client;
  final Uri _baseUri;

  Uri _endpoint(String path) =>
      _baseUri.resolve('/api/v1/authentication/$path');

  Future<http.Response> _post(String path, Map<String, String> body) async {
    try {
      return await _client
          .post(
            _endpoint(path),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 60));
    } on SocketException {
      throw const AuthApiException(AuthFailure.network);
    } on TimeoutException {
      throw const AuthApiException(AuthFailure.network);
    } on http.ClientException {
      throw const AuthApiException(AuthFailure.network);
    } on HandshakeException {
      throw const AuthApiException(AuthFailure.network);
    }
  }

  Future<void> signUp({
    required String username,
    required String password,
  }) async {
    final response = await _post('sign-up', {
      'username': username.trim(),
      'password': password,
      // This app registers commercial clients only.
      'role': AuthSession.commercialClientRole,
    });
    if (response.statusCode == 200) return;
    if (response.statusCode == 400 || response.statusCode == 409) {
      throw const AuthApiException(AuthFailure.usernameTakenOrInvalid);
    }
    throw const AuthApiException(AuthFailure.server);
  }

  Future<AuthSession> signIn({
    required String username,
    required String password,
  }) async {
    final response = await _post('sign-in', {
      'username': username.trim(),
      'password': password,
    });
    if (response.statusCode == 400 || response.statusCode == 401) {
      throw const AuthApiException(AuthFailure.invalidCredentials);
    }
    if (response.statusCode != 200) {
      throw const AuthApiException(AuthFailure.server);
    }
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic>) {
        throw const FormatException('Unexpected IAM response type');
      }
      final id = decoded['id'];
      final apiUsername = decoded['username'];
      final token = decoded['token'];
      final role = decoded['role'];
      if (id is! int ||
          id <= 0 ||
          apiUsername is! String ||
          apiUsername.isEmpty ||
          token is! String ||
          token.isEmpty) {
        throw const FormatException('Missing IAM fields');
      }
      final session = AuthSession(
        userId: id,
        username: apiUsername,
        token: token,
        role: role is String && role.isNotEmpty
            ? role
            : AuthSession.commercialClientRole,
      );
      if (!session.isCommercialClient) {
        throw const AuthApiException(AuthFailure.wrongRole);
      }
      if (session.isExpired) {
        throw const FormatException('Invalid or expired JWT');
      }
      return session;
    } on FormatException {
      throw const AuthApiException(AuthFailure.unexpectedResponse);
    } on TypeError {
      throw const AuthApiException(AuthFailure.unexpectedResponse);
    }
  }

  void close() => _client.close();
}
