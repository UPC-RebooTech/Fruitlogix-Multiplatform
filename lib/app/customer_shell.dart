import 'package:flutter/material.dart';

import '../contexts/logistics_and_monitoring/infrastructure/in_memory_shipment_repository.dart';
import '../contexts/logistics_and_monitoring/presentation/delivery_tracking_page.dart';
import '../contexts/order_management/presentation/customer_catalog_page.dart';
import '../contexts/order_management/presentation/customer_orders_page.dart';
import '../contexts/iam/domain/auth_session.dart';
import '../contexts/payment_management/application/membership_controller.dart';
import '../contexts/payment_management/domain/invoice.dart';
import '../contexts/payment_management/payment_management_module.dart';
import '../contexts/payment_management/presentation/payment_detail_page.dart';
import '../contexts/payment_management/presentation/payments_page.dart';
import '../contexts/payment_management/presentation/pro_badge.dart';
import '../contexts/payment_management/presentation/pro_membership_page.dart';
import '../contexts/order_management/order_management_module.dart';
import '../contexts/quality_management/domain/incident.dart';
import '../contexts/quality_management/infrastructure/demo_quality_repositories.dart';
import '../contexts/quality_management/presentation/incident_detail_page.dart';
import '../contexts/quality_management/presentation/incidents_page.dart';
import '../contexts/quality_management/presentation/report_incident_page.dart';
import '../contexts/quality_management/quality_management_module.dart';
import '../contexts/profiles_management/infrastructure/in_memory_commercial_client_profile_repository.dart';
import '../contexts/profiles_management/presentation/customer_profile_page.dart';
import '../dashboard/presentation/customer_dashboard_page.dart';
import '../l10n/app_localizations.dart';
import '../shared/ui/components/components.dart';
import '../shared/ui/formatters/date_format.dart';
import '../shared/ui/formatters/initials.dart';
import '../shared/ui/formatters/money_format.dart';
import 'locale_controller.dart';
import '../contexts/profiles_management/domain/commercial_client_profile_repository.dart';

/// Sections reachable from the "More" speed dial. They open inside the
/// shell, keeping both bars visible.
///
/// Reserved for later sprints: messages and biometric sign-in settings.
enum MoreSection { payments, incidents, proPlan, profile }

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
  const CustomerShell({
    required this.localeController,
    this.onSignOut,
    this.session,
    this.paymentModule,
    this.qualityModule,
    this.orderModule,
    super.key,
    this.profileRepository,
  });

  final LocaleController localeController;
  final VoidCallback? onSignOut;
  final CommercialClientProfileRepository? profileRepository;

  /// Signed-in user. Without it (tests, previews) payments use demo data.
  final AuthSession? session;

  /// Overrides the Payment Management wiring (tests).
  final PaymentManagementModule? paymentModule;

  /// Overrides the Quality Management wiring (tests).
  final QualityManagementModule? qualityModule;

  /// Overrides the Order Management wiring (tests).
  final OrderManagementModule? orderModule;

  @override
  State<CustomerShell> createState() => _CustomerShellState();
}

