import 'package:flutter/material.dart';

import '../dashboard/presentation/customer_dashboard_page.dart';
import '../contexts/profiles_management/infrastructure/in_memory_commercial_client_profile_repository.dart';
import '../contexts/profiles_management/presentation/customer_profile_page.dart';
import '../contexts/order_management/presentation/customer_catalog_page.dart';
import 'feature_placeholder_page.dart';

/// App-level navigation only. Business logic remains in the bounded contexts.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  int _selected = 0;
  final _profileRepository = InMemoryCommercialClientProfileRepository();

  void _navigateTo(int index) {
    setState(() => _selected = index);
  }

  void _openPayment() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const Scaffold(
        appBar: _PaymentAppBar(),
        body: FeaturePlaceholderPage(
          title: 'Payments',
          boundedContext: 'Payment Management',
        ),
      ),
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
      const FeaturePlaceholderPage(
          title: 'My orders', boundedContext: 'Order Management'),
      const FeaturePlaceholderPage(
          title: 'Tracking', boundedContext: 'Logistics and Monitoring'),
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

class _PaymentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const _PaymentAppBar();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) => AppBar(title: const Text('Payments'));
}
