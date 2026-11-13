import 'package:flutter/material.dart';

import '../contexts/logistics_and_monitoring/infrastructure/in_memory_shipment_repository.dart';
import '../contexts/logistics_and_monitoring/presentation/delivery_tracking_page.dart';
import '../contexts/order_management/presentation/customer_catalog_page.dart';
import '../contexts/order_management/presentation/customer_orders_page.dart';
import '../contexts/payment_management/presentation/payments_page.dart';
import '../contexts/profiles_management/infrastructure/in_memory_commercial_client_profile_repository.dart';
import '../contexts/profiles_management/presentation/customer_profile_page.dart';
import '../dashboard/presentation/customer_dashboard_page.dart';
import '../l10n/app_localizations.dart';
import '../shared/ui/components/components.dart';
import 'more_sheet.dart';

/// App-level navigation only. Business logic remains in the bounded contexts.
///
/// Cosecha navigation for the Commercial Client: Home · Catalog · Orders ·
/// Tracking + "More" (Payments, Profile). Profile is also reachable from the
/// avatar in the top bar.
class CustomerShell extends StatefulWidget {
  const CustomerShell({super.key});

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  static const int _homeTab = 0;
  static const int _catalogTab = 1;
  static const int _ordersTab = 2;
  static const int _trackingTab = 3;

  int _selected = _homeTab;
  final _profileRepository = InMemoryCommercialClientProfileRepository();
  final _shipmentRepository = InMemoryShipmentRepository();

  void _navigateTo(int index) {
    setState(() => _selected = index);
  }

  void _openPayments() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (routeContext) => CosechaSubpageScaffold(
        title: AppLocalizations.of(routeContext).paymentsTitle,
        body: const PaymentsPage(),
      ),
    ));
  }

  void _openProfile() {
    Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (routeContext) => CosechaSubpageScaffold(
        title: AppLocalizations.of(routeContext).profileTitle,
        body: CustomerProfilePage(
          repository: _profileRepository,
          onSaved: () => setState(() {}),
        ),
      ),
    ));
  }

  Future<void> _openMore() async {
    final destination = await showMoreSheet(context);
    if (!mounted || destination == null) return;
    switch (destination) {
      case MoreDestination.payments:
        _openPayments();
      case MoreDestination.profile:
        _openProfile();
    }
  }

  static String _initials(String fullName) {
    final words = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList();
    if (words.isEmpty) return '?';
    final first = words.first.characters.first;
    final second = words.length > 1 ? words[1].characters.first : '';
    return (first + second).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = _profileRepository.current;
    final pages = <Widget>[
      CustomerDashboardPage(
        customerName: profile.firstName,
        onNewOrder: () => _navigateTo(_catalogTab),
        onTrack: () => _navigateTo(_trackingTab),
        onPayments: _openPayments,
      ),
      CustomerCatalogPage(onOrderCreated: () => _navigateTo(_ordersTab)),
      CustomerOrdersPage(onNewOrder: () => _navigateTo(_catalogTab)),
      DeliveryTrackingPage(repository: _shipmentRepository),
    ];
    return Scaffold(
      appBar: CosechaTopBar(
        title: profile.businessName,
        subtitle: l10n.roleCommercialClient,
        initials: _initials(profile.fullName),
        onAvatarTap: _openProfile,
        avatarTooltip: l10n.openProfileTooltip,
      ),
      body: pages[_selected],
      bottomNavigationBar: CosechaBottomBar(
        selectedIndex: _selected,
        onSelected: _navigateTo,
        onMore: _openMore,
        moreLabel: l10n.navMore,
        items: [
          CosechaNavItem(
            icon: Icons.home_outlined,
            selectedIcon: Icons.home,
            label: l10n.navHome,
          ),
          CosechaNavItem(
            icon: Icons.storefront_outlined,
            selectedIcon: Icons.storefront,
            label: l10n.navCatalog,
          ),
          CosechaNavItem(
            icon: Icons.receipt_long_outlined,
            selectedIcon: Icons.receipt_long,
            label: l10n.navOrders,
          ),
          CosechaNavItem(
            icon: Icons.local_shipping_outlined,
            selectedIcon: Icons.local_shipping,
            label: l10n.navTracking,
          ),
        ],
      ),
    );
  }
}
