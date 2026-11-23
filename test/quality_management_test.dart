import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fruitlogix_multiplatform/app/customer_shell.dart';
import 'package:fruitlogix_multiplatform/app/locale_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/application/incidents_controller.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/domain/incident.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/demo_quality_repositories.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/evidence_picker.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/evidence_store.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/fruitlogix_quality_api.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/http_incident_repository.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/incident_json_parser.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/infrastructure/local_incident_index.dart';
import 'package:fruitlogix_multiplatform/contexts/quality_management/quality_management_module.dart';
import 'package:fruitlogix_multiplatform/l10n/app_localizations.dart';
import 'package:fruitlogix_multiplatform/shared/ui/theme/theme.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

const target = IncidentTarget(orderCode: 'ORD-1042', batchId: 2391);
final photo = Uint8List.fromList([1, 2, 3]);

/// Returns fixed bytes instead of opening the camera.
class FakeEvidencePicker implements EvidencePicker {
  int calls = 0;

  @override
  bool get supportsCamera => false;

  @override
  Future<List<Uint8List>> pick(EvidenceSource source, {required int max}) async {
    calls++;
    return [Uint8List.fromList(_tinyPng)];
  }
}

// 1×1 transparent PNG so Image.memory can decode it.
const List<int> _tinyPng = [
  137, 80, 78, 71, 13, 10, 26, 10, 0, 0, 0, 13, 73, 72, 68, 82, 0, 0, 0, 1, 0, 0,
  0, 1, 8, 6, 0, 0, 0, 31, 21, 196, 137, 0, 0, 0, 13, 73, 68, 65, 84, 120, 156, 99,
  0, 1, 0, 0, 5, 0, 1, 13, 10, 45, 180, 0, 0, 0, 0, 73, 69, 78, 68, 174, 66, 96, 130,
];

