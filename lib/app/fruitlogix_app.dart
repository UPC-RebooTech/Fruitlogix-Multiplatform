import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../shared/ui/theme/theme.dart';
import 'authenticated_customer_home.dart';
import 'locale_controller.dart';
import '../contexts/iam/infrastructure/auth_session_controller.dart';
import '../contexts/iam/presentation/auth_access_page.dart';

class FruitLogixApp extends StatefulWidget {
  const FruitLogixApp({this.localeController, this.authController, super.key});

  /// Saved UI language. When null (e.g. in widget tests) an in-memory
  /// controller is used.
  final LocaleController? localeController;
  final AuthSessionController? authController;

  @override
  State<FruitLogixApp> createState() => _FruitLogixAppState();
}

class _FruitLogixAppState extends State<FruitLogixApp> {
  late final LocaleController _localeController =
      widget.localeController ?? LocaleController();
  late final AuthSessionController _authController =
      widget.authController ?? AuthSessionController();

  @override
  void dispose() {
    if (widget.authController == null) _authController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_localeController, _authController]),
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: CosechaTheme.light,
        // Chosen in the app; otherwise the phone language (English by
        // default, Spanish when the phone is in Spanish).
        locale: _localeController.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: _authController.session == null
            ? AuthAccessPage(
                controller: _authController,
                localeController: _localeController,
              )
            : AuthenticatedCustomerHome(
          key: ValueKey(_authController.session!.userId),
          session: _authController.session!,
          localeController: _localeController,
          onSignOut: () {
            _authController.signOut();
          },
        ),
      ),
    );
  }
}
