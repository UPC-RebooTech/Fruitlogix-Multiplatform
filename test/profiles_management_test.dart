import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/profiles_management/domain/commercial_client_profile.dart';
import 'package:fruitlogix_multiplatform/contexts/profiles_management/infrastructure/in_memory_commercial_client_profile_repository.dart';

void main() {
  test('demo commercial profile satisfies domain validation', () {
    final repository = InMemoryCommercialClientProfileRepository();
    expect(repository.current.isValid, isTrue);
    expect(repository.current.firstName, 'Carlos');
  });

  test('profile repository updates information in memory', () {
    final repository = InMemoryCommercialClientProfileRepository();
    final old = repository.current;
    repository.save(CommercialClientProfile(
      id: old.id,
      fullName: 'Carmen Torres',
      businessName: old.businessName,
      email: old.email,
      phone: old.phone,
      taxId: old.taxId,
    ));
    expect(repository.current.firstName, 'Carmen');
  });

  test('invalid business profile cannot be saved', () {
    final repository = InMemoryCommercialClientProfileRepository();
    final old = repository.current;
    expect(
      () => repository.save(CommercialClientProfile(
        id: old.id,
        fullName: old.fullName,
        businessName: old.businessName,
        email: 'invalid-email',
        phone: old.phone,
        taxId: old.taxId,
      )),
      throwsArgumentError,
    );
  });

  test('validates Peruvian mobile phone numbers', () {
    expect(
      CommercialClientProfile.validatePhone('987654321'),
      isNull,
    );

    expect(
      CommercialClientProfile.validatePhone('+51 987 654 321'),
      isNull,
    );

    expect(
      CommercialClientProfile.validatePhone('98765432'),
      isNotNull,
    );

    expect(
      CommercialClientProfile.validatePhone('812345678'),
      isNotNull,
    );
  });
}
