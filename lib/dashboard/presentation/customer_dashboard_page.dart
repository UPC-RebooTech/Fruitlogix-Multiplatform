import 'package:flutter/material.dart';

import '../../app/fruitlogix_theme.dart';

/// Initial customer dashboard adapted from the previous FruitLogix web app.
/// All numbers shown here are DEMO values, not live backend responses.
class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({
    required this.customerName,
    required this.onNewOrder,
    required this.onTrack,
    required this.onPayments,
    super.key,
  });

  final String customerName;
  final VoidCallback onNewOrder;
  final VoidCallback onTrack;
  final VoidCallback onPayments;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(18),
      children: [
        const Row(children: [
          Icon(Icons.circle, size: 10, color: Color(0xFF36C77D)),
          SizedBox(width: 8),
          Text('DEMO DATA',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
        ]),
        const SizedBox(height: 12),
        Text('Welcome, $customerName',
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 29,
              color: FruitLogixPalette.forest,
            )),
        const Text('Overview of your commercial activity',
            style: TextStyle(color: FruitLogixPalette.forestSoft)),
        const SizedBox(height: 24),
        const _SectionHeader('QUICK ACTIONS'),
        const SizedBox(height: 10),
        _ActionTile(
          title: 'New order',
          subtitle: 'Browse available fruits',
          icon: Icons.add_shopping_cart,
          onTap: onNewOrder,
        ),
        const SizedBox(height: 8),
        _ActionTile(
          title: 'Track delivery',
          subtitle: 'View shipment status',
          icon: Icons.location_on_outlined,
          onTap: onTrack,
        ),
        const SizedBox(height: 8),
        _ActionTile(
          title: 'Payments',
          subtitle: 'Review pending balance',
          icon: Icons.account_balance_wallet_outlined,
          onTap: onPayments,
        ),
        const SizedBox(height: 26),
        const _SectionHeader('COMMERCIAL OVERVIEW'),
        const SizedBox(height: 10),
        const Row(children: [
          Expanded(child: _MetricCard(label: 'Active orders', value: '3', icon: Icons.inventory_2_outlined)),
          SizedBox(width: 10),
          Expanded(child: _MetricCard(label: 'In transit', value: '2', icon: Icons.local_shipping_outlined)),
        ]),
        const SizedBox(height: 10),
        const _MetricCard(
          label: 'Pending balance',
          value: 'S/ 1,450.00',
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: 26),
        const _SectionHeader('ACTIVE ORDERS'),
        const SizedBox(height: 10),
        const _OrderPreview(
          id: 'ORD-1042',
          status: 'IN TRANSIT',
          description: 'Hass avocado · Expected 14:30',
        ),
        const SizedBox(height: 10),
        const _OrderPreview(
          id: 'ORD-1040',
          status: 'PREPARING',
          description: 'Kent mango · Order processing',
        ),
        const SizedBox(height: 18),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.title);
  final String title;

  @override
  Widget build(BuildContext context) => Text(
        title,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 1,
          color: FruitLogixPalette.forestSoft,
        ),
      );
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: FruitLogixPalette.forest,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            child: Row(
              children: [
                Icon(icon, color: FruitLogixPalette.lime),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          )),
                      Text(subtitle,
                          style: const TextStyle(color: FruitLogixPalette.muted)),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right, color: FruitLogixPalette.lime),
              ],
            ),
          ),
        ),
      );
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value, required this.icon});
  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FruitLogixPalette.forest,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: FruitLogixPalette.lime, size: 23),
            const SizedBox(height: 12),
            Text(label,
                style: const TextStyle(
                  color: FruitLogixPalette.muted,
                  fontSize: 12,
                )),
            const SizedBox(height: 3),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
        ),
      );
}

class _OrderPreview extends StatelessWidget {
  const _OrderPreview({
    required this.id,
    required this.status,
    required this.description,
  });
  final String id;
  final String status;
  final String description;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: FruitLogixPalette.forestSoft,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Expanded(
                child: Text(id,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    )),
              ),
              Text(status,
                  style: const TextStyle(
                    color: FruitLogixPalette.lime,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  )),
            ]),
            const SizedBox(height: 7),
            Text(description,
                style: const TextStyle(color: FruitLogixPalette.muted)),
          ],
        ),
      );
}
