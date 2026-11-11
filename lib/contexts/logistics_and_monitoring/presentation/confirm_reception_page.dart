import 'package:flutter/material.dart';
import '../../../app/fruitlogix_theme.dart';
import '../domain/shipment.dart';

class ConfirmReceptionPage extends StatefulWidget {
  const ConfirmReceptionPage({
    required this.shipment,
    required this.onConfirmed,
    super.key,
  });

  final DeliveryShipment shipment;
  final void Function(String notes, bool hasIncidents) onConfirmed;

  @override
  State<ConfirmReceptionPage> createState() => _ConfirmReceptionPageState();
}

class _ConfirmReceptionPageState extends State<ConfirmReceptionPage> {
  final _notesController = TextEditingController();
  bool _hasIncidents = false;
  bool _inspectionAccepted = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Reception'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Banner de estado
          Card(
            color: FruitLogixPalette.forestSoft,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery status',
                    style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Arrived at Dock • ${widget.shipment.trackingNumber}',
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Productos Recibidos
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Received products',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: FruitLogixPalette.forest),
                  ),
                  const SizedBox(height: 6),
                  Text(widget.shipment.itemsSummary, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                  const Divider(height: 20),
                  Text('Order reference: ${widget.shipment.orderId}', style: const TextStyle(fontSize: 11, color: Colors.black45)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Inspección de Recepción
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Inspect delivery',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: FruitLogixPalette.forest),
                  ),
                  const SizedBox(height: 6),
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Cargo seal & temperature compliant', style: TextStyle(fontSize: 13)),
                    subtitle: Text('Arrival Temp: ${widget.shipment.telemetry.temperatureC} °C', style: const TextStyle(fontSize: 11)),
                    value: _inspectionAccepted,
                    activeThumbColor: FruitLogixPalette.forest,
                    onChanged: (v) => setState(() => _inspectionAccepted = v),
                  ),
                  const Divider(height: 16),
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Report incident (damaged fruit or delayed cargo)', style: TextStyle(fontSize: 13)),
                    value: _hasIncidents,
                    activeColor: Colors.red[800],
                    onChanged: (v) => setState(() => _hasIncidents = v ?? false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Observaciones
          Card(
            color: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Any incident? / Notes',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: FruitLogixPalette.forest),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _notesController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      hintText: 'Enter cargo inspection observations...',
                      border: OutlineInputBorder(),
                      contentPadding: EdgeInsets.all(10),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Botón Confirm Receipt
          ElevatedButton(
            onPressed: () {
              widget.onConfirmed(_notesController.text.trim(), _hasIncidents);
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reception confirmed successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: FruitLogixPalette.lime,
              foregroundColor: FruitLogixPalette.forest,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Confirm receipt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
        ],
      ),
    );
  }
}