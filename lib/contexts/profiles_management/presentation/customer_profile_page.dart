import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/initials.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/commercial_client_profile.dart';
import '../domain/commercial_client_profile_repository.dart';

/// Read/edit commercial client information with local demo persistence.
/// Production profile verification and backend persistence are out of scope.
///
/// View mode shows read-only data rows; edit mode shows fields with the
/// label above, validated when tapping Save.
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

  void _cancel() {
    final profile = widget.repository.current;
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
      SnackBar(content: Text(AppLocalizations.of(context).profileSaved)),
    );
  }

  /// Uses the domain rule and shows the localized message.
  String? Function(String?) _rule(
    String? Function(String?) domainRule,
    String message,
  ) =>
      (value) => domainRule(value) == null ? null : message;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final profile = widget.repository.current;

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CosechaSpace.screenMargin,
        CosechaSpace.md,
        CosechaSpace.screenMargin,
        CosechaSpace.lg,
      ),
      children: [
        _AccountCard(
          businessName: profile.businessName,
          fullName: profile.fullName,
          role: l10n.roleCommercialClient,
        ),
        const SizedBox(height: CosechaSpace.xs),
        Text(
          l10n.profileDemoNote,
          style: textTheme.bodySmall
              ?.copyWith(color: context.cosechaContentSecondary),
        ),
        const SizedBox(height: CosechaSpace.md),
        CosechaOverline(l10n.profileContactSection),
        const SizedBox(height: CosechaSpace.xs),
        if (_editing)
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CosechaTextField(
                  label: l10n.profileFullName,
                  controller: _fullName,
                  textInputAction: TextInputAction.next,
                  validator: _rule(
                    CommercialClientProfile.validateFullName,
                    l10n.profileFullNameError,
                  ),
                ),
                const SizedBox(height: CosechaSpace.sm),
                CosechaTextField(
                  label: l10n.profileBusinessName,
                  controller: _businessName,
                  textInputAction: TextInputAction.next,
                  validator: _rule(
                    CommercialClientProfile.validateBusinessName,
                    l10n.profileBusinessNameError,
                  ),
                ),
                const SizedBox(height: CosechaSpace.sm),
                CosechaTextField(
                  label: l10n.profileEmail,
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _rule(
                    CommercialClientProfile.validateEmail,
                    l10n.profileEmailError,
                  ),
                ),
                const SizedBox(height: CosechaSpace.sm),
                CosechaTextField(
                  label: l10n.profilePhone,
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _rule(
                    CommercialClientProfile.validatePhone,
                    l10n.profilePhoneError,
                  ),
                ),
                const SizedBox(height: CosechaSpace.sm),
                CosechaTextField(
                  label: l10n.profileTaxId,
                  controller: _taxId,
                  keyboardType: TextInputType.number,
                  textInputAction: TextInputAction.done,
                  validator: _rule(
                    CommercialClientProfile.validateTaxId,
                    l10n.profileTaxIdError,
                  ),
                ),
                const SizedBox(height: CosechaSpace.md),
                CosechaPrimaryButton(
                  label: l10n.profileSave,
                  icon: Icons.save_outlined,
                  onPressed: _save,
                ),
                const SizedBox(height: CosechaSpace.xs),
                Center(
                  child: CosechaTextButton(
                    label: l10n.cancel,
                    onPressed: _cancel,
                  ),
                ),
              ],
            ),
          )
        else ...[
          CosechaCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                CosechaInfoRow(
                  icon: Icons.person_outline,
                  label: l10n.profileFullName,
                  value: profile.fullName,
                ),
                const _RowDivider(),
                CosechaInfoRow(
                  icon: Icons.storefront_outlined,
                  label: l10n.profileBusinessName,
                  value: profile.businessName,
                ),
                const _RowDivider(),
                CosechaInfoRow(
                  icon: Icons.mail_outline,
                  label: l10n.profileEmail,
                  value: profile.email,
                ),
                const _RowDivider(),
                CosechaInfoRow(
                  icon: Icons.phone_outlined,
                  label: l10n.profilePhone,
                  value: profile.phone,
                  mono: true,
                ),
                const _RowDivider(),
                CosechaInfoRow(
                  icon: Icons.badge_outlined,
                  label: l10n.profileTaxId,
                  value: profile.taxId,
                  mono: true,
                ),
              ],
            ),
          ),
          const SizedBox(height: CosechaSpace.md),
          CosechaSecondaryButton(
            label: l10n.profileEdit,
            icon: Icons.edit_outlined,
            onPressed: () => setState(() => _editing = true),
          ),
        ],
      ],
    );
  }
}

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
        child: Divider(),
      );
}

/// Dark account card (an allowed highlighted block in Cosecha).
class _AccountCard extends StatelessWidget {
  const _AccountCard({
    required this.businessName,
    required this.fullName,
    required this.role,
  });

  final String businessName;
  final String fullName;
  final String role;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final colors = CosechaStatusColors.of(context);
    return CosechaCard(
      tone: CosechaCardTone.dark,
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Text(
              initialsOf(fullName),
              style: textTheme.titleMedium
                  ?.copyWith(color: scheme.onPrimaryContainer),
            ),
          ),
          const SizedBox(width: CosechaSpace.inner),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  businessName,
                  style: textTheme.titleMedium
                      ?.copyWith(color: colors.onDarkPrimary),
                ),
                Text(
                  fullName,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: colors.onDarkSecondary),
                ),
                const SizedBox(height: CosechaSpace.xs),
                CosechaStatusTag(
                  label: role,
                  status: CosechaStatus.highlight,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
