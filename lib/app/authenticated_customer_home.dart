import 'package:flutter/material.dart';

import '../contexts/iam/domain/auth_session.dart';
import '../contexts/profiles_management/domain/commercial_client_profile.dart';
import '../contexts/profiles_management/domain/commercial_client_profile_repository.dart';
import '../contexts/profiles_management/infrastructure/http_commercial_client_profile_repository.dart';
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
    this.onSessionExpired,
    super.key,
  });

  final AuthSession session;
  final LocaleController localeController;
  final VoidCallback onSignOut;

  /// The platform rejected the token (401).
  final VoidCallback? onSessionExpired;

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

  /// The profile lives in the platform (`/profiles/me`). The copy this
  /// phone kept before only prefills the form when the platform has none.
  void _loadProfile() {
    final session = widget.session;
    _profileFuture = () async {
      CommercialClientProfile? local;
      try {
        local = (await SecureLocalCommercialClientProfileRepository.open(
          userId: session.userId,
          username: session.username,
        )).current;
      } catch (_) {
        local = null;
      }
      try {
        return await HttpCommercialClientProfileRepository.open(
          userId: session.userId,
          username: session.username,
          token: () => session.token,
          fallback: local,
        );
      } on ProfileApiException catch (error) {
        if (error.reason == ProfileApiFailure.unauthorized) {
          widget.onSessionExpired?.call();
        }
        rethrow;
      }
    }();
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
          onSessionExpired: widget.onSessionExpired ?? widget.onSignOut,
          profileRepository: snapshot.requireData,
          // Payment Management (US36/US70/US30) calls the API with this JWT.
          session: widget.session,
        );
      },
    );
  }
}
