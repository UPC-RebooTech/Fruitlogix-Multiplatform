import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/fruitlogix_app.dart';

void main() {
  testWidgets('Commercial dashboard loads and routes to catalog', (tester) async {
    await tester.pumpWidget(const FruitLogixApp());
    expect(find.text('Welcome, Carlos'), findsOneWidget);
    await tester.tap(find.text('New order'));
    await tester.pumpAndSettle();
    expect(find.text('Implementation pending'), findsOneWidget);
  });
}
