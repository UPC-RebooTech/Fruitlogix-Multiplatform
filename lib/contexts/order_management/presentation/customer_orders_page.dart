import 'package:flutter/material.dart';

import '../../../app/fruitlogix_theme.dart';
import '../infrastructure/in_memory_order_repository.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({required this.onNewOrder, super.key});
  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    final repository = InMemoryOrderRepository.instance;
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final orders = repository.orders;
        return ListView(
          padding: const EdgeInsets.all(18),
          children: [
            Row(children: [
              const Expanded(
                child: Text('My orders',
                    style: TextStyle(
                      color: FruitLogixPalette.forest,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              FilledButton(
                onPressed: onNewOrder,
                child: const Text('New order'),
              ),
            ]),
            const SizedBox(height: 10),
            const Text('Session-only demo orders — not synchronized with backend.'),
            const SizedBox(height: 20),
            if (orders.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(32),
                  child: Text('No demo orders yet. Add products in the catalog.'),
                ),
              ),
            for (final order in orders) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [
                        Expanded(
                          child: Text(order.id,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              )),
                        ),
                        Text(order.status,
                            style: const TextStyle(color: FruitLogixPalette.lime)),
                      ]),
                      const SizedBox(height: 8),
                      for (final line in order.lines)
                        Text('${line.product.name} · ${line.quantity} ${line.product.unit}',
                            style: const TextStyle(color: FruitLogixPalette.muted)),
                      const SizedBox(height: 10),
                      Text('S/ ${order.total.toStringAsFixed(2)}',
                          style: const TextStyle(
                            color: FruitLogixPalette.lime,
                            fontWeight: FontWeight.bold,
                            fontSize: 22,
                          )),
                      const SizedBox(height: 5),
                      Text('Delivery: ${order.deliveryDate.day}/${order.deliveryDate.month}/${order.deliveryDate.year}',
                          style: const TextStyle(color: Colors.white)),
                      Text(order.deliveryAddress,
                          style: const TextStyle(color: FruitLogixPalette.muted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ],
        );
      },
    );
  }
}
