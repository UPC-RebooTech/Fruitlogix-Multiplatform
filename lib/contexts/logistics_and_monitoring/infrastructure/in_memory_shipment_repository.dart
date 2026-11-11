import '../domain/shipment.dart';

class InMemoryShipmentRepository {
  final List<DeliveryShipment> _shipments = [
    DeliveryShipment(
      trackingNumber: 'TRK-2026-001',
      orderId: 'ORD-1042',
      shipmentProgress: 0.75,
      estimatedArrival: 'Today, 03:45 PM',
      transportStatus: 'In Transit • Reefer Truck (Plate ABC-123)',
      itemsSummary: 'Mango Kent (2,500 kg) • Palta Hass (1,200 kg)',
      telemetry: const TelemetryLog(
        temperatureC: 4.2,
        humidityPercent: 86.0,
        reeferUnitStatus: 'Active & Stable',
      ),
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