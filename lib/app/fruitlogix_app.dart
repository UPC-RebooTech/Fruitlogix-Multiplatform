import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../shared/ui/theme/theme.dart';
import 'customer_shell.dart';
import 'locale_controller.dart';

class FruitLogixApp extends StatefulWidget {
  const FruitLogixApp({this.localeController, super.key});

  /// Saved UI language. When null (e.g. in widget tests) an in-memory
  /// controller is used.
  final LocaleController? localeController;

  @override
  State<FruitLogixApp> createState() => _FruitLogixAppState();
}

class _FruitLogixAppState extends State<FruitLogixApp> {
  late final LocaleController _localeController =
      widget.localeController ?? LocaleController();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _localeController,
      builder: (context, _) => MaterialApp(
        onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
        debugShowCheckedModeBanner: false,
        theme: CosechaTheme.light,
        // Chosen in the app; otherwise the phone language (English by
        // default, Spanish when the phone is in Spanish).
        locale: _localeController.locale,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: CustomerShell(localeController: _localeController),
      ),
    );
  }
}
