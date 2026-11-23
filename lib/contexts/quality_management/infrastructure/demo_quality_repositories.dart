import '../domain/incident.dart';
import '../domain/incident_repository.dart';
import 'evidence_store.dart';

/// Offline incidents (no session, widget tests, or until Order Management
/// provides real lots).
class DemoIncidentRepository implements IncidentRepository {
  DemoIncidentRepository({
    EvidenceStore? evidence,
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 250),
  })  : _evidence = evidence ?? MemoryEvidenceStore(),
        _clock = clock ?? DateTime.now {
    final now = _clock();
    _incidents.addAll([
      Incident(
        id: '7',
        batchId: 2388,
        orderCode: 'ORD-1040',
        description: 'Kent mango boxes arrived with bruised fruit on the top layer.',
        reportedAt: now.subtract(const Duration(days: 2, hours: 3)),
        status: IncidentStatus.inReview,
      ),
      Incident(
        id: '4',
        batchId: 2374,
        orderCode: 'ORD-1036',
        description: 'Two boxes of Hass avocado were missing from the delivery.',
        reportedAt: now.subtract(const Duration(days: 9)),
        status: IncidentStatus.resolved,
      ),
    ]);
  }

  final EvidenceStore _evidence;
  final DateTime Function() _clock;
  final Duration latency;
  final List<Incident> _incidents = [];
  int _nextId = 8;

  @override
  Future<List<Incident>> fetchMyIncidents() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return [
      for (final incident in _incidents)
        incident.copyWith(evidence: await _evidence.load(incident.id)),
    ];
  }

  @override
  Future<Incident> report(NewIncident incident) async {
    final error = incident.validate();
    if (error != null) throw ArgumentError('Invalid incident: $error');
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    final id = '${_nextId++}';
    final created = Incident(
      id: id,
      batchId: incident.target!.batchId,
      orderCode: incident.target!.orderCode,
      description: incident.description.trim(),
      reportedAt: _clock(),
      status: IncidentStatus.open,
    );
    _incidents.add(created);
    return created.copyWith(evidence: await _evidence.save(id, incident.photos));
  }
}

/// Demo orders and lots. Lots are fictitious until Order Management reads
/// the client's orders from the platform API.
class DemoIncidentTargets implements IncidentTargetSource {
  const DemoIncidentTargets({this.extraOrders = _noOrders});

  /// Orders created in this session (from the catalog), newest first.
  final List<IncidentTarget> Function() extraOrders;

  static List<IncidentTarget> _noOrders() => const [];

  static const List<IncidentTarget> _known = [
    IncidentTarget(
      orderCode: 'ORD-1042',
      batchId: 2391,
      productSummary: 'Mango Kent · Palta Hass',
    ),
    IncidentTarget(
      orderCode: 'ORD-1040',
      batchId: 2388,
      productSummary: 'Mango Kent',
    ),
  ];

  @override
  Future<List<IncidentTarget>> reportableTargets() async =>
      [...extraOrders(), ..._known];

  @override
  IncidentTarget targetForOrder(String orderCode) {
    for (final target in [...extraOrders(), ..._known]) {
      if (target.orderCode == orderCode) return target;
    }
    return IncidentTarget(orderCode: orderCode, batchId: demoBatchFor(orderCode));
  }

  /// Stable fictitious lot for an order code (`ORD-1043` → `2443`).
  static int demoBatchFor(String orderCode) {
    final digits = int.tryParse(orderCode.replaceAll(RegExp(r'\D'), '')) ?? 0;
    return 2000 + digits % 1000 + 400;
  }
}