void main() {
  group('US11 · domain', () {
    test('a description needs at least 10 characters', () {
      expect(NewIncident.validateDescription('Bruised'), IncidentDraftError.descriptionTooShort);
      expect(NewIncident.validateDescription('   Bruised fruit   '), isNull);
    });

    test('an incident needs an order and at most 4 photos', () {
      expect(
        const NewIncident(target: null, description: 'Bruised fruit on top').validate(),
        IncidentDraftError.missingTarget,
      );
      expect(
        NewIncident(target: target, description: 'Bruised fruit on top', photos: List.filled(5, photo))
            .validate(),
        IncidentDraftError.tooManyPhotos,
      );
      expect(
        NewIncident(target: target, description: 'Bruised fruit on top', photos: [photo]).validate(),
        isNull,
      );
    });

    test('display codes', () {
      final incident = Incident(
        id: '7',
        batchId: 2388,
        description: 'x',
        reportedAt: DateTime(2026),
        status: IncidentStatus.open,
      );
      expect(incident.code, 'INC-0007');
      expect(incident.lotCode, 'LOT-2388');
    });
  });

  group('API response parsing', () {
    test('statuses in different spellings', () {
      expect(IncidentJsonParser.parseStatus('OPEN'), IncidentStatus.open);
      expect(IncidentJsonParser.parseStatus('reported'), IncidentStatus.open);
      expect(IncidentJsonParser.parseStatus('In_Review'), IncidentStatus.inReview);
      expect(IncidentJsonParser.parseStatus('En revisión'), IncidentStatus.inReview);
      expect(IncidentJsonParser.parseStatus('RESOLVED'), IncidentStatus.resolved);
      expect(IncidentJsonParser.parseStatus('cerrada'), IncidentStatus.resolved);
      expect(IncidentJsonParser.parseStatus('Rechazada'), IncidentStatus.rejected);
      expect(IncidentJsonParser.parseStatus(1), IncidentStatus.inReview);
      expect(IncidentJsonParser.parseStatus(null), IncidentStatus.open);
    });

    test('lists, wrapped lists and malformed items', () {
      final list = IncidentJsonParser.parseList([
        {'id': 3, 'batchId': 2391, 'description': 'Bruised', 'status': 'OPEN', 'createdAt': '2026-11-20T10:00:00Z'},
        {'description': 'no id'},
      ]);
      expect(list, hasLength(1));
      expect(list.single.id, '3');
      expect(list.single.reportedAt.toUtc(), DateTime.utc(2026, 11, 20, 10));
      expect(IncidentJsonParser.parseList({'data': []}), isEmpty);
      expect(() => IncidentJsonParser.parseList('oops'), throwsFormatException);
    });
  });

  group('HttpIncidentRepository', () {
    late List<http.Request> requests;
    late InMemoryIncidentIndex index;
    late MemoryEvidenceStore evidence;

    HttpIncidentRepository repository(Future<http.Response> Function(http.Request) handler) {
      requests = [];
      index = InMemoryIncidentIndex();
      evidence = MemoryEvidenceStore();
      final client = MockClient((request) {
        requests.add(request);
        return handler(request);
      });
      return HttpIncidentRepository(
        api: FruitLogixQualityApi(
          token: () => 'jwt',
          client: client,
          baseUri: Uri.parse('https://api.test'),
        ),
        index: index,
        evidence: evidence,
      );
    }

    test('reports with the JWT and keeps the photos on the device', () async {
      final repo = repository((request) async => http.Response(
            jsonEncode({'id': 12, 'batchId': 2391, 'description': 'Bruised fruit on top', 'status': 'OPEN'}),
            200,
          ));
      final created = await repo.report(
        NewIncident(target: target, description: '  Bruised fruit on top ', photos: [photo]),
      );

      final sent = requests.single;
      expect(sent.method, 'POST');
      expect(sent.url.path, '/api/v1/incidents');
      expect(sent.headers['Authorization'], 'Bearer jwt');
      expect(jsonDecode(sent.body), {
        'batchId': 2391,
        'description': 'Bruised fruit on top',
        'evidenceUrls': <String>[],
      });
      expect(created.id, '12');
      expect(created.orderCode, 'ORD-1042');
      expect(created.evidence.single.bytes, photo);
      expect((await index.load()).keys, ['12']);
      expect(await evidence.load('12'), hasLength(1));
    });

    test('finds the new id in the list when POST returns no body', () async {
      final repo = repository((request) async => request.method == 'POST'
          ? http.Response('', 200)
          : http.Response(
              jsonEncode([
                {'id': 5, 'batchId': 1, 'description': 'Other client', 'status': 'OPEN'},
                {'id': 6, 'batchId': 2391, 'description': 'Bruised fruit on top', 'status': 'OPEN'},
              ]),
              200,
            ));
      final created = await repo.report(
        const NewIncident(target: target, description: 'Bruised fruit on top'),
      );
      expect(created.id, '6');
    });

    test('only lists the incidents this client reported', () async {
      final repo = repository((request) async => http.Response(
            jsonEncode([
              {'id': 5, 'batchId': 1, 'description': 'Other client', 'status': 'OPEN'},
              {'id': 6, 'batchId': 2391, 'description': 'Mine', 'status': 'IN_REVIEW'},
            ]),
            200,
          ));
      await index.remember('6', const IncidentLocalMeta(orderCode: 'ORD-1042'));
      final mine = await repo.fetchMyIncidents();
      expect(mine.map((i) => i.id), ['6']);
      expect(mine.single.status, IncidentStatus.inReview);
      expect(mine.single.orderCode, 'ORD-1042');
    });

    test('maps HTTP failures', () async {
      final unauthorized = repository((_) async => http.Response('', 401));
      await expectLater(
        unauthorized.fetchMyIncidents(),
        throwsA(isA<QualityApiException>()
            .having((e) => e.reason, 'reason', QualityApiFailure.unauthorized)),
      );
      final server = repository((_) async => http.Response('boom', 500));
      await expectLater(
        server.fetchMyIncidents(),
        throwsA(isA<QualityApiException>()
            .having((e) => e.reason, 'reason', QualityApiFailure.server)),
      );
    });
  });

  group('IncidentsController', () {
    test('loads newest first, counts by status and adds reports on top', () async {
      final controller = IncidentsController(
        repository: DemoIncidentRepository(latency: Duration.zero),
      );
      await controller.load();
      expect(controller.status, IncidentsStatus.ready);
      expect(controller.incidents.first.id, '7');
      expect(controller.inReviewCount, 1);
      expect(controller.closedCount, 1);
      expect(controller.openCount, 0);

      final created = await controller.report(
        NewIncident(target: target, description: 'Wrong product delivered', photos: [photo]),
      );
      expect(controller.incidents.first, same(created));
      expect(controller.openCount, 1);
      expect(controller.submitting, isFalse);
    });

    test('rejects invalid incidents before calling the repository', () async {
      final controller = IncidentsController(
        repository: DemoIncidentRepository(latency: Duration.zero),
      );
      expect(
        () => controller.report(const NewIncident(target: target, description: 'short')),
        throwsArgumentError,
      );
    });
  });

  test('order codes map to stable demo lots', () {
    const targets = DemoIncidentTargets();
    expect(targets.targetForOrder('ORD-1042').batchId, 2391);
    expect(targets.targetForOrder('ORD-1043').batchId, DemoIncidentTargets.demoBatchFor('ORD-1043'));
    expect(DemoIncidentTargets.demoBatchFor('ORD-1043'), DemoIncidentTargets.demoBatchFor('ORD-1043'));
  });

  testWidgets('US11: report an incident with a photo from More → Incidents', (tester) async {
    tester.view.physicalSize = const Size(390 * 3, 1600 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final picker = FakeEvidencePicker();
    final quality = QualityManagementModule.demo(picker: picker, latency: Duration.zero);
    await tester.pumpWidget(MaterialApp(
      theme: CosechaTheme.light,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: CustomerShell(localeController: LocaleController(), qualityModule: quality),
    ));
    await tester.pumpAndSettle();

    // More → Incidents keeps both bars and marks "More".
    await tester.tap(find.byTooltip('More'));
    await tester.pumpAndSettle();
    await tester.tap(find.bySemanticsLabel('Incidents').last);
    await tester.pumpAndSettle();
    expect(find.text('INC-0007'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);

    // Sending empty shows the errors (validation on Send).
    await tester.tap(find.text('Report an incident').first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Send report'));
    await tester.pumpAndSettle();
    expect(find.text('Choose the order with the problem'), findsOneWidget);
    expect(find.text('Describe the problem (at least 10 characters)'), findsOneWidget);

    // Choose the order, describe, add a photo and send.
    await tester.tap(find.text('ORD-1042 · Lot LOT-2391'));
    await tester.pumpAndSettle();
    expect(find.text('Choose the order with the problem'), findsNothing);
    await tester.enterText(find.byType(TextField), 'Bruised mangoes in 3 boxes');
    await tester.pumpAndSettle();
    expect(find.text('Describe the problem (at least 10 characters)'), findsNothing);
    await tester.tap(find.text('Add photo'));
    await tester.pumpAndSettle();
    expect(picker.calls, 1);
    expect(find.bySemanticsLabel('Photo 1'), findsOneWidget);
    await tester.tap(find.text('Send report'));
    await tester.pumpAndSettle();

    // The new incident opens in detail, inside the shell.
    expect(find.text('Incident INC-0008'), findsOneWidget);
    expect(find.text('Bruised mangoes in 3 boxes'), findsOneWidget);
    expect(find.text('Open'), findsWidgets);

    // Back returns to the history, which now starts with the new incident.
    await tester.tap(find.byType(BackButtonIcon));
    await tester.pumpAndSettle();
    expect(find.text('INC-0008'), findsOneWidget);
  });
}
