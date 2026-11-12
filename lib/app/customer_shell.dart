import 'package:flutter/material.dart';

import '../dashboard/presentation/customer_dashboard_page.dart';
import '../contexts/profiles_management/infrastructure/in_memory_commercial_client_profile_repository.dart';
import '../contexts/profiles_management/presentation/customer_profile_page.dart';
import '../contexts/order_management/presentation/customer_catalog_page.dart';
import '../contexts/order_management/presentation/customer_orders_page.dart';
import '../contexts/logistics_and_monitoring/infrastructure/in_memory_shipment_repository.dart';
import '../contexts/logistics_and_monitoring/presentation/delivery_tracking_page.dart';
import '../contexts/payment_management/presentation/payments_page.dart';

/// App-level navigation only. Business logic remains in the bounded contexts.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _selected = 0;
  final _profileRepository = InMemoryCommercialClientProfileRepository();
  final _shipmentRepository = InMemoryShipmentRepository();

  void _navigateTo(int index) {
    setState(() => _selected = index);
  }

  void _openPayment() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const PaymentsPage(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final pages = <Widget>[
      CustomerDashboardPage(
        customerName: _profileRepository.current.firstName,
        onNewOrder: () => _navigateTo(1),
        onTrack: () => _navigateTo(3),
        onPayments: _openPayment,
      ),
      CustomerCatalogPage(onOrderCreated: () => _navigateTo(2)),
      CustomerOrdersPage(onNewOrder: () => _navigateTo(1)),
      DeliveryTrackingPage(repository: _shipmentRepository),
      CustomerProfilePage(
        repository: _profileRepository,
        onSaved: () => setState(() {}),
      ),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('FruitLogix',
                style: TextStyle(fontWeight: FontWeight.w800)),
            Text('COMMERCIAL CLIENT',
                style: TextStyle(fontSize: 10, letterSpacing: 1.2)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => _navigateTo(4),
            icon: const Icon(Icons.account_circle_outlined),
          ),
        ],
      ),
      body: pages[_selected],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selected,
        onDestinationSelected: _navigateTo,
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.storefront_outlined), label: 'Catalog'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Orders'),
          NavigationDestination(icon: Icon(Icons.local_shipping_outlined), label: 'Tracking'),
          NavigationDestination(icon: Icon(Icons.person_outline), label: 'Profile'),
        ],
      ),
    );
  }
}