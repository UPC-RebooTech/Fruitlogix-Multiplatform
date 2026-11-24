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

/// Certificado de auditoría térmica (US71)
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
  final String optimalRangeLabel;
  final double averageTempC;
  final double maxTempRecordedC;
  final double minTempRecordedC;
  final double compliancePercentage;
  final double totalTripHours;
  final String digitalSignatureHash;
  final String issuedAt;
}

/// Trazabilidad agrícola desde la cosecha en fundo hasta la entrega (US72)
class TraceableLotItem {
  const TraceableLotItem({
    required this.lotCode,
    required this.productName,
    required this.variety,
    required this.quantityKg,
    required this.originFarm,
    required this.originRegion,
    required this.harvestDate,
    required this.certifications,
    required this.qualityGrade,
  });

  final String lotCode;
  final String productName;
  final String variety;
  final int quantityKg;
  final String originFarm;
  final String originRegion;
  final String harvestDate;
  final List<String> certifications;
  final String qualityGrade;
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
    required this.lots,
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
  final List<TraceableLotItem> lots;
  final ColdChainCertificate? certificate;
  bool isReceived;
  String? inspectionNotes;
  bool hasIncidents;

  /// Mantiene compatibilidad con vistas existentes como ConfirmReceptionPage
  String get itemsSummary =>
      lots.map((l) => '${l.productName} ${l.variety} (${l.quantityKg} kg)').join(' • ');
}