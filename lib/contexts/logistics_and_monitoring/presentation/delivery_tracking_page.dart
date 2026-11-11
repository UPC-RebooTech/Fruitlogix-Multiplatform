import 'package:flutter/material.dart';
import '../../../app/fruitlogix_theme.dart';
import '../domain/shipment.dart';
import '../infrastructure/in_memory_shipment_repository.dart';
import 'confirm_reception_page.dart';

class DeliveryTrackingPage extends StatefulWidget {
  const DeliveryTrackingPage({required this.repository, super.key});

  final InMemoryShipmentRepository repository;

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  @override
  Widget build(BuildContext context) {
    final shipments = widget.repository.getActiveShipments();
    if (shipments.isEmpty) {
      return const Center(child: Text('No active shipments.'));
    }

    final shipment = shipments.first;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Text(
          'Delivery Tracking',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: FruitLogixPalette.forest,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Track live temperature and logistics stages of your orders.',
          style: TextStyle(fontSize: 12, color: Colors.black54),
        ),
        const SizedBox(height: 16),

        // Tarjeta Header: Track Delivery
        _SectionCard(
          title: 'Track delivery',
          subtitle: 'Tracking ID: ${shipment.trackingNumber} (${shipment.orderId})',
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Shipment progress',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.black54),
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: shipment.shipmentProgress,
                  backgroundColor: FruitLogixPalette.background,
                  valueColor: const AlwaysStoppedAnimation<Color>(FruitLogixPalette.lime),
                  minHeight: 8,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Estimated arrival:', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  Text(shipment.estimatedArrival,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Transport status:', style: TextStyle(fontSize: 12, color: Colors.black87)),
                  Expanded(
                    child: Text(
                      shipment.transportStatus,
                      textAlign: TextAlign.end,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Tarjeta Cold-chain conditions
        _SectionCard(
          title: 'Cold-chain conditions',
          subtitle: 'IoT Reefer Telemetry',
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _TelemetryTile(
                icon: Icons.thermostat,
                label: 'Temperature',
                value: '${shipment.telemetry.temperatureC} °C',
                color: const Color(0xFF2E7D32),
              ),
              _TelemetryTile(
                icon: Icons.water_drop_outlined,
                label: 'Humidity',
                value: '${shipment.telemetry.humidityPercent} %',
                color: FruitLogixPalette.forest,
              ),
              _TelemetryTile(
                icon: Icons.ac_unit,
                label: 'Reefer Unit',
                value: shipment.telemetry.reeferUnitStatus,
                color: FruitLogixPalette.forestSoft,
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        // Tarjeta Tracking events
        _SectionCard(
          title: 'Tracking events',
          subtitle: 'Route checkpoints & geofences',
          child: Column(
            children: shipment.events.map((event) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: [
                    Icon(
                      event.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
                      size: 18,
                      color: event.isCompleted ? const Color(0xFF2E7D32) : Colors.grey,
                    ),
                    const SizedBox(width: 8),
                    Text(event.time,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        event.description,
                        style: TextStyle(
                          fontSize: 12,
                          color: event.isCompleted ? Colors.black87 : Colors.black45,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 16),

        // Botón Confirm reception
        ElevatedButton(
          onPressed: shipment.isReceived
              ? null
              : () async {
            await Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) => ConfirmReceptionPage(
                shipment: shipment,
                onConfirmed: (notes, incidents) {
                  setState(() {
                    widget.repository.markAsReceived(
                      shipment.trackingNumber,
                      notes: notes,
                      incidents: incidents,
                    );
                  });
                },
              ),
            ));
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: shipment.isReceived ? Colors.grey[300] : FruitLogixPalette.lime,
            foregroundColor: FruitLogixPalette.forest,
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            shipment.isReceived ? 'Reception Completed ✓' : 'Confirm reception',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ),
      ],
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.subtitle, required this.child});
  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: FruitLogixPalette.forest,
              ),
            ),
            Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.black45)),
            const Divider(height: 18),
            child,
          ],
        ),
      ),
    );
  }
}

class _TelemetryTile extends StatelessWidget {
  const _TelemetryTile({required this.icon, required this.label, required this.value, required this.color});
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: color, size: 22),
        const SizedBox(height: 4),
        Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
        Text(label, style: const TextStyle(fontSize: 10, color: Colors.black45)),
      ],
    );
  }
}