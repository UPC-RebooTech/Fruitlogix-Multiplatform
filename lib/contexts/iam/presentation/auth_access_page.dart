import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../app/locale_controller.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../infrastructure/auth_session_controller.dart';
import '../infrastructure/fruitlogix_auth_api.dart';

/// Auth UI for the commercial-client app. Backend IAM only stores credentials.
/// Business profile data is handled separately by Profiles Management.
class AuthAccessPage extends StatefulWidget {
  const AuthAccessPage({
    required this.controller,
    required this.localeController,
    super.key,
  });

  final AuthSessionController controller;
  final LocaleController localeController;

  @override
  State<AuthAccessPage> createState() => _AuthAccessPageState();
}

class _AuthAccessPageState extends State<AuthAccessPage> {
  static const _languages = <CosechaLanguageOption>[
    CosechaLanguageOption(locale: Locale('en'), code: 'EN', name: 'English'),
    CosechaLanguageOption(locale: Locale('es'), code: 'ES', name: 'Español'),
  ];

  final _formKey = GlobalKey<FormState>();
  final _username = TextEditingController();
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _registering = false;
  bool _remember = false;
  bool _accepted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller.consumeExpiredNotice()) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _showError(AppLocalizations.of(context).authSessionExpired);
      });
    }
  }

  @override
  void dispose() {
    _username.dispose();
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  String? _validateUsername(String? value) {
    final username = (value ?? '').trim().toLowerCase();
    if (!_registering) {
      return username.isNotEmpty ? null : AppLocalizations.of(context).authUsernameRequired;
    }
    return RegExp(r'^[a-z0-9._]{4,20}$').hasMatch(username)
        ? null
        : AppLocalizations.of(context).authInvalidUsername;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (!_registering) {
      return password.isNotEmpty ? null : AppLocalizations.of(context).authRequiredPassword;
    }
    if (password.length >= 8 &&
        RegExp(r'[A-Za-z]').hasMatch(password) &&
        RegExp(r'[0-9]').hasMatch(password)) {
      return null;
    }
    return AppLocalizations.of(context).authInvalidPassword;
  }

  String _failureMessage(AppLocalizations l10n, AuthFailure failure) {
    return switch (failure) {
      AuthFailure.invalidCredentials => l10n.authInvalidCredentials,
      AuthFailure.usernameTakenOrInvalid => l10n.authUsernameUnavailable,
      AuthFailure.wrongRole => l10n.authWrongRole,
      AuthFailure.network => l10n.authNetworkError,
      AuthFailure.server => l10n.authServerError,
      AuthFailure.unexpectedResponse => l10n.authUnexpectedResponse,
    };
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_busy || !_formKey.currentState!.validate()) return;
    final l10n = AppLocalizations.of(context);
    if (_registering && !_accepted) {
      _showError(l10n.authMustAccept);
      return;
    }

    setState(() => _busy = true);
    try {
      final username = _username.text.trim().toLowerCase();
      if (_registering) {
        await widget.controller.register(
          username: username,
          password: _password.text,
          remember: _remember,
          // IAM does not receive business-profile fields. The next feature
          // persists them locally and replaces this no-op registration hook.
          saveLocalProfile: (_) async {},
        );
      } else {
        await widget.controller.signIn(
          username: username,
          password: _password.text,
          remember: _remember,
        );
      }
      // Successful auth notifies FruitLogixApp, which opens CustomerShell.
    } on AuthApiException catch (error) {
      if (mounted) {
        _showError(_failureMessage(AppLocalizations.of(context), error.reason));
      }
    } catch (_) {
      if (mounted) _showError(AppLocalizations.of(context).authUnexpectedResponse);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openLegal(String document) async {
    final lang = Localizations.localeOf(context).languageCode == 'es' ? 'es' : 'en';
    final uri = Uri.https(
      'upc-rebootech.github.io',
      '/Fruitlogix-website-v2/$document',
      {'lang': lang},
    );
    try {
      if (await launchUrl(uri, mode: LaunchMode.externalApplication)) return;
    } catch (_) {
      // Report an inaccessible browser below.
    }
    if (mounted) _showError(AppLocalizations.of(context).profileLegalOpenError);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inverseSurface,
        foregroundColor: Theme.of(context).colorScheme.onInverseSurface,
        title: Text(l10n.appTitle),
        actions: [
          CosechaLanguageButton(
            current: Localizations.localeOf(context),
            options: _languages,
            onSelected: widget.localeController.setLocale,
            tooltip: l10n.languageTooltip,
          ),
          const SizedBox(width: CosechaSpace.sm),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(CosechaSpace.screenMargin),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CosechaPageHeader(
                      title: _registering ? l10n.authRegisterTitle : l10n.authLoginTitle,
                      subtitle: l10n.authWelcome,
                    ),
                    const SizedBox(height: CosechaSpace.md),
                    CosechaTextField(
                      label: l10n.authUsername,
                      controller: _username,
                      enabled: !_busy,
                      textInputAction: TextInputAction.next,
                      validator: _validateUsername,
                    ),
                    const SizedBox(height: CosechaSpace.sm),
                    CosechaTextField(
                      label: l10n.authPassword,
                      controller: _password,
                      enabled: !_busy,
                      obscureText: true,
                      validator: _validatePassword,
                      textInputAction: _registering
                          ? TextInputAction.next
                          : TextInputAction.done,
                    ),
                    if (_registering) ...[
                      const SizedBox(height: CosechaSpace.sm),
                      CosechaTextField(
                        label: l10n.authConfirmPassword,
                        controller: _confirmation,
                        enabled: !_busy,
                        obscureText: true,
                        validator: (value) => value == _password.text
                            ? null
                            : l10n.authPasswordMismatch,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: CosechaSpace.md),
                      CheckboxListTile(
                        value: _accepted,
                        onChanged: _busy
                            ? null
                            : (value) => setState(() => _accepted = value ?? false),
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: Text(l10n.authAcceptance),
                      ),
                      Wrap(
                        alignment: WrapAlignment.start,
                        spacing: CosechaSpace.xs,
                        children: [
                          TextButton(
                            onPressed: _busy ? null : () => _openLegal('terminos.html'),
                            child: Text(l10n.profileLegalTerms),
                          ),
                          TextButton(
                            onPressed: _busy ? null : () => _openLegal('privacidad.html'),
                            child: Text(l10n.profileLegalPrivacy),
                          ),
                        ],
                      ),
                    ],
                    CheckboxListTile(
                      value: _remember,
                      onChanged: _busy
                          ? null
                          : (value) => setState(() => _remember = value ?? false),
                      contentPadding: EdgeInsets.zero,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(l10n.authRememberMe),
                    ),
                    const SizedBox(height: CosechaSpace.md),
                    if (_busy)
                      const Center(child: CircularProgressIndicator())
                    else
                      CosechaPrimaryButton(
                        label: _registering ? l10n.authCreateAccount : l10n.authSignIn,
                        onPressed: _submit,
                      ),
                    const SizedBox(height: CosechaSpace.sm),
                    Center(
                      child: CosechaTextButton(
                        label: _registering ? l10n.authSwitchToLogin : l10n.authSwitchToRegister,
                        onPressed: _busy
                            ? null
                            : () => setState(() {
                                  _registering = !_registering;
                                  _accepted = false;
                                  _confirmation.clear();
                                  _formKey.currentState?.reset();
                                }),
                      ),
                    ),
                    if (!_registering) ...[
                      const SizedBox(height: CosechaSpace.sm),
                      Text(
                        l10n.authLocalProfileNote,
                        textAlign: TextAlign.center,
                        style: Theme.of(context)
                            .textTheme.bodySmall
                            ?.copyWith(color: context.cosechaContentSecondary),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
