import 'package:flutter/foundation.dart';

import '../domain/reception_repository.dart';
import '../domain/shipment.dart';
import '../domain/shipment_repository.dart';

enum ShipmentsStatus { idle, loading, ready, failure }

/// Loads the deliveries of the client's orders for the Tracking tab and
/// confirms their reception with the client's rating (US35).
class ShipmentsController extends ChangeNotifier {
  ShipmentsController({
    required ShipmentRepository repository,
    required ReceptionRepository reception,
  }) : _repository = repository,
       _reception = reception;

  final ShipmentRepository _repository;
  final ReceptionRepository _reception;

  ShipmentsStatus _status = ShipmentsStatus.idle;
  List<DeliveryShipment> _shipments = const [];
  Object? _error;
  Future<void>? _inFlight;
  bool _disposed = false;
  bool _confirming = false;

  ShipmentsStatus get status => _status;
  Object? get error => _error;

  /// A reception is being sent.
  bool get confirming => _confirming;

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

  /// US35 — Sends the reception (rating optional) and, once the platform
  /// accepts it, marks the delivery as received. Rethrows errors so the
  /// reception screen can show them and let the client retry.
  Future<void> confirmReception(
    DeliveryShipment shipment,
    ReceptionReport report,
  ) async {
    if (!report.isValid) throw ArgumentError('Rating must be 1 to 5');
    _confirming = true;
    _notify();
    try {
      await _reception.confirm(shipment, report);
      shipment
        ..isReceived = true
        ..rating = report.rating
        ..inspectionNotes = report.comment
        ..hasIncidents = report.hasIncidence;
    } finally {
      _confirming = false;
      _notify();
    }
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
