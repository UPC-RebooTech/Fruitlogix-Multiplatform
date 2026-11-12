import 'package:flutter/material.dart';
import '../../../app/fruitlogix_theme.dart';
import '../domain/payment.dart';

class PaymentDetailPage extends StatelessWidget {
  final Payment payment;

  const PaymentDetailPage({super.key, required this.payment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECE4),
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FruitLogix', style: TextStyle(fontWeight: FontWeight.w800)),
            Text('COMMERCIAL CLIENT', style: TextStyle(fontSize: 10, letterSpacing: 1.2)),
          ],
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Payment Detail',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: FruitLogixPalette.forest,
            ),
          ),
          const Text(
            'Detalle de pago referencial',
            style: TextStyle(color: FruitLogixPalette.forestSoft),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: FruitLogixPalette.forest,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Payment detail',
                  style: TextStyle(color: FruitLogixPalette.lime, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'Order ${payment.orderId}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _DetailCard(label: 'Payment status', value: payment.status),
          const SizedBox(height: 10),
          _DetailCard(label: 'Amount due', value: 'S/ ${payment.amount.toStringAsFixed(2)}'),
          const SizedBox(height: 10),
          _DetailCard(label: 'Due date', value: payment.dueDate),
          const SizedBox(height: 10),
          _DetailCard(label: 'Payment method', value: payment.method),
          const SizedBox(height: 24),
          FilledButton.icon(
            style: FilledButton.styleFrom(
              backgroundColor: FruitLogixPalette.forest,
              foregroundColor: FruitLogixPalette.lime,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Simulación de pago registrada con éxito')),
              );
            },
            icon: const Icon(Icons.check_circle_outline),
            label: const Text('Simular confirmación de pago', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _DetailCard extends StatelessWidget {
  const _DetailCard({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFD0DCD0)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: FruitLogixPalette.forest)),
      ],
    ),
  );
}