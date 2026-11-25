import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/auth_session.dart';
import 'fruitlogix_auth_api.dart';

/// App-level session. Persistent JWTs are kept in platform secure storage.
/// A session without 'remember' stays in memory only.
class AuthSessionController extends ChangeNotifier {
  AuthSessionController({
    FruitLogixAuthApi? api,
    FlutterSecureStorage? storage,
  })  : _api = api ?? FruitLogixAuthApi(),
        _storage = storage ?? const FlutterSecureStorage();

  static const _sessionKey = 'fruitlogix_iam_session_v1';

  final FruitLogixAuthApi _api;
  final FlutterSecureStorage _storage;
  AuthSession? _session;

  AuthSession? get session {
    if (_session?.isExpired == true) return null;
    return _session;
  }

  Future<void> restore() async {
    try {
      final saved = await _storage.read(key: _sessionKey);
      if (saved == null) return;
      final data = jsonDecode(saved);
      if (data is! Map<String, dynamic>) {
        await _storage.delete(key: _sessionKey);
        return;
      }
      final restored = AuthSession.fromJson(data);
      if (restored.isExpired) {
        await _storage.delete(key: _sessionKey);
        return;
      }
      _session = restored;
      notifyListeners();
    } catch (_) {
      // Inaccessible/invalid secure store: require a new sign-in.
      _session = null;
      notifyListeners();
    }
  }

  Future<void> _activate(AuthSession next, {required bool remember}) async {
    if (remember) {
      try {
        await _storage.write(key: _sessionKey, value: jsonEncode(next.toJson()));
      } catch (_) {
        // Continue in memory only if secure storage is unavailable.
      }
    } else {
      try {
        await _storage.delete(key: _sessionKey);
      } catch (_) {
        // No persistent session requested.
      }
    }
    _session = next;
    notifyListeners();
  }

  Future<AuthSession> signIn({
    required String username,
    required String password,
    required bool remember,
  }) async {
    final next = await _api.signIn(username: username, password: password);
    await _activate(next, remember: remember);
    return next;
  }

  /// Registration creates a backend account, signs in to obtain a JWT, and
  /// stores local profile data BEFORE making the session visible to the app.
  Future<AuthSession> register({
    required String username,
    required String password,
    required bool remember,
    required Future<void> Function(AuthSession session) saveLocalProfile,
  }) async {
    await _api.signUp(username: username, password: password);
    final next = await _api.signIn(username: username, password: password);
    await saveLocalProfile(next);
    await _activate(next, remember: remember);
    return next;
  }

  Future<void> signOut() async {
    _session = null;
    notifyListeners();
    try {
      await _storage.delete(key: _sessionKey);
    } catch (_) {
      // Even if the secure store cannot be read, the in-memory session ends.
    }
  }

  bool _expired = false;

  /// The platform answered 401 (token expired, revoked or user deleted):
  /// back to the login, which tells the client why once.
  Future<void> expire() async {
    if (_session == null) return;
    _expired = true;
    await signOut();
  }

  /// True once after [expire].
  bool consumeExpiredNotice() {
    final expired = _expired;
    _expired = false;
    return expired;
  }

  @override
  void dispose() {
    _api.close();
    super.dispose();
  }
}
