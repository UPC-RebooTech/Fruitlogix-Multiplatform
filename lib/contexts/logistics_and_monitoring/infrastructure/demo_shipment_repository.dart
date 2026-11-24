import '../domain/geofence.dart';
import '../domain/shipment.dart';
import '../domain/shipment_repository.dart';

/// Offline deliveries (no session, widget tests). They match the demo
/// orders ORD-1042 (in transit) and ORD-1040 (scheduled).
class DemoShipmentRepository implements ShipmentRepository {
  DemoShipmentRepository({
    DateTime Function()? clock,
    this.latency = const Duration(milliseconds: 250),
  }) : _clock = clock ?? DateTime.now;

  final DateTime Function() _clock;
  final Duration latency;
  List<DeliveryShipment>? _shipments;

  @override
  Future<List<DeliveryShipment>> fetchMyShipments() async {
    if (latency > Duration.zero) await Future<void>.delayed(latency);
    return _shipments ??= _seed();
  }

  List<DeliveryShipment> _seed() {
    final now = _clock();
    DateTime at(int days, int hour, int minute) =>
        DateTime(now.year, now.month, now.day + days, hour, minute);
    return [
      DeliveryShipment(
        id: 'demo-1',
        trackingNumber: 'TRK-2026-001',
        orderId: 'ORD-1042',
        status: ShipmentStatus.inTransit,
        estimatedArrival: at(0, 15, 45),
        driverName: 'Luis Ramírez',
        driverPhone: '+51 987 111 222',
        vehiclePlate: 'ABC-123',
        vehicleType: 'Reefer truck',
        routeOrigin: 'Piura',
        routeDestination: 'Lima',
        routeDistanceKm: 980,
        itemsSummary: 'Mango Kent (120 kg) • Hass avocado (60 kg)',
        telemetry: TelemetryLog(
          temperatureC: 4.2,
          humidityPercent: 86,
          reeferUnitStatus: 'Active & Stable',
          recordedAt: at(0, 14, 10),
          // ~1.5 km from the demo warehouse (US65).
          position: const GeoPoint(-12.0712, -77.0251),
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
      DeliveryShipment(
        id: 'demo-2',
        trackingNumber: 'TRK-2026-002',
        orderId: 'ORD-1040',
        status: ShipmentStatus.scheduled,
        estimatedArrival: at(2, 10, 0),
        routeOrigin: 'Piura',
        routeDestination: 'Lima',
        itemsSummary: 'Mango Kent (80 kg)',
      ),
    ];
  }
}
