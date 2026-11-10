import 'commercial_client_profile.dart';

/// Domain port. An API-backed implementation can replace the in-memory one.
abstract class CommercialClientProfileRepository {
  CommercialClientProfile get current;
  void save(CommercialClientProfile profile);
}
