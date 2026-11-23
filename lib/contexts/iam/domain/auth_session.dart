import 'dart:convert';

/// Identity returned by the FruitLogix IAM API. No password is stored here.
class AuthSession {
  const AuthSession({
    required this.userId,
    required this.username,
    required this.token,
  });

  final int userId;
  final String username;
  final String token;

  /// Client-side expiration check only. The backend remains the authority.
  bool get isExpired {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final json = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final claims = jsonDecode(json);
      if (claims is! Map<String, dynamic>) return true;
      final exp = claims['exp'];
      if (exp is! num) return true;
      final expiry = DateTime.fromMillisecondsSinceEpoch(
        exp.toInt() * 1000,
        isUtc: true,
      );
      return !expiry.isAfter(DateTime.now().toUtc());
    } catch (_) {
      return true;
    }
  }

  Map<String, dynamic> toJson() => {
        'userId': userId,
        'username': username,
        'token': token,
      };

  factory AuthSession.fromJson(Map<String, dynamic> value) {
    final id = value['userId'];
    final username = value['username'];
    final token = value['token'];
    if (id is! int || id <= 0 || username is! String || username.isEmpty ||
        token is! String || token.isEmpty) {
      throw const FormatException('Malformed stored session');
    }
    return AuthSession(userId: id, username: username, token: token);
  }
}
