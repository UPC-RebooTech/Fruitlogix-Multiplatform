/// Commercial Client profile aggregate within Profiles Management.
/// This model contains no Flutter or infrastructure dependencies.
class CommercialClientProfile {
  const CommercialClientProfile({
    required this.id,
    required this.fullName,
    required this.businessName,
    required this.email,
    required this.phone,
    required this.taxId,
  });

  final String id;
  final String fullName;
  final String businessName;
  final String email;
  final String phone;
  final String taxId;

  String get firstName => fullName.trim().split(RegExp(r'\s+')).first;

  bool get isValid =>
      validateFullName(fullName) == null &&
      validateBusinessName(businessName) == null &&
      validateEmail(email) == null &&
      validatePhone(phone) == null &&
      validateTaxId(taxId) == null;

  static String? validateFullName(String? value) =>
      (value ?? '').trim().length < 3 ? 'Enter your full name' : null;

  static String? validateBusinessName(String? value) =>
      (value ?? '').trim().length < 2 ? 'Enter your business name' : null;

  static String? validateEmail(String? value) {
    final text = (value ?? '').trim();
    final pattern = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return pattern.hasMatch(text) ? null : 'Enter a valid email';
  }

  static String? validatePhone(String? value) {
    final digits = (value ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.length >= 7 && digits.length <= 15
        ? null
        : 'Enter a valid phone number';
  }

  /// Initial demo uses a Peruvian RUC (11 digits).
  static String? validateTaxId(String? value) =>
      RegExp(r'^\d{11}$').hasMatch((value ?? '').trim())
          ? null
          : 'RUC must contain 11 digits';
}
