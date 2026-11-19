import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/fruitlogix_app.dart';

void main() {
  testWidgets('Commercial dashboard loads and routes to catalog', (tester) async {
    await tester.pumpWidget(const FruitLogixApp());
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
