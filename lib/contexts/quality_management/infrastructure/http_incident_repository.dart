import '../domain/incident.dart';
import '../domain/incident_repository.dart';
import 'evidence_store.dart';
import 'fruitlogix_quality_api.dart';
import 'incident_json_parser.dart';
import 'local_incident_index.dart';

/// Incidents in the platform API, with their photos kept on the device.
class HttpIncidentRepository implements IncidentRepository {
  HttpIncidentRepository({
    required this.api,
    required this.index,
    required this.evidence,
  });

  final FruitLogixQualityApi api;
  final IncidentIndex index;
  final EvidenceStore evidence;

  @override
  Future<List<Incident>> fetchMyIncidents() async {
    final body = await api.getIncidents();
    final List<Incident> all;
    try {
      all = IncidentJsonParser.parseList(body);
    } on FormatException {
      throw const QualityApiException(QualityApiFailure.unexpectedResponse);
    }
    final mine = await index.load();
    return [
      for (final incident in all)
        if (mine.containsKey(incident.id))
          incident.copyWith(
            orderCode: mine[incident.id]!.orderCode,
            evidence: await evidence.load(incident.id),
          ),
    ];
  }

  @override
  Future<Incident> report(NewIncident incident) async {
    final error = incident.validate();
    if (error != null) throw ArgumentError('Invalid incident: $error');
    final target = incident.target!;
    final description = incident.description.trim();

    final body = await api.createIncident(
      batchId: target.batchId,
      description: description,
    );

    var id = IncidentJsonParser.createdId(body);
    Incident? created;
    if (body is Map) {
      try {
        created = IncidentJsonParser.parse(body);
      } on FormatException {
        created = null;
      }
    }
    if (id == null) {
      // The API answered without the new id: find it in the list.
      final all = IncidentJsonParser.parseList(await api.getIncidents());
      final candidates = all
          .where((i) => i.batchId == target.batchId && i.description == description)
          .toList();
      if (candidates.isEmpty) {
        throw const QualityApiException(QualityApiFailure.unexpectedResponse);
      }
      created = candidates.last;
      id = created.id;
    }

    await index.remember(id, IncidentLocalMeta(orderCode: target.orderCode));
    final photos = await evidence.save(id, incident.photos);
    return (created ??
            Incident(
              id: id,
              batchId: target.batchId,
              description: description,
              reportedAt: DateTime.now(),
              status: IncidentStatus.open,
            ))
        .copyWith(orderCode: target.orderCode, evidence: photos);
  }
}
