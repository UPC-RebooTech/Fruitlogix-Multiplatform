/// Lifecycle of a delivery as seen by the Commercial Client.
enum ShipmentStatus {
  /// Created, waiting for dispatch.
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
  delivered;

  /// Still on its way or waiting at the dock.
  bool get isActive => this != delivered;

  /// Rough progress for the progress bar (the API has no position-based
  /// progress yet).
  double get progress => switch (this) {
    scheduled => 0.1,
    dispatched => 0.3,
    inTransit => 0.6,
    delayed => 0.6,
    arrived => 0.9,
    delivered => 1,
  };
}

/// Latest cold-chain reading of the reefer.
class TelemetryLog {
  const TelemetryLog({
    required this.temperatureC,
    required this.humidityPercent,
    this.reeferUnitStatus,
    this.recordedAt,
  });

  final double temperatureC;
  final double humidityPercent;

  /// Free text from the reefer unit (demo only).
  final String? reeferUnitStatus;
  final DateTime? recordedAt;
}

/// Route checkpoint (demo only: the API has no named checkpoints yet).
class TrackingEventItem {
  const TrackingEventItem({
    required this.time,
    required this.description,
    required this.isCompleted,
  });

  final String time;
  final String description;
  final bool isCompleted;
}

/// One of the client's orders, used to match deliveries (the deliveries
/// endpoint returns every client's deliveries).
class ShipmentOrderRef {
  const ShipmentOrderRef({
    required this.orderId,
    required this.orderCode,
    this.itemsSummary,
  });

  final int orderId;

  /// Display code (`ORD-0007`), the same one Orders shows.
  final String orderCode;
  final String? itemsSummary;
}

/// The client's orders (provided by Order Management).
typedef ClientOrdersLookup = Future<List<ShipmentOrderRef>> Function();

class DeliveryShipment {
  DeliveryShipment({
    required this.id,
    required this.trackingNumber,
    required this.orderId,
    required this.status,
    this.estimatedArrival,
    this.driverName,
    this.driverPhone,
    this.vehiclePlate,
    this.vehicleType,
    this.routeOrigin,
    this.routeDestination,
    this.routeDistanceKm,
    this.telemetry,
    this.events = const [],
    this.itemsSummary,
    this.isReceived = false,
    this.inspectionNotes,
    this.hasIncidents = false,
  });

  /// Platform delivery id (`12`) or demo id.
  final String id;

  /// Display code: `TRK-0012`.
  final String trackingNumber;

  /// Order display code (`ORD-0007`), as in Orders and Incidents.
  final String orderId;
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

  /// Latest reading; null when the reefer has not reported yet.
  final TelemetryLog? telemetry;
  final List<TrackingEventItem> events;
  final String? itemsSummary;

  bool isReceived;
  String? inspectionNotes;
  bool hasIncidents;

  double get shipmentProgress => isReceived ? 1 : status.progress;

  bool get hasDriver => (driverName ?? '').trim().isNotEmpty;

  bool get canCallDriver =>
      (driverPhone ?? '').replaceAll(RegExp(r'\D'), '').length >= 6;
}
