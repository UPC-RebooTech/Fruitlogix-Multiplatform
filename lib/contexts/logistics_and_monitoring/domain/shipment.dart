import 'geofence.dart';

/// Lifecycle of a delivery as seen by the Commercial Client.
enum ShipmentStatus {
  /// Created, waiting for dispatch (`PendingDispatch`).
  scheduled,

  /// Left the warehouse.
  dispatched,

  /// On the road.
  inTransit,

  /// Running late (the distributor reported a delay).
  delayed,

  /// At the client's dock.
  arrived,

  /// Received.
  delivered,

  /// `Failed` (reserved by the platform) or a status this app does not know.
  failed;

  /// Still on its way or waiting at the dock.
  bool get isActive => this != delivered && this != failed;

  /// Left the warehouse and not received yet: the client can confirm the
  /// reception once it arrives.
  bool get isOnTheWay =>
      this == dispatched || this == inTransit || this == delayed || this == arrived;

  /// Rough progress for the progress bar (the API has no position-based
  /// progress yet).
  double get progress => switch (this) {
    scheduled => 0.1,
    dispatched => 0.3,
    inTransit => 0.6,
    delayed => 0.6,
    arrived => 0.9,
    delivered => 1,
    failed => 0,
  };
}

/// Latest cold-chain reading of the reefer.
class TelemetryLog {
  const TelemetryLog({
    required this.temperatureC,
    required this.humidityPercent,
    this.reeferUnitStatus,
    this.recordedAt,
    this.position,
  });

  final double temperatureC;
  final double humidityPercent;

  /// Free text from the reefer unit (demo only).
  final String? reeferUnitStatus;
  final DateTime? recordedAt;

  /// Where the truck was at [recordedAt] (US65 geofence).
  final GeoPoint? position;
}

/// `deliveryEvent.type` of `GET /deliveries/{id}/events`.
enum DeliveryEventType { created, dispatched, delayed, checkpoint, arrived, delivered, other }

/// Route checkpoint or delivery milestone. Platform events carry a [type]
/// (labelled by the UI) and [occurredAt]; demo events carry fixed texts.
class TrackingEventItem {
  const TrackingEventItem({
    required this.time,
    required this.description,
    required this.isCompleted,
    this.type,
    this.occurredAt,
    this.place,
    this.note,
  });

  final String time;
  final String description;
  final bool isCompleted;
  final DeliveryEventType? type;
  final DateTime? occurredAt;

  /// Checkpoint name (`Peaje Chicama`).
  final String? place;

  /// Delay reason or distributor note.
  final String? note;
}

/// One of the client's orders, used to match deliveries (the deliveries
/// endpoint returns every client's deliveries).
class ShipmentOrderRef {
  const ShipmentOrderRef({
    required this.orderId,
    required this.orderCode,
    this.itemsSummary,
    this.isDelivered = false,
    this.rating,
  });

  final int orderId;

  /// Display code (`ORD-0007`), the same one Orders shows.
  final String orderCode;
  final String? itemsSummary;

  /// The order is already delivered: its reception was confirmed.
  final bool isDelivered;

  /// Stars the client gave at reception (`order.reception.rating`).
  final int? rating;
}

/// The client's orders (provided by Order Management).
typedef ClientOrdersLookup = Future<List<ShipmentOrderRef>> Function();

class DeliveryShipment {
  DeliveryShipment({
    required this.id,
    required this.trackingNumber,
    required this.orderId,
    required this.status,
    this.orderNumber,
    this.estimatedArrival,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.vehicleType,
    this.routeOrigin,
    this.routeDestination,
    this.routeDistanceKm,
    this.dispatchedAt,
    this.arrivedAt,
    this.telemetry,
    this.readings = const [],
    this.events = const [],
    this.itemsSummary,
    this.isReceived = false,
    this.inspectionNotes,
    this.hasIncidents = false,
    this.rating,
  });

  /// Platform delivery id (`12`) or demo id.
  final String id;

  /// Display code: `TRK-0012`.
  final String trackingNumber;

  /// Order display code (`ORD-0007`), as in Orders and Incidents.
  final String orderId;

