class TelemetryLog {
  const TelemetryLog({
    required this.temperatureC,
    required this.humidityPercent,
    required this.reeferUnitStatus,
  });

  final double temperatureC;
  final double humidityPercent;
  final String reeferUnitStatus;
}

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

class DeliveryShipment {
  DeliveryShipment({
    required this.trackingNumber,
    required this.orderId,
    required this.shipmentProgress,
    required this.estimatedArrival,
    required this.transportStatus,
    required this.telemetry,
    required this.events,
    required this.itemsSummary,
    this.isReceived = false,
    this.inspectionNotes,
    this.hasIncidents = false,
  });

  final String trackingNumber;
  final String orderId;
  final double shipmentProgress; // 0.0 a 1.0
  final String estimatedArrival;
  final String transportStatus;
  final TelemetryLog telemetry;
  final List<TrackingEventItem> events;
  final String itemsSummary;
  bool isReceived;
  String? inspectionNotes;
  bool hasIncidents;
}