import '../domain/incident.dart';
import '../domain/incident_repository.dart';

/// The client's orders that can get an incident: the platform needs the
/// harvest lot (`batchId`), which the producer links when preparing the
/// order. Orders without a lot are not offered yet.
class OrderIncidentTargets implements IncidentTargetSource {
  const OrderIncidentTargets({required this.orders});

  /// The client's orders with a lot, newest first (Order Management).
  final List<IncidentTarget> Function() orders;

  @override
  Future<List<IncidentTarget>> reportableTargets() async => orders();

  @override
  IncidentTarget? targetForOrder(String orderCode) {
    for (final target in orders()) {
      if (target.orderCode == orderCode) return target;
    }
    return null;
  }
}
