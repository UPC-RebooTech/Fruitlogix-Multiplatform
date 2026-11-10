import '../domain/commercial_client_profile.dart';
import '../domain/commercial_client_profile_repository.dart';

/// Local demo data; deliberately no backend/network connection.
class InMemoryCommercialClientProfileRepository
    implements CommercialClientProfileRepository {
  CommercialClientProfile _current = const CommercialClientProfile(
    id: 'demo-commercial-client',
    fullName: 'Carlos Demo',
    businessName: 'Mercado Central Demo',
    email: 'cliente@example.com',
    phone: '+51 987 654 321',
    taxId: '20123456789',
  );

  @override
  CommercialClientProfile get current => _current;

  @override
  void save(CommercialClientProfile profile) {
    if (!profile.isValid) {
      throw ArgumentError('Invalid commercial client profile');
    }
    if (profile.id != _current.id) {
      throw ArgumentError('Cannot change profile identity');
    }
    _current = profile;
  }
}
