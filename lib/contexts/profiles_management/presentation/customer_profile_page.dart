import 'package:flutter/material.dart';

import '../../../app/fruitlogix_theme.dart';
import '../domain/commercial_client_profile.dart';
import '../domain/commercial_client_profile_repository.dart';

/// Read/edit commercial client information with local demo persistence.
/// Production profile verification and backend persistence are out of scope.
class CustomerProfilePage extends StatefulWidget {
  const CustomerProfilePage({
    required this.repository,
    required this.onSaved,
    super.key,
  });

  final CommercialClientProfileRepository repository;
  final VoidCallback onSaved;

  @override
  State<CustomerProfilePage> createState() => _CustomerProfilePageState();
}

class _CustomerProfilePageState extends State<CustomerProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fullName;
  late final TextEditingController _businessName;
  late final TextEditingController _email;
  late final TextEditingController _phone;
  late final TextEditingController _taxId;
  bool _editing = false;

  @override
  void initState() {
    super.initState();
    final profile = widget.repository.current;
    _fullName = TextEditingController(text: profile.fullName);
    _businessName = TextEditingController(text: profile.businessName);
    _email = TextEditingController(text: profile.email);
    _phone = TextEditingController(text: profile.phone);
    _taxId = TextEditingController(text: profile.taxId);
  }

  @override
  void dispose() {
    _fullName.dispose();
    _businessName.dispose();
    _email.dispose();
    _phone.dispose();
    _taxId.dispose();
    super.dispose();
  }

  void _reset() {
    final profile = widget.repository.current;
    _formKey.currentState?.reset();
    _fullName.text = profile.fullName;
    _businessName.text = profile.businessName;
    _email.text = profile.email;
    _phone.text = profile.phone;
    _taxId.text = profile.taxId;
    setState(() => _editing = false);
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final previous = widget.repository.current;
    final updated = CommercialClientProfile(
      id: previous.id,
      fullName: _fullName.text.trim(),
      businessName: _businessName.text.trim(),
      email: _email.text.trim(),
      phone: _phone.text.trim(),
      taxId: _taxId.text.trim(),
    );
    widget.repository.save(updated);
    setState(() => _editing = false);
    widget.onSaved();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Demo profile updated for this session')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Text(
          'Commercial profile',
          style: TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: FruitLogixPalette.forest,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          'Demo information · changes last for this app session',
          style: TextStyle(color: FruitLogixPalette.forestSoft),
        ),
        const SizedBox(height: 22),
        Container(
          decoration: BoxDecoration(
            color: FruitLogixPalette.forest,
            borderRadius: BorderRadius.circular(22),
          ),
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.business_outlined, color: FruitLogixPalette.lime),
                  SizedBox(width: 10),
                  Text('PROFILE AND CONTACT', style: TextStyle(
                    color: FruitLogixPalette.lime,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                  )),
                ]),
                const SizedBox(height: 20),
                _input(
                  label: 'Full name',
                  controller: _fullName,
                  validator: CommercialClientProfile.validateFullName,
                ),
                _input(
                  label: 'Business name',
                  controller: _businessName,
                  validator: CommercialClientProfile.validateBusinessName,
                ),
                _input(
                  label: 'Email',
                  controller: _email,
                  keyboard: TextInputType.emailAddress,
                  validator: CommercialClientProfile.validateEmail,
                ),
                _input(
                  label: 'Contact phone',
                  controller: _phone,
                  keyboard: TextInputType.phone,
                  validator: CommercialClientProfile.validatePhone,
                ),
                _input(
                  label: 'Business RUC',
                  controller: _taxId,
                  keyboard: TextInputType.number,
                  validator: CommercialClientProfile.validateTaxId,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        if (!_editing)
          FilledButton.icon(
            onPressed: () => setState(() => _editing = true),
            icon: const Icon(Icons.edit_outlined),
            label: const Text('Edit profile'),
          )
        else ...[
          FilledButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.save_outlined),
            label: const Text('Save changes'),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: _reset,
            child: const Text('Cancel'),
          ),
        ],
      ],
    );
  }

  Widget _input({
    required String label,
    required TextEditingController controller,
    required String? Function(String?) validator,
    TextInputType keyboard = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextFormField(
        controller: controller,
        readOnly: !_editing,
        keyboardType: keyboard,
        style: const TextStyle(color: Colors.white),
        validator: validator,
        autovalidateMode: AutovalidateMode.disabled,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: FruitLogixPalette.muted),
          floatingLabelStyle: const TextStyle(color: FruitLogixPalette.lime),
          filled: true,
          fillColor: FruitLogixPalette.forestSoft,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 17,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}
