import 'package:flutter/foundation.dart';

import '../domain/incident.dart';
import '../domain/incident_repository.dart';

enum IncidentsStatus { idle, loading, ready, failure }

/// Loads the client's incidents and reports new ones (US11).
///
/// Loading never blocks navigation: the Incidents section renders at once
/// and shows a loader until the list arrives.
class IncidentsController extends ChangeNotifier {
  IncidentsController({required IncidentRepository repository})
      : _repository = repository;

  final IncidentRepository _repository;

  IncidentsStatus _status = IncidentsStatus.idle;
  List<Incident> _incidents = const [];
  Object? _error;
  bool _submitting = false;
  Future<void>? _inFlight;
  bool _disposed = false;

  IncidentsStatus get status => _status;
  Object? get error => _error;
  bool get submitting => _submitting;

  /// Newest first.
  List<Incident> get incidents => _incidents;

  bool get hasData => _status == IncidentsStatus.ready ||
      (_status == IncidentsStatus.loading && _incidents.isNotEmpty);

  int get openCount =>
      _incidents.where((i) => i.status == IncidentStatus.open).length;
  int get inReviewCount =>
      _incidents.where((i) => i.status == IncidentStatus.inReview).length;
  int get closedCount => _incidents.where((i) => i.status.isClosed).length;

  /// Concurrent calls share the same request.
  Future<void> load() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    _status = IncidentsStatus.loading;
    _error = null;
    _notify();
    try {
      final fetched = await _repository.fetchMyIncidents();
      _incidents = List.unmodifiable(
        [...fetched]..sort((a, b) => b.reportedAt.compareTo(a.reportedAt)),
      );
      _status = IncidentsStatus.ready;
    } catch (error) {
      _error = error;
      _status = IncidentsStatus.failure;
    }
    _notify();
  }

  /// Sends [incident]; on success it is added at the top of the list.
  /// Rethrows the repository error so the form can show it.
  Future<Incident> report(NewIncident incident) async {
    if (incident.validate() != null) {
      throw ArgumentError('Invalid incident: ${incident.validate()}');
    }
    _submitting = true;
    _notify();
    try {
      final created = await _repository.report(incident);
      _incidents = List.unmodifiable([created, ..._incidents]);
      if (_status != IncidentsStatus.ready) _status = IncidentsStatus.ready;
      return created;
    } finally {
      _submitting = false;
      _notify();
    }
  }

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
