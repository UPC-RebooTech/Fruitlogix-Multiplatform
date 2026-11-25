import 'commercial_client_profile.dart';

abstract class CommercialClientProfileRepository {
  CommercialClientProfile get current;

  bool get isPersistent;

  /// Saved in the platform (/profiles/me), not only on this phone.
  bool get syncsWithPlatform;

  Future<void> save(CommercialClientProfile profile);
}