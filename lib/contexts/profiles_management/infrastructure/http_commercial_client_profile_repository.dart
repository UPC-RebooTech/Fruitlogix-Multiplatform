import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../shared/infrastructure/api_errors.dart';
import '../../../shared/infrastructure/fruitlogix_api_config.dart';
import '../domain/commercial_client_profile.dart';
import '../domain/commercial_client_profile_repository.dart';

enum ProfileApiFailure { network, unauthorized, invalid, server, unexpectedResponse }

class ProfileApiException implements Exception {
  const ProfileApiException(this.reason, [this.message]);

  final ProfileApiFailure reason;

  /// Validation message of the platform (e.g. RUC of 11 digits).
  final String? message;

  @override
  String toString() =>
      'ProfileApiException($reason${message == null ? '' : ': $message'})';
}

/// Commercial Client profile in the platform (`GET`/`PUT /profiles/me`).
///
/// App ↔ API: `fullName` ↔ `contactName`, `taxId` ↔ `ruc`. The address and
/// the warehouse (US65) are not edited here: the address is sent back as it
/// was and `warehouse` is omitted so the platform keeps it.
class HttpCommercialClientProfileRepository
    implements CommercialClientProfileRepository {
  HttpCommercialClientProfileRepository._(
    this._client,
    this._baseUri,
    this._token,
    this._current,
    this._address,
  );

  final http.Client _client;
  final Uri _baseUri;
  final String Function() _token;
  CommercialClientProfile _current;
  String _address;

  static const Duration _timeout = Duration(seconds: 60);

  /// Loads the profile. A 404 (not created yet) opens an empty form,
  /// prefilled with [fallback] (e.g. what this phone kept before the profile
  /// lived in the platform) so the client only has to save it.
  static Future<HttpCommercialClientProfileRepository> open({
    required int userId,
    required String username,
    required String Function() token,
    http.Client? client,
    Uri? baseUri,
    CommercialClientProfile? fallback,
  }) async {
    final http.Client httpClient = client ?? http.Client();
    final uri = baseUri ?? Uri.parse(fruitLogixApiUrl);
    final id = 'iam-user-$userId';
    final body = await _send(
      () => httpClient.get(
        uri.resolve('/api/v1/profiles/me'),
        headers: _headers(token()),
      ),
      notFoundIsEmpty: true,
    );
    final CommercialClientProfile profile;
    var address = '';
    if (body is Map) {
      profile = fromJson(body, id: id);
      address = _text(body['address']);
    } else {
      profile = CommercialClientProfile(
        id: id,
        fullName: fallback?.fullName ?? username.trim(),
        businessName: fallback?.businessName ?? '',
        email: fallback?.email ?? '',
        phone: fallback?.phone ?? '',
        taxId: fallback?.taxId ?? '',
      );
    }
    return HttpCommercialClientProfileRepository._(
      httpClient,
      uri,
      token,
      profile,
      address,
    );
  }

  static CommercialClientProfile fromJson(
    Map<dynamic, dynamic> json, {
    required String id,
  }) => CommercialClientProfile(
    id: id,
    fullName: _text(json['contactName']),
    businessName: _text(json['businessName']),
    email: _text(json['email']),
    phone: _text(json['phone']),
    taxId: _text(json['ruc']),
  );

  /// `PUT /profiles/me` replaces every field, so all are sent.
  static Map<String, Object?> toJson(
    CommercialClientProfile profile, {
    required String address,
  }) => {
    'businessName': profile.businessName.trim(),
    'ruc': profile.taxId.trim(),
    'contactName': profile.fullName.trim(),
    'email': profile.email.trim(),
    'phone': profile.phone.trim(),
    'address': address,
  };

  @override
  CommercialClientProfile get current => _current;

  @override
  bool get isPersistent => true;

  @override
  bool get syncsWithPlatform => true;

  @override
  Future<void> save(CommercialClientProfile profile) async {
    if (!profile.isValid) {
      throw ArgumentError('Invalid commercial client profile');
    }
    if (profile.id != _current.id) {
      throw ArgumentError('Cannot change profile identity');
    }
    final body = await _send(
      () => _client.put(
        _baseUri.resolve('/api/v1/profiles/me'),
        headers: {
          ..._headers(_token()),
          'Content-Type': 'application/json',
        },
        body: jsonEncode(toJson(profile, address: _address)),
      ),
    );
    // Update the UI only once the platform accepted it.
    _current = body is Map ? fromJson(body, id: profile.id) : profile;
    if (body is Map) _address = _text(body['address']);
  }

  static Map<String, String> _headers(String token) => {
    'Accept': 'application/json',
    'Authorization': 'Bearer $token',
  };

  static Future<Object?> _send(
    Future<http.Response> Function() request, {
    bool notFoundIsEmpty = false,
  }) async {
    final http.Response response;
    try {
      response = await request().timeout(_timeout);
    } on TimeoutException {
      throw const ProfileApiException(ProfileApiFailure.network);
    } on http.ClientException {
      throw const ProfileApiException(ProfileApiFailure.network);
    } catch (error) {
      throw ProfileApiException(ProfileApiFailure.network, '$error');
    }
    final code = response.statusCode;
    if (code == 401) {
      throw const ProfileApiException(ProfileApiFailure.unauthorized);
    }
    if (code == 404 && notFoundIsEmpty) return null;
    if (code == 400) {
      throw ProfileApiException(
        ProfileApiFailure.invalid,
        apiErrorMessage(response.body),
      );
    }
    if (code < 200 || code >= 300) {
      throw ProfileApiException(
        code >= 500
            ? ProfileApiFailure.server
            : ProfileApiFailure.unexpectedResponse,
        apiErrorMessage(response.body),
      );
    }
    if (response.body.trim().isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      throw const ProfileApiException(ProfileApiFailure.unexpectedResponse);
    }
  }

  static String _text(Object? raw) => raw is String ? raw.trim() : '';
}