class _CustomerShellState extends State<CustomerShell>
    with WidgetsBindingObserver {
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

  late final CommercialClientProfileRepository _profileRepository =
      widget.profileRepository ??
          InMemoryCommercialClientProfileRepository();
  final _shipmentRepository = InMemoryShipmentRepository();

  late final PaymentManagementModule _payments = widget.paymentModule ??
      (widget.session == null
          ? PaymentManagementModule.demo()
          : PaymentManagementModule.remote(widget.session!));
  bool _paymentsStarted = false;
  ProCheckoutStage _lastProStage = ProCheckoutStage.idle;

  /// Quality Management (EP02 · US11). Demo lots until Order Management
  /// reads real orders; see `qualityRemoteEnabled`.
  late final QualityManagementModule _quality = widget.qualityModule ??
      (qualityRemoteEnabled && widget.session != null
          ? QualityManagementModule.remote(widget.session!, targets: _incidentTargets)
          : QualityManagementModule.demo(targets: _incidentTargets));

  /// Order Management: the signed-in client's orders from the platform API
  /// (demo without session).
  late final OrderManagementModule _orders = widget.orderModule ??
      (widget.session == null
          ? OrderManagementModule.demo()
          : OrderManagementModule.remote(widget.session!));

  /// Orders the client can report about: their orders (newest first). Lots
  /// are demo values until the API links orders to harvest lots.
  late final DemoIncidentTargets _incidentTargets = DemoIncidentTargets(
    extraOrders: () => [
      for (final order in _orders.orders.orders)
        IncidentTarget(
          orderCode: order.code,
          batchId: DemoIncidentTargets.demoBatchFor(order.code),
          productSummary: order.productSummary,
        ),
    ],
  );

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _payments.membership.addListener(_onMembershipChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Reminder texts follow the UI language.
    final l10n = AppLocalizations.of(context);
    _payments.reminders.textBuilder = (invoice) => (
          title: l10n.reminderNotificationTitle(invoice.code),
          body: l10n.reminderNotificationBody(
            formatMoney(invoice.amount, invoice.currency),
            formatNumericDate(invoice.dueDate),
          ),
        );
    if (!_paymentsStarted) {
      _paymentsStarted = true;
      // Not awaited: the dashboard renders at once (US36).
      _payments.start();
      _orders.start();
      _quality.start();
    }
  }

  /// Back in the app: refresh balances and re-evaluate reminders (US70).
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _payments.overview.load();
  }

  /// US30: once the backend confirms the plan, celebrate and show the badge.
  void _onMembershipChanged() {
    if (!mounted) return;
    final stage = _payments.membership.stage;
    final upgraded = stage == ProCheckoutStage.success &&
        _lastProStage != ProCheckoutStage.success;
    _lastProStage = stage;
    setState(() {}); // Top bar badge.
    if (upgraded) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context).proSuccess)),
      );
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _payments.membership.removeListener(_onMembershipChanged);
    if (widget.paymentModule == null) _payments.dispose();
    if (widget.orderModule == null) _orders.dispose();
    if (widget.qualityModule == null) _quality.dispose();
    super.dispose();
  }

  /// Email sent to Stripe: the IAM username when it is an email, otherwise
  /// the profile email.
  String get _billingEmail {
    final username = widget.session?.username ?? '';
    return username.contains('@') ? username : _profileRepository.current.email;
  }

  void _navigateTo(int index) {
    setState(() {
      _section = null;
      _details.clear();
      _selected = index;
    });
  }

  void _openSection(MoreSection section) {
    // A previous "canceled"/"failed" notice should not greet a new visit.
    if (section == MoreSection.proPlan) _payments.membership.acknowledge();
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

  void _openInvoice(Invoice invoice) {
    _openDetail(_DetailPage(
      title: (l10n) => l10n.invoiceTitle(invoice.code),
      builder: (_) => PaymentDetailPage(
        invoice: invoice,
        reminders: _payments.reminders,
      ),
    ));
  }

  void _openIncident(Incident incident) {
    _openDetail(_incidentDetailPage(incident));
  }

  _DetailPage _incidentDetailPage(Incident incident) => _DetailPage(
        title: (l10n) => l10n.qmIncidentTitle(incident.code),
        builder: (_) => IncidentDetailPage(incident: incident),
      );

  /// US11 — Report form inside "More → Incidents" (both bars visible).
  /// [orderCode] fixes the order (from reception or an order card).
  void _openIncidentReport({String? orderCode}) {
    final target =
        orderCode == null ? null : _quality.targetForOrder(orderCode);
    setState(() {
      _section = MoreSection.incidents;
      _details
        ..clear()
        ..add(_DetailPage(
          title: (l10n) => l10n.qmNewIncidentTitle,
          builder: (_) => ReportIncidentPage(
            controller: _quality.incidents,
            targets: _quality.targets,
            picker: _quality.picker,
            initialTarget: target,
            // Back from the new incident returns to the history.
            onSubmitted: (incident) => setState(() {
              _details
                ..clear()
                ..add(_incidentDetailPage(incident));
            }),
          ),
        ));
    });
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
          value: MoreSection.incidents,
          icon: Icons.report_problem_outlined,
          label: l10n.qmIncidentsTitle,
        ),
        CosechaSpeedDialItem(
          value: MoreSection.proPlan,
          icon: Icons.workspace_premium_outlined,
          label: l10n.proTitle,
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
        MoreSection.incidents => l10n.qmIncidentsTitle,
        MoreSection.proPlan => l10n.proTitle,
        MoreSection.profile => l10n.profileTitle,
      };

  Widget _sectionBody(MoreSection section) => switch (section) {
        MoreSection.payments => PaymentsPage(
            overview: _payments.overview,
            reminders: _payments.reminders,
            membership: _payments.membership,
            onOpenInvoice: _openInvoice,
            onOpenPro: () => _openSection(MoreSection.proPlan),
          ),
        MoreSection.incidents => IncidentsPage(
            controller: _quality.incidents,
            onOpenIncident: _openIncident,
            onReport: _openIncidentReport,
          ),
        MoreSection.proPlan => ProMembershipPage(
            controller: _payments.membership,
            email: _billingEmail,
            name: _profileRepository.current.fullName,
          ),
        MoreSection.profile => CustomerProfilePage(
            repository: _profileRepository,
            onSaved: () => setState(() {}),
            onSignOut: widget.onSignOut,
          ),
      };

  Widget _tabBody(int index) => switch (index) {
        _catalogTab => CustomerCatalogPage(
            catalog: _orders.catalog,
            orders: _orders.orders,
            onOrderCreated: () => _navigateTo(_ordersTab),
          ),
        _ordersTab => CustomerOrdersPage(
            orders: _orders.orders,
            onNewOrder: () => _navigateTo(_catalogTab),
            onReportIncident: (orderCode) =>
                _openIncidentReport(orderCode: orderCode),
          ),
        _trackingTab => DeliveryTrackingPage(
            repository: _shipmentRepository,
            onReportIncident: (orderCode) =>
                _openIncidentReport(orderCode: orderCode),
          ),
        _ => CustomerDashboardPage(
            customerName: _profileRepository.current.firstName,
            onNewOrder: () => _navigateTo(_catalogTab),
            onTrack: () => _navigateTo(_trackingTab),
            onPayments: () => _openSection(MoreSection.payments),
            balance: _payments.overview,
            reminders: _payments.reminders,
            orders: _orders.orders,
            onOpenOrders: () => _navigateTo(_ordersTab),
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
      title = profile.businessName.trim().isEmpty
          ? profile.fullName
          : profile.businessName;
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
          badge: _payments.membership.isPro ? const ProBadge(compact: true) : null,
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
