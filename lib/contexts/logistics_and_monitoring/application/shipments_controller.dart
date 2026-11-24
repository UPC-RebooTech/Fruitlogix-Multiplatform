import 'package:flutter/foundation.dart';

import '../domain/shipment.dart';
import '../domain/shipment_repository.dart';

enum ShipmentsStatus { idle, loading, ready, failure }

/// Loads the deliveries of the client's orders for the Tracking tab.
class ShipmentsController extends ChangeNotifier {
  ShipmentsController({required ShipmentRepository repository})
    : _repository = repository;

  final ShipmentRepository _repository;

  ShipmentsStatus _status = ShipmentsStatus.idle;
  List<DeliveryShipment> _shipments = const [];
  Object? _error;
  Future<void>? _inFlight;
  bool _disposed = false;

  ShipmentsStatus get status => _status;
  Object? get error => _error;

  /// Active first (in transit and delayed before scheduled), by ETA.
  List<DeliveryShipment> get shipments => _shipments;

  bool get hasData =>
      _status == ShipmentsStatus.ready ||
      (_status == ShipmentsStatus.loading && _shipments.isNotEmpty);

  /// Concurrent calls share the same request.
  Future<void> load() =>
      _inFlight ??= _load().whenComplete(() => _inFlight = null);

  Future<void> _load() async {
    _status = ShipmentsStatus.loading;
    _error = null;
    _notify();
    try {
      final List<DeliveryShipment> fetched = [
        ...await _repository.fetchMyShipments(),
      ]..sort(_byRelevance);
      _shipments = List<DeliveryShipment>.unmodifiable(fetched);
      _status = ShipmentsStatus.ready;
    } catch (error) {
      _error = error;
      _status = ShipmentsStatus.failure;
    }
    _notify();
  }

  /// Reception confirmed at the dock (kept on the device until US35 sends
  /// it to the platform).
  void markAsReceived(
    String shipmentId, {
    String? notes,
    bool incidents = false,
  }) {
    for (final shipment in _shipments) {
      if (shipment.id != shipmentId) continue;
      shipment
        ..isReceived = true
        ..inspectionNotes = notes
        ..hasIncidents = incidents;
    }
    _notify();
  }

  static int _rank(DeliveryShipment s) {
    if (s.isReceived || s.status == ShipmentStatus.delivered) return 4;
    return switch (s.status) {
      ShipmentStatus.arrived => 0,
      ShipmentStatus.inTransit || ShipmentStatus.delayed => 1,
      ShipmentStatus.dispatched => 2,
      _ => 3,
    };
  }

  static int _byRelevance(DeliveryShipment a, DeliveryShipment b) {
    final byRank = _rank(a).compareTo(_rank(b));
    if (byRank != 0) return byRank;
    final ea = a.estimatedArrival, eb = b.estimatedArrival;
    if (ea == null || eb == null) return ea == null ? 1 : -1;
    return ea.compareTo(eb);
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
