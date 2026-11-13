import 'package:flutter/material.dart';

import '../contexts/logistics_and_monitoring/infrastructure/in_memory_shipment_repository.dart';
import '../contexts/logistics_and_monitoring/presentation/delivery_tracking_page.dart';
import '../contexts/order_management/presentation/customer_catalog_page.dart';
import '../contexts/order_management/presentation/customer_orders_page.dart';
import '../contexts/payment_management/domain/payment.dart';
import '../contexts/payment_management/presentation/payment_detail_page.dart';
import '../contexts/payment_management/presentation/payments_page.dart';
import '../contexts/profiles_management/infrastructure/in_memory_commercial_client_profile_repository.dart';
import '../contexts/profiles_management/presentation/customer_profile_page.dart';
import '../dashboard/presentation/customer_dashboard_page.dart';
import '../l10n/app_localizations.dart';
import '../shared/ui/components/components.dart';
import '../shared/ui/formatters/initials.dart';
import 'locale_controller.dart';

/// Sections reachable from the "More" speed dial. They open inside the
/// shell, keeping both bars visible.
///
/// Reserved for later sprints: incident history, messages, Pro plan
/// (Stripe) and biometric sign-in settings.
enum MoreSection { payments, profile }

/// A detail screen opened inside a section (e.g. an invoice). Detail screens
/// also keep both bars; the top bar back button goes back one level.
class _DetailPage {
  const _DetailPage({required this.title, required this.builder});

  final String Function(AppLocalizations l10n) title;
  final WidgetBuilder builder;
}

/// App-level navigation only. Business logic remains in the bounded contexts.
///
/// Cosecha navigation for the Commercial Client: Home · Catalog · Orders ·
/// Tracking + "More" (Payments, Profile). Profile is also reachable from the
/// avatar in the top bar.
class CustomerShell extends StatefulWidget {
  const CustomerShell({required this.localeController, super.key});

  final LocaleController localeController;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell> {
  static const int _homeTab = 0;
  static const int _catalogTab = 1;
  static const int _ordersTab = 2;
  static const int _trackingTab = 3;

  static const List<CosechaLanguageOption> _languages = [
    CosechaLanguageOption(locale: Locale('en'), code: 'EN', name: 'English'),
    CosechaLanguageOption(locale: Locale('es'), code: 'ES', name: 'Español'),
  ];

  int _selected = _homeTab;

  /// Section opened from "More"; null while a tab is shown.
  MoreSection? _section;

  /// Detail screens opened inside the current section, innermost last.
  final List<_DetailPage> _details = [];

  final _profileRepository = InMemoryCommercialClientProfileRepository();
  final _shipmentRepository = InMemoryShipmentRepository();

  void _navigateTo(int index) {
    setState(() {
      _section = null;
      _details.clear();
      _selected = index;
    });
  }

  void _openSection(MoreSection section) {
    setState(() {
      _section = section;
      _details.clear();
    });
  }

  void _openDetail(_DetailPage page) {
    setState(() => _details.add(page));
  }

  /// Back inside a section: closes the innermost detail, then the section.
  void _goBack() {
    setState(() {
      if (_details.isNotEmpty) {
        _details.removeLast();
      } else {
        _section = null;
      }
    });
  }

  void _openPayment(Payment payment) {
    _openDetail(_DetailPage(
      title: (l10n) => l10n.invoiceTitle(payment.id),
      builder: (_) => PaymentDetailPage(payment: payment),
    ));
  }

  Future<void> _openMore(Rect anchor) async {
    final l10n = AppLocalizations.of(context);
    final section = await showCosechaSpeedDial<MoreSection>(
      context: context,
      anchor: anchor,
      closeLabel: l10n.closeMenu,
      items: [
        CosechaSpeedDialItem(
          value: MoreSection.payments,
          icon: Icons.account_balance_wallet_outlined,
          label: l10n.paymentsTitle,
        ),
        CosechaSpeedDialItem(
          value: MoreSection.profile,
          icon: Icons.storefront_outlined,
          label: l10n.profileTitle,
        ),
      ],
    );
    if (!mounted || section == null) return;
    _openSection(section);
  }

  String _sectionTitle(AppLocalizations l10n, MoreSection section) =>
      switch (section) {
        MoreSection.payments => l10n.paymentsTitle,
        MoreSection.profile => l10n.profileTitle,
      };

  Widget _sectionBody(MoreSection section) => switch (section) {
        MoreSection.payments => PaymentsPage(onOpenPayment: _openPayment),
        MoreSection.profile => CustomerProfilePage(
            repository: _profileRepository,
            onSaved: () => setState(() {}),
          ),
      };

  Widget _tabBody(int index) => switch (index) {
        _catalogTab => CustomerCatalogPage(
            onOrderCreated: () => _navigateTo(_ordersTab),
          ),
        _ordersTab => CustomerOrdersPage(
            onNewOrder: () => _navigateTo(_catalogTab),
          ),
        _trackingTab => DeliveryTrackingPage(repository: _shipmentRepository),
        _ => CustomerDashboardPage(
            customerName: _profileRepository.current.firstName,
            onNewOrder: () => _navigateTo(_catalogTab),
            onTrack: () => _navigateTo(_trackingTab),
            onPayments: () => _openSection(MoreSection.payments),
          ),
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final profile = _profileRepository.current;
    final section = _section;
    final detail = _details.isEmpty ? null : _details.last;

    final String title;
    final Widget body;
    if (section == null) {
      title = profile.businessName;
      body = _tabBody(_selected);
    } else if (detail == null) {
      title = _sectionTitle(l10n, section);
      body = _sectionBody(section);
    } else {
      title = detail.title(l10n);
      body = detail.builder(context);
    }

    return PopScope(
      // System back inside a "More" section goes back one level, then to
      // the previous tab.
      canPop: section == null,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _goBack();
      },
      child: Scaffold(
        appBar: CosechaTopBar(
          title: title,
          subtitle: section == null ? l10n.roleCommercialClient : null,
          initials: initialsOf(profile.fullName),
          onAvatarTap: () => _openSection(MoreSection.profile),
          avatarTooltip: l10n.openProfileTooltip,
          onBack: section == null ? null : _goBack,
          actions: [
            CosechaLanguageButton(
              current: Localizations.localeOf(context),
              options: _languages,
              onSelected: widget.localeController.setLocale,
              tooltip: l10n.languageTooltip,
            ),
            const SizedBox(width: 8),
          ],
        ),
        body: KeyedSubtree(
          key: ValueKey<Object>('${section ?? _selected}/${_details.length}'),
          child: body,
        ),
        bottomNavigationBar: CosechaBottomBar(
          selectedIndex: section == null ? _selected : null,
          moreSelected: section != null,
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
      ),
    );
  }
}
