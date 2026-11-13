import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../shared/ui/theme/theme.dart';
import 'customer_shell.dart';

class FruitLogixApp extends StatelessWidget {
  const FruitLogixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      onGenerateTitle: (context) => AppLocalizations.of(context).appTitle,
      debugShowCheckedModeBanner: false,
      theme: CosechaTheme.light,
      // English by default, Spanish when the device is in Spanish.
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: const CustomerShell(),
    );
  }
}
