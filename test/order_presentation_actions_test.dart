import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/commercial_order.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/domain/order_edit.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/presentation/order_actions_sheet.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

CommercialOrder _pendingOrder() => CommercialOrder(
  id: '9001',
  lines: const [],
  deliveryAddress: 'Av. Arequipa 123',
  deliveryDate: DateTime.now().add(const Duration(days: 7)),
  status: OrderStatus.pending,
  totalAmount: 10,
);

Widget _app(Widget child) => MaterialApp(
  theme: CosechaTheme.light,
  locale: const Locale('en'),
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  home: Scaffold(body: Center(child: child)),
);

void main() {
  testWidgets('edit sheet returns the fields supported by UpdateOrderResource',
      (tester) async {
    OrderUpdate? result;
    final order = _pendingOrder();
    await tester.pumpWidget(_app(
      Builder(builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await showOrderEditSheet(context: context, order: order);
        },
        child: const Text('Open edit'),
      )),
    ));
    await tester.tap(find.text('Open edit'));
    await tester.pumpAndSettle();
    expect(find.text('Edit order details'), findsOneWidget);
    await tester.tap(find.text('Save changes'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.deliveryAddress, 'Av. Arequipa 123');
    expect(result!.orderId, '9001');
  });

  testWidgets('cancellation sheet returns an optional reason', (tester) async {
    OrderCancellation? result;
    final order = _pendingOrder();
    await tester.pumpWidget(_app(
      Builder(builder: (context) => ElevatedButton(
        onPressed: () async {
          result = await showOrderCancelSheet(context: context, order: order);
        },
        child: const Text('Open cancel'),
      )),
    ));
    await tester.tap(find.text('Open cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Cancel order'), findsOneWidget);
    await tester.tap(find.text('Confirm cancellation'));
    await tester.pumpAndSettle();
    expect(result, isNotNull);
    expect(result!.orderId, '9001');
    expect(result!.reason, isNull);
  });
}
