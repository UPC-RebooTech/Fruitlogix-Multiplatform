import 'package:flutter/material.dart';

import '../../contexts/order_management/application/orders_controller.dart';
import '../../contexts/order_management/domain/commercial_order.dart';
import '../../contexts/order_management/presentation/order_status_view.dart';
import '../../contexts/payment_management/application/financial_overview_controller.dart';
import '../../contexts/payment_management/application/invoice_reminder_service.dart';
import '../../contexts/payment_management/presentation/financial_balance_card.dart';
import '../../contexts/payment_management/presentation/invoice_reminders_card.dart';
import '../../l10n/app_localizations.dart';
import '../../shared/ui/components/components.dart';
import '../../shared/ui/formatters/date_format.dart';
import '../../shared/ui/theme/theme.dart';

/// Home of the Commercial Client.
///
/// Cosecha hierarchy: priority information first (dark KPI cards and the
/// financial balance of US36, loaded from the API), then quick actions and
/// active orders in white cards.
class CustomerDashboardPage extends StatelessWidget {
  const CustomerDashboardPage({
    required this.customerName,
    required this.onNewOrder,
    required this.onTrack,
    required this.onPayments,
    required this.balance,
    required this.reminders,
    required this.orders,
    required this.onOpenOrders,
    super.key,
  });

  /// The client's orders (Order Management BC).
  final OrdersController orders;
  final VoidCallback onOpenOrders;

  /// US36: balance read from the Payment Management BC.
  final FinancialOverviewController balance;

  /// US70: invoices due soon.
  final InvoiceReminderService reminders;

  final String customerName;
  final VoidCallback onNewOrder;
  final VoidCallback onTrack;
  final VoidCallback onPayments;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return ListenableBuilder(
      listenable: orders,
      builder: (context, _) {
        final ordersLoading =
            !orders.hasData && orders.status != OrdersStatus.failure;
        String count(int value) => ordersLoading ? '…' : '$value';
        return ListView(
          padding: const EdgeInsets.fromLTRB(
            CosechaSpace.screenMargin,
            CosechaSpace.md,
            CosechaSpace.screenMargin,
            CosechaSpace.lg,
          ),
          children: [
            CosechaPageHeader(
              overline: l10n.dashboardOverline,
              title: l10n.dashboardWelcome(customerName),
              subtitle: l10n.dashboardSubtitle,
            ),
            const SizedBox(height: CosechaSpace.md),

            _Section(
              title: l10n.dashboardOverviewSection,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: CosechaKpiCard(
                        label: l10n.kpiActiveOrders,
                        value: count(orders.activeCount),
                        icon: Icons.inventory_2_outlined,
                      ),
                    ),
                    const SizedBox(width: CosechaSpace.xs),
                    Expanded(
                      child: CosechaKpiCard(
                        label: l10n.kpiInTransit,
                        value: count(orders.inTransitCount),
                        icon: Icons.local_shipping_outlined,
                      ),
                    ),
                  ],
                ),
                FinancialBalanceCard(
                  controller: balance,
                  onOpenPayments: onPayments,
                ),
              ],
            ),
            const SizedBox(height: CosechaSpace.xs),
            UpcomingRemindersBanner(service: reminders, onTap: onPayments),
            const SizedBox(height: CosechaSpace.sm),

            _Section(
              title: l10n.dashboardQuickActionsSection,
              children: [
                CosechaActionRow(
                  icon: Icons.add_shopping_cart_outlined,
                  title: l10n.actionNewOrder,
                  detail: l10n.actionNewOrderDetail,
                  onTap: onNewOrder,
                ),
                CosechaActionRow(
                  icon: Icons.local_shipping_outlined,
                  title: l10n.actionTrackDelivery,
                  detail: l10n.actionTrackDeliveryDetail,
                  onTap: onTrack,
                ),
                CosechaActionRow(
                  icon: Icons.account_balance_wallet_outlined,
                  title: l10n.actionPayments,
                  detail: l10n.actionPaymentsDetail,
                  onTap: onPayments,
                ),
              ],
            ),
            const SizedBox(height: CosechaSpace.md),

            _Section(
              title: l10n.dashboardActiveOrdersSection,
              children: _activeOrders(context, l10n),
            ),
          ],
        );
      },
    );
  }

  /// Up to three active orders, newest first.
  List<Widget> _activeOrders(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    Widget note(String text) => Text(
      text,
      style: textTheme.bodyMedium?.copyWith(
        color: context.cosechaContentSecondary,
      ),
    );

    if (!orders.hasData && orders.status != OrdersStatus.failure) {
      return const [CosechaProgressBar(value: null)];
    }
    if (orders.status == OrdersStatus.failure && orders.orders.isEmpty) {
      return [
        note(
          orderErrorMessage(orders.error, l10n, fallback: l10n.ordersLoadError),
        ),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: CosechaTextButton(
            label: l10n.qmRetry,
            icon: Icons.refresh,
            onPressed: orders.load,
          ),
        ),
      ];
    }
    final active = orders.activeOrders;
    if (active.isEmpty) return [note(l10n.dashboardNoActiveOrders)];
    return [
      for (final order in active.take(3))
        _OrderPreview(order: order, onTap: onOpenOrders),
    ];
  }
}

/// Overline title followed by its items, 8 apart.
class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        CosechaOverline(title),
        for (final child in children) ...[
          const SizedBox(height: CosechaSpace.xs),
          child,
        ],
      ],
    );
  }
}

class _OrderPreview extends StatelessWidget {
  const _OrderPreview({required this.order, required this.onTap});

  final CommercialOrder order;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final view = orderStatusView(order.status, l10n);
    final id = order.code;
    final statusLabel = view.label;
    final status = view.status;
    final delivery = l10n.orderDeliveryDate(
      formatLongDate(context, order.deliveryDate),
    );
    final description = order.productSummary.isEmpty
        ? delivery
        : '${order.productSummary} · $delivery';
    return CosechaCard(
      onTap: onTap,
      semanticLabel: '$id, $statusLabel, $description',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  style: CosechaDataText.of(context).dataMono
                      .copyWith(color: context.cosechaContent),
                ),
              ),
              const SizedBox(width: CosechaSpace.xs),
              CosechaStatusTag(label: statusLabel, status: status),
            ],
          ),
          const SizedBox(height: CosechaSpace.xs),
          Text(
            description,
            style: textTheme.bodyMedium?.copyWith(
              color: context.cosechaContentSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
