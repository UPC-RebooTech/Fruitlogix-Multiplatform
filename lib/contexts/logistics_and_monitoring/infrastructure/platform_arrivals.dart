import '../domain/geofence.dart';
import '../domain/shipment.dart';
import 'arrivals_store.dart';
import 'delivery_json_parser.dart';
import 'fruitlogix_logistics_api.dart';

/// US65 — The warehouse zone lives in the client's profile in the platform
/// (`GET /profiles/me` → `warehouse`, `PUT /profiles/me/warehouse`). The
/// arrivals already seen stay on the phone ([arrivals]) so each one is
/// notified once.
class PlatformArrivalsStore implements ArrivalsStore {
  PlatformArrivalsStore({required this.api, required this.arrivals});

  final FruitLogixLogisticsApi api;
  final ArrivalsStore arrivals;

  /// The platform has no way to remove the warehouse yet.
  @override
  bool get canClearZone => false;

  @override
  Future<WarehouseZone?> loadZone() async {
    try {
      final profile = await api.getMyProfile();
      return profile is Map ? zoneOf(profile['warehouse']) : null;
    } on LogisticsApiException catch (error) {
      // 404: the client has not created the profile yet (no zone).
      if (error.reason == LogisticsApiFailure.notFound) return null;
      rethrow;
    }
  }

  @override
  Future<void> saveZone(WarehouseZone? zone) async {
    if (zone == null) {
      throw UnsupportedError('The platform keeps the warehouse once set');
    }
    await api.putWarehouse({
      'latitude': zone.center.latitude,
      'longitude': zone.center.longitude,
      'radiusKm': zone.radiusKm,
    });
  }

  @override
  Future<List<ArrivalRecord>> loadArrivals() => arrivals.loadArrivals();

  @override
  Future<void> saveArrivals(List<ArrivalRecord> list) =>
      arrivals.saveArrivals(list);

  /// `{ latitude, longitude, radiusKm }`, or null when not configured.
  static WarehouseZone? zoneOf(Object? json) {
    if (json is! Map) return null;
    final lat = json['latitude'], lng = json['longitude'];
    final radius = json['radiusKm'];
    if (lat is! num || lng is! num || radius is! num || radius <= 0) {
      return null;
    }
    final center = GeoPoint(lat.toDouble(), lng.toDouble());
    return center.isValid
        ? WarehouseZone(center: center, radiusKm: radius.toDouble())
        : null;
  }
}

/// The platform detects the arrivals (geofence on each tracking log, or a
/// manual `arrive` by the distributor): `GET /deliveries/arrivals`.
class PlatformArrivalDetector implements ArrivalDetector {
  const PlatformArrivalDetector({required this.api});

  final FruitLogixLogisticsApi api;

  @override
  Future<List<ArrivalRecord>> detect({
    required WarehouseZone zone,
    required List<DeliveryShipment> shipments,
    required Set<String> alreadyRecorded,
    required DateTime now,
  }) async {
    final byId = {for (final s in shipments) s.id: s};
    return [
      for (final json in DeliveryJsonParser.list(await api.getArrivals()))
        ?parse(json, zone: zone, shipments: byId),
    ];
  }

  /// `DeliveryArrivalResource`. The delivery of the list gives the order
  /// code, driver and plate; without it, codes are built from the ids.
  static ArrivalRecord? parse(
    Map<dynamic, dynamic> json, {
    required WarehouseZone? zone,
    required Map<String, DeliveryShipment> shipments,
  }) {
    final id = DeliveryJsonParser.idOf({'id': json['deliveryId']});
    final at = json['arrivedAt'];
    final arrivedAt = at is String ? DateTime.tryParse(at)?.toLocal() : null;
    if (id == null || arrivedAt == null) return null;
    final shipment = shipments['$id'];
    final orderId = DeliveryJsonParser.orderIdOf(json);
    final lat = json['latitude'], lng = json['longitude'];
    final point = lat is num && lng is num
        ? GeoPoint(lat.toDouble(), lng.toDouble())
        : null;
    return ArrivalRecord(
      deliveryId: '$id',
      trackingNumber:
          shipment?.trackingNumber ?? 'TRK-${id.toString().padLeft(4, '0')}',
      orderCode:
          shipment?.orderId ??
          (orderId == null ? '' : 'ORD-${orderId.toString().padLeft(4, '0')}'),
      arrivedAt: arrivedAt,
      distanceKm: zone != null && point != null && point.isValid
          ? zone.center.distanceKmTo(point)
          : null,
      driverName: shipment?.driverName,
      vehiclePlate: shipment?.vehiclePlate,
    );
  }
}
