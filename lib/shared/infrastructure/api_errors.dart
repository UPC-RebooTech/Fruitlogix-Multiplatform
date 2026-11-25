import 'dart:convert';

import 'package:http/http.dart' as http;

/// Readable message of an API error body. The platform answers in three
/// shapes: `{ "message": ... }`, a JSON string (older 404s) or ProblemDetails
/// (`detail`/`title`, or `errors: { field: [..] }` for validation).
/// Order: message → first validation error → detail → string → title.
String? apiErrorMessage(String body) {
  final Object? decoded;
  try {
    decoded = jsonDecode(body);
  } on FormatException {
    return null;
  }
  if (decoded is String) return decoded.trim().isEmpty ? null : decoded;
  if (decoded is! Map) return null;
  String? text(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
  if (text(decoded['message']) case final message?) return message;
  final errors = decoded['errors'];
  if (errors is Map) {
    for (final value in errors.values) {
      if (value is List && value.isNotEmpty) return '${value.first}';
      if (text(value) case final message?) return message;
    }
  }
  return text(decoded['detail']) ?? text(decoded['title']);
}

/// Shared HTTP client of a signed-in session: reports a 401 (missing,
/// invalid or expired token, or a deleted user) so the app can sign out and
/// return to the login. A 403 is not reported: it means the role cannot do
/// that action, not that the session ended.
class SessionGuardClient extends http.BaseClient {
  SessionGuardClient({required this.onUnauthorized, http.Client? inner})
    : _inner = inner ?? http.Client();

  final void Function() onUnauthorized;
  final http.Client _inner;
  bool _reported = false;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final response = await _inner.send(request);
    if (response.statusCode == 401 && !_reported) {
      _reported = true;
      onUnauthorized();
    }
    return response;
  }

  /// Several API clients share this one; each of them calls [close] on
  /// dispose, so only [dispose] really closes the connection.
  @override
  void close() {}

  void dispose() => _inner.close();
}
