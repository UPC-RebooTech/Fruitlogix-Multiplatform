import 'dart:math' as math;

import 'package:flutter/foundation.dart';

import 'shipment.dart';

/// A position on Earth (WGS84 degrees).
@immutable
class GeoPoint {
  const GeoPoint(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  bool get isValid =>
      latitude.abs() <= 90 && longitude.abs() <= 180 && !(latitude == 0 && longitude == 0);

  /// Great-circle (haversine) distance in kilometres.
  double distanceKmTo(GeoPoint other) {
    const earthRadiusKm = 6371.0;
    double rad(double degrees) => degrees * math.pi / 180;
    final dLat = rad(other.latitude - latitude);
    final dLng = rad(other.longitude - longitude);
    final a = math.pow(math.sin(dLat / 2), 2) +
        math.cos(rad(latitude)) * math.cos(rad(other.latitude)) * math.pow(math.sin(dLng / 2), 2);
    return 2 * earthRadiusKm * math.asin(math.min(1, math.sqrt(a)));
  }

  @override
  bool operator ==(Object other) =>
      other is GeoPoint && other.latitude == latitude && other.longitude == longitude;

  @override
  int get hashCode => Object.hash(latitude, longitude);
}

/// US65 — Geofence around the client's warehouse.
@immutable
class WarehouseZone {
  const WarehouseZone({required this.center, required this.radiusKm});

  /// Radii the client can choose.
  static const List<double> radiiKm = [1, 3, 5];
  static const double defaultRadiusKm = 3;

  final GeoPoint center;
  final double radiusKm;

  bool contains(GeoPoint point) => center.distanceKmTo(point) <= radiusKm;

  Map<String, Object?> toJson() => {
        'lat': center.latitude,
        'lng': center.longitude,
        'radiusKm': radiusKm,
      };

  static WarehouseZone? fromJson(Object? json) {
    if (json is! Map) return null;
    final lat = json['lat'], lng = json['lng'], radius = json['radiusKm'];
    if (lat is! num || lng is! num || radius is! num || radius <= 0) return null;
    final center = GeoPoint(lat.toDouble(), lng.toDouble());
    return center.isValid ? WarehouseZone(center: center, radiusKm: radius.toDouble()) : null;
  }
}

/// A truck that entered the warehouse zone (the arrivals list).
@immutable
class ArrivalRecord {
  const ArrivalRecord({
    required this.deliveryId,
    required this.trackingNumber,
    required this.orderCode,
    required this.arrivedAt,
    required this.distanceKm,
    this.driverName,
    this.vehiclePlate,
  });

  final String deliveryId;
  final String trackingNumber;
  final String orderCode;

  /// When the app detected it inside the zone.
  final DateTime arrivedAt;
  final double distanceKm;
  final String? driverName;
  final String? vehiclePlate;

  Map<String, Object?> toJson() => {
        'deliveryId': deliveryId,
        'trackingNumber': trackingNumber,
        'orderCode': orderCode,
        'arrivedAt': arrivedAt.toUtc().toIso8601String(),
        'distanceKm': distanceKm,
        'driverName': driverName,
        'vehiclePlate': vehiclePlate,
      };

  static ArrivalRecord? fromJson(Object? json) {
    if (json is! Map) return null;
    final id = json['deliveryId'], at = DateTime.tryParse('${json['arrivedAt']}');
    if (id is! String || at == null) return null;
    return ArrivalRecord(
      deliveryId: id,
      trackingNumber: '${json['trackingNumber'] ?? id}',
      orderCode: '${json['orderCode'] ?? ''}',
      arrivedAt: at.toLocal(),
      distanceKm: (json['distanceKm'] as num?)?.toDouble() ?? 0,
      driverName: json['driverName'] as String?,
      vehiclePlate: json['vehiclePlate'] as String?,
    );
  }
}

/// Deliveries on their way whose latest position is inside [zone] and that
/// were not recorded yet. Each delivery is recorded once.
List<ArrivalRecord> detectArrivals({
  required WarehouseZone zone,
  required Iterable<DeliveryShipment> shipments,
  required Set<String> alreadyRecorded,
  required DateTime now,
}) {
  return [
    for (final shipment in shipments)
      if (!alreadyRecorded.contains(shipment.id) &&
          !shipment.isReceived &&
          shipment.status != ShipmentStatus.delivered &&
          shipment.status != ShipmentStatus.scheduled)
        if (shipment.telemetry?.position case final position?)
          if (position.isValid && zone.contains(position))
            ArrivalRecord(
              deliveryId: shipment.id,
              trackingNumber: shipment.trackingNumber,
              orderCode: shipment.orderId,
              arrivedAt: now,
              distanceKm: zone.center.distanceKmTo(position),
              driverName: shipment.driverName,
              vehiclePlate: shipment.vehiclePlate,
            ),
  ];
}
