import 'package:flutter/material.dart';

import '../contexts/iam/domain/auth_session.dart';
import '../contexts/profiles_management/domain/commercial_client_profile_repository.dart';
import '../contexts/profiles_management/infrastructure/secure_local_commercial_client_profile_repository.dart';
import '../l10n/app_localizations.dart';
import '../shared/ui/components/components.dart';
import 'customer_shell.dart';
import 'locale_controller.dart';

/// Loads the signed-in user's local profile before showing the customer shell.
/// Never falls back to Carlos Demo when a real IAM session exists.
class AuthenticatedCustomerHome extends StatefulWidget {
  const AuthenticatedCustomerHome({
    required this.session,
    required this.localeController,
    required this.onSignOut,
    super.key,
  });

  final AuthSession session;
  final LocaleController localeController;
  final VoidCallback onSignOut;

  @override
  State<AuthenticatedCustomerHome> createState() =>
      _AuthenticatedCustomerHomeState();
}

class _AuthenticatedCustomerHomeState extends State<AuthenticatedCustomerHome> {
  late Future<CommercialClientProfileRepository> _profileFuture;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = SecureLocalCommercialClientProfileRepository.open(
      userId: widget.session.userId,
      username: widget.session.username,
    );
  }

  @override
  void didUpdateWidget(covariant AuthenticatedCustomerHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.session.userId != widget.session.userId) {
      _loadProfile();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<CommercialClientProfileRepository>(
      future: _profileFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Scaffold(
            body: SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(l10n.profileLoadFailed, textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      CosechaPrimaryButton(
                        label: l10n.profileRetry,
                        onPressed: () => setState(_loadProfile),
                      ),
                      const SizedBox(height: 8),
                      CosechaTextButton(
                        label: l10n.authSignOut,
                        onPressed: widget.onSignOut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }
        return CustomerShell(
          localeController: widget.localeController,
          onSignOut: widget.onSignOut,
          profileRepository: snapshot.requireData,
        );
      },
    );
  }
}
