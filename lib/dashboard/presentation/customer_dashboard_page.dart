import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../shared/ui/components/components.dart';
import '../../shared/ui/formatters/money_format.dart';
import '../../shared/ui/theme/theme.dart';

/// Home of the Commercial Client.
///
/// Cosecha hierarchy: priority information first (dark KPI cards, including
/// the pending balance required by US36), then quick actions and active
/// orders in white cards.
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

  // Demo data until the dashboard reads from the bounded contexts.
  static const int _activeOrders = 3;
  static const int _inTransit = 2;
  static const double _pendingBalance = 1450.00;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
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
                    value: '$_activeOrders',
                    icon: Icons.inventory_2_outlined,
                  ),
                ),
                const SizedBox(width: CosechaSpace.xs),
                Expanded(
                  child: CosechaKpiCard(
                    label: l10n.kpiInTransit,
                    value: '$_inTransit',
                    icon: Icons.local_shipping_outlined,
                  ),
                ),
              ],
            ),
            CosechaKpiCard(
              label: l10n.kpiPendingBalance,
              value: formatSoles(_pendingBalance),
              icon: Icons.payments_outlined,
            ),
          ],
        ),
        const SizedBox(height: CosechaSpace.md),

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
          children: [
            _OrderPreview(
              id: 'ORD-1042',
              statusLabel: l10n.orderStatusInTransit,
              status: CosechaStatus.info,
              description:
                  l10n.orderExpectedAt(l10n.productHassAvocado, '14:30'),
            ),
            _OrderPreview(
              id: 'ORD-1040',
              statusLabel: l10n.orderStatusPreparing,
              status: CosechaStatus.neutral,
              description: l10n.orderProcessing(l10n.productKentMango),
            ),
          ],
        ),
      ],
    );
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
  const _OrderPreview({
    required this.id,
    required this.statusLabel,
    required this.status,
    required this.description,
  });

  final String id;
  final String statusLabel;
  final CosechaStatus status;
  final String description;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CosechaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  id,
                  style: CosechaDataText.of(context)
                      .dataMono
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
            style: textTheme.bodyMedium
                ?.copyWith(color: context.cosechaContentSecondary),
          ),
        ],
      ),
    );
  }
}
