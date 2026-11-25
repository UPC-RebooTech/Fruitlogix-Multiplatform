import 'package:flutter/foundation.dart';

import '../domain/geofence.dart';
import '../domain/shipment.dart';
import '../infrastructure/arrival_notifier.dart';
import '../infrastructure/arrivals_store.dart';
import '../infrastructure/warehouse_locator.dart';

/// US65 — Warehouse zone and arrivals list. [check] runs after each
/// deliveries refresh: a truck whose latest position is inside the zone is
/// recorded once and notified on the phone.
class ArrivalsController extends ChangeNotifier {
  ArrivalsController({
    required ArrivalsStore store,
    required ArrivalNotifier notifier,
    required WarehouseLocator locator,
    ArrivalDetector detector = const GeofenceArrivalDetector(),
    DateTime Function()? clock,
  })  : _store = store,
        _detector = detector,
        _notifier = notifier,
        _locator = locator,
        _clock = clock ?? DateTime.now;

  final ArrivalsStore _store;
  final ArrivalNotifier _notifier;
  final WarehouseLocator _locator;
  final ArrivalDetector _detector;
  final DateTime Function() _clock;

  /// Older arrivals are listed but not notified (e.g. the first sync on a
  /// new phone brings past arrivals from the platform).
  static const Duration notifyWindow = Duration(hours: 2);

  WarehouseZone? _zone;
  List<ArrivalRecord> _arrivals = const [];
  bool _loaded = false;
  bool _locating = false;
  bool _disposed = false;
  Future<void>? _loading;
  Future<void> _checks = Future<void>.value();

  /// Localized notification text; set by the shell (follows the UI language).
  ArrivalText Function(ArrivalRecord arrival)? textBuilder;

  WarehouseZone? get zone => _zone;

  /// The platform keeps the warehouse once set; only the demo can remove it.
  bool get canClearZone => _store.canClearZone;

  /// Newest first.
  List<ArrivalRecord> get arrivals => _arrivals;
  bool get loaded => _loaded;

  /// Reading the phone's position to set the zone.
  bool get locating => _locating;

  Future<void> load() => _loading ??= _load();

  Future<void> _load() async {
    try {
      _zone = await _store.loadZone();
      final stored = <ArrivalRecord>[...await _store.loadArrivals()]
        ..sort(_newestFirst);
      _arrivals = List.unmodifiable(stored);
    } catch (error) {
      debugPrint('Arrivals not loaded: $error');
    }
    _loaded = true;
    _notify();
  }

  /// Centres the zone on the phone's current position (the client is at the
  /// warehouse). Throws [LocationException] so the sheet can explain it.
  Future<void> setZoneAtCurrentPosition(double radiusKm) async {
    _locating = true;
    _notify();
    try {
      final center = await _locator.currentPosition();
      await _saveZone(WarehouseZone(center: center, radiusKm: radiusKm));
    } finally {
      _locating = false;
      _notify();
    }
    // Asked here, after a gesture of the client, not at start-up.
    await _notifier.ensureReady();
  }

  Future<void> changeRadius(double radiusKm) async {
    final zone = _zone;
    if (zone == null || zone.radiusKm == radiusKm) return;
    await _saveZone(WarehouseZone(center: zone.center, radiusKm: radiusKm));
  }

  /// Stops the alerts. The arrivals already recorded are kept.
  Future<void> clearZone() async {
    await load();
    _zone = null;
    _notify();
    await _store.saveZone(null);
  }

  /// The zone changes only once the store (the platform) accepted it.
  Future<void> _saveZone(WarehouseZone zone) async {
    await load();
    await _store.saveZone(zone);
    _zone = zone;
    _notify();
  }

  /// Records and notifies the deliveries that entered the zone. Calls run
  /// one after another so a delivery is never recorded twice.
  Future<List<ArrivalRecord>> check(Iterable<DeliveryShipment> shipments) {
    final snapshot = List<DeliveryShipment>.of(shipments);
    final run = _checks.then((_) => _check(snapshot));
    _checks = run.then<void>((_) {}, onError: (_) {});
    return run;
  }

  Future<List<ArrivalRecord>> _check(List<DeliveryShipment> shipments) async {
    await load();
    final zone = _zone;
    if (zone == null || _disposed) return const [];
    final known = {for (final a in _arrivals) a.deliveryId};
    final now = _clock();
    final found = [
      for (final arrival in await _detector.detect(
        zone: zone,
        shipments: shipments,
        alreadyRecorded: known,
        now: now,
      ))
        if (known.add(arrival.deliveryId)) arrival,
    ];
    if (found.isEmpty || _disposed) return const [];
    final merged = [...found, ..._arrivals]..sort(_newestFirst);
    _arrivals = List.unmodifiable(merged);
    _notify();
    await _store.saveArrivals(_arrivals);
    final text = textBuilder;
    if (text != null) {
      for (final arrival in found) {
        if (now.difference(arrival.arrivedAt) > notifyWindow) continue;
        try {
          await _notifier.show(arrival, text(arrival));
        } catch (error) {
          debugPrint('Arrival notification failed: $error');
        }
      }
    }
    return found;
  }

  static int _newestFirst(ArrivalRecord a, ArrivalRecord b) =>
      b.arrivedAt.compareTo(a.arrivedAt);

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
