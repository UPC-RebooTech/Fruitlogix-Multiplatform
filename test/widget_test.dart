import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/fruitlogix_app.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

void main() {
  testWidgets('Signed-out app shows login', (tester) async {
    await tester.pumpWidget(const FruitLogixApp());
    expect(find.text('Sign in'), findsWidgets);
  });

  testWidgets('Commercial dashboard loads and routes to catalog', (tester) async {
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(localeController: LocaleController()),
    ));
    expect(find.text('Welcome, Carlos'), findsOneWidget);

    // The quick action sits below the KPI cards.
    final newOrder = find.text('New order');
    await tester.scrollUntilVisible(newOrder, 200,
        scrollable: find.byType(Scrollable).first);
    await tester.tap(newOrder);
    await tester.pumpAndSettle();

    expect(find.text('Commercial catalog'), findsOneWidget);
  });
}
