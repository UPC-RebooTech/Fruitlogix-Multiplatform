import 'commercial_client_profile.dart';

abstract class CommercialClientProfileRepository {
  CommercialClientProfile get current;

  bool get isPersistent;

  Future<void> save(CommercialClientProfile profile);
}