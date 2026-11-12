import 'package:flutter/material.dart';
import '../../../app/fruitlogix_theme.dart';
import '../infrastructure/in_memory_payment_repository.dart';
import 'payment_detail_page.dart';

class PaymentsPage extends StatelessWidget {
  const PaymentsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final repo = InMemoryPaymentRepository();

    return Scaffold(
      backgroundColor: const Color(0xFFE8ECE4), // Fondo verdecito claro original
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'Payments',
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
              color: FruitLogixPalette.forest,
            ),
          ),
          const Text(
            'Balance y pagos pendientes',
            style: TextStyle(color: FruitLogixPalette.forestSoft),
          ),
          const SizedBox(height: 16),

          // Tarjeta de Balance Pendiente
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
                  'Pending balance',
                  style: TextStyle(color: FruitLogixPalette.lime, fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  'S/ ${repo.pendingBalance.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          const Text(
            'INVOICES & TRANSACTIONS',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: FruitLogixPalette.forestSoft,
            ),
          ),
          const SizedBox(height: 10),

          // Lista de pagos
          ...repo.payments.map((payment) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: FruitLogixPalette.forest,
              borderRadius: BorderRadius.circular(20),
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PaymentDetailPage(payment: payment),
                    ),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Row(
                    children: [
                      const Icon(Icons.receipt_long_outlined, color: FruitLogixPalette.lime),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order ${payment.orderId}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'S/ ${payment.amount.toStringAsFixed(2)} · ${payment.status}',
                              style: const TextStyle(color: FruitLogixPalette.muted),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right, color: FruitLogixPalette.lime),
                    ],
                  ),
                ),
              ),
            ),
          )),
        ],
      ),
    );
  }
}