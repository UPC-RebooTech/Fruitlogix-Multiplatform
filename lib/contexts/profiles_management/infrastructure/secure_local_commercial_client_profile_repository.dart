import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../domain/commercial_client_profile.dart';
import '../domain/commercial_client_profile_repository.dart';

/// Device-only profile data, kept separately for each authenticated IAM user.
/// It does NOT sync contact details or RUC with the backend.
class SecureLocalCommercialClientProfileRepository
    implements CommercialClientProfileRepository {
  SecureLocalCommercialClientProfileRepository._(
      this._storage,
      this._key,
      this._current,
      );

  final FlutterSecureStorage _storage;
  final String _key;
  CommercialClientProfile _current;

  static Future<SecureLocalCommercialClientProfileRepository> open({
    required int userId,
    required String username,
    FlutterSecureStorage storage = const FlutterSecureStorage(),
  }) async {
    if (userId <= 0 || username.trim().isEmpty) {
      throw ArgumentError('Invalid IAM identity');
    }
    final profileId = 'iam-user-$userId';
    final key = 'fruitlogix_commercial_profile_v1_$userId';
    final raw = await storage.read(key: key);

    // Username is only an initial display alias, NOT a verified full name.
    CommercialClientProfile profile = CommercialClientProfile(
      id: profileId,
      fullName: username.trim(),
      businessName: '',
      email: '',
      phone: '',
      taxId: '',
    );

    if (raw != null) {
      final decoded = jsonDecode(raw);
      if (decoded is! Map<String, dynamic> || decoded['id'] != profileId) {
        throw const FormatException('Invalid locally stored profile identity');
      }
      String field(String name) {
        final value = decoded[name];
        if (value is! String) {
          throw FormatException('Invalid stored profile field: $name');
        }
        return value;
      }
      final saved = CommercialClientProfile(
        id: profileId,
        fullName: field('fullName'),
        businessName: field('businessName'),
        email: field('email'),
        phone: field('phone'),
        taxId: field('taxId'),
      );
      if (!saved.isValid) {
        throw const FormatException('Invalid locally stored profile values');
      }
      profile = saved;
    }

    return SecureLocalCommercialClientProfileRepository._(
      storage,
      key,
      profile,
    );
  }

  @override
  bool get isPersistent => true;

  @override
  CommercialClientProfile get current => _current;

  @override
  Future<void> save(CommercialClientProfile profile) async {
    if (!profile.isValid) {
      throw ArgumentError('Invalid commercial client profile');
    }
    if (profile.id != _current.id) {
      throw ArgumentError('Cannot change profile identity');
    }
    await _storage.write(
      key: _key,
      value: jsonEncode({
        'id': profile.id,
        'fullName': profile.fullName,
        'businessName': profile.businessName,
        'email': profile.email,
        'phone': profile.phone,
        'taxId': profile.taxId,
      }),
    );
    // Update UI only AFTER secure storage confirms the write.
    _current = profile;
  }
}
