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

/// Certificado de auditoría térmica para cumplimiento fitosanitario y comercial (US71)
class ColdChainCertificate {
  const ColdChainCertificate({
    required this.certificateId,
    required this.optimalRangeLabel,
    required this.averageTempC,
    required this.maxTempRecordedC,
    required this.minTempRecordedC,
    required this.compliancePercentage,
    required this.totalTripHours,
    required this.digitalSignatureHash,
    required this.issuedAt,
  });

  final String certificateId;
  final String optimalRangeLabel; // Ej: "0.5 °C - 5.5 °C"
  final double averageTempC;
  final double maxTempRecordedC;
  final double minTempRecordedC;
  final double compliancePercentage; // Ej: 98.6
  final double totalTripHours;
  final String digitalSignatureHash; // Hash SHA-256 de integridad
  final String issuedAt;
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
    this.certificate,
    this.isReceived = false,
    this.inspectionNotes,
    this.hasIncidents = false,
  });

  final String trackingNumber;
  final String orderId;
  final double shipmentProgress;
  final String estimatedArrival;
  final String transportStatus;
  final TelemetryLog telemetry;
  final List<TrackingEventItem> events;
  final String itemsSummary;
  final ColdChainCertificate? certificate;
  bool isReceived;
  String? inspectionNotes;
  bool hasIncidents;
}