  /// Platform order id (`7`), used to confirm the reception (US35).
  /// Null for demo deliveries.
  final int? orderNumber;
  final ShipmentStatus status;
  final DateTime? estimatedArrival;

  /// US38 — who transports the order.
  final String? driverName;

  /// US77 — number to call the driver.
  final String? driverPhone;
  final String? vehiclePlate;
  final String? vehicleType;
  final String? routeOrigin;
  final String? routeDestination;
  final double? routeDistanceKm;

  /// When the truck left (`start-dispatch`) and reached the warehouse.
  final DateTime? dispatchedAt;
  final DateTime? arrivedAt;

  /// Latest reading; null when the reefer has not reported yet.
  final TelemetryLog? telemetry;

  /// Every cold-chain reading of the trip, oldest first.
  final List<TelemetryLog> readings;

  /// Cold-chain summary of the trip, computed from [readings]; null
  /// without readings.
  ColdChainCertificate? get coldChainCertificate =>
      ColdChainCertificate.fromReadings(readings);

  /// The latest delay the distributor reported (its `note` is the reason).
  TrackingEventItem? get latestDelay => events
      .where((e) => e.type == DeliveryEventType.delayed)
      .lastOrNull;
  final List<TrackingEventItem> events;
  final String? itemsSummary;

  bool isReceived;
  String? inspectionNotes;
  bool hasIncidents;

  /// US35 — stars given at reception (1–5), null when not rated.
  int? rating;

  double get shipmentProgress => isReceived ? 1 : status.progress;

  bool get hasDriver => (driverName ?? '').trim().isNotEmpty;

  bool get canCallDriver =>
      (driverPhone ?? '').replaceAll(RegExp(r'\D'), '').length >= 6;
}

/// Cold-chain compliance of a trip, from its tracking logs (the platform
/// stores every reading; it issues no certificate of its own).
class ColdChainCertificate {
  const ColdChainCertificate({
    required this.readingsCount,
    required this.averageTempC,
    required this.minTempC,
    required this.maxTempC,
    required this.inRangeCount,
    this.firstReadingAt,
    this.lastReadingAt,
  });

  /// Target range of the reefer for fresh fruit (°C).
  static const double rangeMinC = 1;
  static const double rangeMaxC = 6;

  /// Null without readings.
  static ColdChainCertificate? fromReadings(List<TelemetryLog> readings) {
    if (readings.isEmpty) return null;
    final temps = [for (final r in readings) r.temperatureC];
    final dated = [
      for (final r in readings)
        if (r.recordedAt != null) r.recordedAt!,
    ]..sort();
    return ColdChainCertificate(
      readingsCount: readings.length,
      averageTempC: temps.reduce((a, b) => a + b) / temps.length,
      minTempC: temps.reduce((a, b) => a < b ? a : b),
      maxTempC: temps.reduce((a, b) => a > b ? a : b),
      inRangeCount:
          temps.where((t) => t >= rangeMinC && t <= rangeMaxC).length,
      firstReadingAt: dated.firstOrNull,
      lastReadingAt: dated.lastOrNull,
    );
  }

  final int readingsCount;
  final double averageTempC;
  final double minTempC;
  final double maxTempC;
  final int inRangeCount;
  final DateTime? firstReadingAt;
  final DateTime? lastReadingAt;

  /// Share of readings inside the target range (0–100).
  double get compliancePercent => inRangeCount * 100 / readingsCount;

  bool get isCompliant => inRangeCount == readingsCount;

  /// Time between the first and the last reading.
  Duration? get monitored => firstReadingAt == null || lastReadingAt == null
      ? null
      : lastReadingAt!.difference(firstReadingAt!);
}

/// What the client records when the goods arrive (US35).
class ReceptionReport {
  const ReceptionReport({
    required this.hasIncidence,
    required this.sealAndTemperatureOk,
    this.rating,
    this.comment,
  });

  static const int maxRating = 5;

  /// 1–5 stars; null when the client chooses not to rate (allowed).
  final int? rating;

  /// Optional comment about the service.
  final String? comment;
  final bool hasIncidence;

  /// Seal intact and temperature within range at the dock.
  final bool sealAndTemperatureOk;

  bool get isValid => rating == null || (rating! >= 1 && rating! <= maxRating);
}
