import 'package:http/http.dart' as http;

import '../iam/domain/auth_session.dart';
import 'application/incidents_controller.dart';
import 'domain/incident.dart';
import 'domain/incident_repository.dart';
import 'infrastructure/demo_quality_repositories.dart';
import 'infrastructure/evidence_picker.dart';
import 'infrastructure/evidence_store.dart';
import 'infrastructure/fruitlogix_quality_api.dart';
import 'infrastructure/http_incident_repository.dart';
import 'infrastructure/local_incident_index.dart';

/// Composition root of the Quality Management bounded context (EP02).
///
/// [QualityManagementModule.remote] talks to the platform API with the
/// signed-in user's JWT: photos are uploaded with `POST /files` and their
/// URLs sent with the incident (a copy stays on the phone).
/// [QualityManagementModule.demo] works offline.
class QualityManagementModule {
  QualityManagementModule._({
    required this.incidents,
    required this.targets,
    required this.picker,
    FruitLogixQualityApi? api,
  }) : _api = api;

  factory QualityManagementModule.remote(
    AuthSession session, {
    required IncidentTargetSource targets,
    http.Client? client,
  }) {
    final api = FruitLogixQualityApi(token: () => session.token, client: client);
    return QualityManagementModule._(
      api: api,
      targets: targets,
      picker: ImagePickerEvidencePicker(),
      incidents: IncidentsController(
        repository: HttpIncidentRepository(
          api: api,
          index: SharedPreferencesIncidentIndex(userId: session.userId),
          evidence: EvidenceStore.device(scope: '${session.userId}'),
        ),
      ),
    );
  }

  factory QualityManagementModule.demo({
    IncidentTargetSource targets = const DemoIncidentTargets(),
    EvidencePicker? picker,
    Duration latency = const Duration(milliseconds: 250),
  }) =>
      QualityManagementModule._(
        targets: targets,
        picker: picker ?? ImagePickerEvidencePicker(),
        incidents: IncidentsController(
          repository: DemoIncidentRepository(latency: latency),
        ),
      );

  final IncidentsController incidents;
  final IncidentTargetSource targets;
  final EvidencePicker picker;
  final FruitLogixQualityApi? _api;

  Future<void> start() => incidents.load();

  /// Target for an order code coming from reception or the order card.
  IncidentTarget? targetForOrder(String orderCode) =>
      targets.targetForOrder(orderCode);

  void dispose() {
    incidents.dispose();
    _api?.close();
  }
}
