import 'incident.dart';

/// Incidents reported by the signed-in Commercial Client.
abstract interface class IncidentRepository {
  /// The client's incidents, with their local evidence photos.
  Future<List<Incident>> fetchMyIncidents();

  /// Sends the incident and keeps its photos on the device.
  /// Throws [ArgumentError] when [incident] is not valid.
  Future<Incident> report(NewIncident incident);
}

/// Orders (and their lots) the client can report about.
abstract interface class IncidentTargetSource {
  /// Recent orders, newest first.
  Future<List<IncidentTarget>> reportableTargets();

  /// The target of a known order (from reception or the order card).
  IncidentTarget targetForOrder(String orderCode);
}
