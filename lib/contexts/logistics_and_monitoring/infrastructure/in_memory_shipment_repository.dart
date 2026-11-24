import '../domain/shipment.dart';

class InMemoryShipmentRepository {
  final List<DeliveryShipment> _shipments = [
    DeliveryShipment(
      trackingNumber: 'TRK-2026-001',
      orderId: 'ORD-1042',
      shipmentProgress: 0.75,
      estimatedArrival: 'Today, 03:45 PM',
      transportStatus: 'In Transit • Reefer Truck (Plate ABC-123)',
      telemetry: const TelemetryLog(
        temperatureC: 4.2,
        humidityPercent: 86.0,
        reeferUnitStatus: 'Active & Stable',
      ),
      certificate: const ColdChainCertificate(
        certificateId: 'CERT-CC-2026-0941',
        optimalRangeLabel: '1.0 °C – 6.0 °C (Palta & Mango)',
        averageTempC: 4.1,
        maxTempRecordedC: 5.3,
        minTempRecordedC: 3.8,
        compliancePercentage: 99.2,
        totalTripHours: 9.5,
        digitalSignatureHash: 'a7f3c4e912b590df88210e4a77bc89d13f9901ae',
        issuedAt: '2026-11-21 14:30 UTC-5',
      ),
      lots: const [
        TraceableLotItem(
          lotCode: 'LOT-2026-MK04',
          productName: 'Mango',
          variety: 'Kent',
          quantityKg: 2500,
          originFarm: 'Campos del Norte',
          originRegion: 'Valle del Chira, Piura',
          harvestDate: '18 Nov 2026',
          certifications: ['GlobalG.A.P.', 'SENASA Certificado'],
          qualityGrade: 'Exportación Extra (Calibre 8)',
        ),
        TraceableLotItem(
          lotCode: 'LOT-2026-PH12',
          productName: 'Palta',
          variety: 'Hass',
          quantityKg: 1200,
          originFarm: 'Fundo Santa Rosa',
          originRegion: 'Caraz, Áncash',
          harvestDate: '19 Nov 2026',
          certifications: ['GlobalG.A.P.', 'Rainforest Alliance'],
          qualityGrade: 'Exportación Grado 1 (Materia Seca >23%)',
        ),
      ],
      events: const [
        TrackingEventItem(
          time: '06:00 AM',
          description: 'Dispatched from Piura Packing Facility',
          isCompleted: true,
        ),
        TrackingEventItem(
          time: '11:30 AM',
          description: 'Geofence Checkpoint Chiclayo Cleared',
          isCompleted: true,
        ),
        TrackingEventItem(
          time: '02:15 PM',
          description: 'Approaching Destination Warehouse Lima',
          isCompleted: true,
        ),
        TrackingEventItem(
          time: '03:45 PM',
          description: 'Final Delivery & Dock Inspection',
          isCompleted: false,
        ),
      ],
    ),
  ];

  List<DeliveryShipment> getActiveShipments() => _shipments;

  void markAsReceived(String trackingNumber, {String? notes, bool incidents = false}) {
    final shipment = _shipments.firstWhere((s) => s.trackingNumber == trackingNumber);
    shipment.isReceived = true;
    shipment.inspectionNotes = notes;
    shipment.hasIncidents = incidents;
  }
}