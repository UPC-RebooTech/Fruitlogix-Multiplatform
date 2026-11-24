import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/domain/lot_timeline.dart';
import 'package:fruitlogix_multiplatform/contexts/logistics_and_monitoring/logistics_module.dart';
import 'package:fruitlogix_multiplatform/contexts/order_management/order_management_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';

final lot = LotRecord(
  lotCode: 'LOT-2391',
  harvestedAt: DateTime(2026, 11, 20, 5, 30),
  harvestedBy: 'Agrícola San José',
  inspectedAt: DateTime(2026, 11, 21, 10, 15),
  inspectedBy: 'QC · Ana Torres',
  inspectionResult: InspectionResult.approved,
  loadedAt: DateTime(2026, 11, 22, 6),
);

List<TraceState> states(LotTimeline timeline) =>
    [for (final event in timeline.events) event.state];

void main() {
  group('US72 · buildLotTimeline', () {
    test('scenario 1: every stage with date and responsible, in chain order', () {
      final timeline = buildLotTimeline(TraceInputs(
        orderCode: 'ORD-0007',
        lot: lot,
        loaded: true,
        loadedBy: 'Luis Ramírez · ABC-123',
        received: true,
        receivedAt: DateTime(2026, 11, 23, 14),
        receivedBy: 'Mercado Central',
        invoiced: true,
        invoicedAt: DateTime(2026, 11, 23, 18),
        invoicedBy: 'Distributor',
      ));
      expect(timeline.events.map((e) => e.stage), TraceStage.values);
      expect(states(timeline), everyElement(TraceState.done));
      expect(timeline.isComplete, isTrue);
      final times = [for (final e in timeline.events) e.at!];
      expect([...times]..sort(), times, reason: 'chronological');
      expect(timeline.events[0].responsible, 'Agrícola San José');
      expect(timeline.events[1].inspectionResult, InspectionResult.approved);
      expect(timeline.events[2].responsible, 'Luis Ramírez · ABC-123');
      expect(timeline.lotCode, 'LOT-2391');
    });

    test('scenario 2: stages not reached yet are pending ("To do")', () {
      final timeline = buildLotTimeline(TraceInputs(
        orderCode: 'ORD-0008',
        lot: LotRecord(lotCode: 'LOT-2388', harvestedAt: DateTime(2026, 11, 22)),
      ));
      expect(states(timeline), [
        TraceState.done,
        TraceState.pending,
        TraceState.pending,
        TraceState.pending,
        TraceState.pending,
      ]);
      expect(timeline.isComplete, isFalse);
      expect(timeline.hasMissingRecords, isFalse);
    });

    test('a delivered order without lot data: earlier stages have no record', () {
      final timeline = buildLotTimeline(const TraceInputs(
        orderCode: 'ORD-0007',
        loaded: true,
        received: true,
      ));
      expect(states(timeline), [
        TraceState.noRecord,
        TraceState.noRecord,
        TraceState.done,
        TraceState.done,
        TraceState.pending,
      ]);
      expect(timeline.hasMissingRecords, isTrue);
      expect(timeline.lotCode, isNull);
    });

    test('an invoice issued before reception does not mark reception as done', () {
      final timeline = buildLotTimeline(TraceInputs(
        orderCode: 'ORD-1042',
        lot: lot,
        loaded: true,
        invoiced: true,
      ));
      expect(timeline.events[3].state, TraceState.pending);
      expect(timeline.events[4].state, TraceState.done);
    });
  });

  testWidgets('US72: traceability opened from an order card', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 2600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(
        localeController: LocaleController(),
        orderModule: OrderManagementModule.demo(latency: Duration.zero),
        logisticsModule: LogisticsModule.demo(latency: Duration.zero),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Orders'));
    await tester.pumpAndSettle();

    // ORD-1042 is the second active order (newest first: ORD-1040, ORD-1042).
    await tester.tap(find.textContaining('View traceability').at(1));
    await tester.pumpAndSettle();

    expect(find.text('Traceability ORD-1042'), findsOneWidget);
    expect(find.text('LOT-2391'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp(r'^Harvested, .*Responsible: Agrícola San José')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Quality inspected, .*Approved$')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(RegExp(r'^Loaded and dispatched, .*Responsible: Luis Ramírez · ABC-123')),
      findsOneWidget,
    );
    // In transit: not received yet (scenario 2).
    expect(find.bySemanticsLabel(RegExp(r'^Received, To do$')), findsOneWidget);
  });
}
