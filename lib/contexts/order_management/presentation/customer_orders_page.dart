import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/orders_controller.dart';
import '../domain/commercial_order.dart';
import 'order_status_view.dart';

/// The client's orders, read from the platform API (demo without session).
class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({
    required this.orders,
    required this.onNewOrder,
    this.onReportIncident,
    super.key,
  });

  final OrdersController orders;
  final VoidCallback onNewOrder;

  /// Opens the incident report (Quality Management) for an order code.
  final ValueChanged<String>? onReportIncident;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: orders,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final list = orders.orders;
        final loading =
            !orders.hasData && orders.status != OrdersStatus.failure;
        return RefreshIndicator(
          onRefresh: orders.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              CosechaSpace.screenMargin,
              CosechaSpace.md,
              CosechaSpace.screenMargin,
              CosechaSpace.lg,
            ),
            children: [
              CosechaPageHeader(
                title: l10n.ordersTitle,
                subtitle: l10n.ordersSubtitle,
              ),
              const SizedBox(height: CosechaSpace.md),
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(CosechaSpace.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (orders.status == OrdersStatus.failure && list.isEmpty)
                CosechaEmptyState(
                  isError: true,
                  title: orderErrorMessage(
                    orders.error,
                    l10n,
                    fallback: l10n.ordersLoadError,
                  ),
                  action: CosechaTextButton(
                    label: l10n.qmRetry,
                    icon: Icons.refresh,
                    onPressed: orders.load,
                  ),
                )
              else if (list.isEmpty)
                CosechaEmptyState(
                  icon: Icons.receipt_long_outlined,
                  title: l10n.ordersEmptyTitle,
                  message: l10n.ordersEmptyMessage,
                  action: CosechaPrimaryButton(
                    label: l10n.actionNewOrder,
                    icon: Icons.add,
                    onPressed: onNewOrder,
                  ),
                )
              else ...[
                // One primary action per screen.
                CosechaPrimaryButton(
                  label: l10n.actionNewOrder,
                  icon: Icons.add,
                  onPressed: onNewOrder,
                ),
                const SizedBox(height: CosechaSpace.md),
                for (final order in list) ...[
                  _OrderCard(
                    order: order,
                    onReportIncident: onReportIncident == null
                        ? null
                        : () => onReportIncident!(order.code),
                  ),
                  const SizedBox(height: CosechaSpace.xs),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order, this.onReportIncident});

  final CommercialOrder order;
  final VoidCallback? onReportIncident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = orderStatusView(order.status, l10n);
    final date = MaterialLocalizations.of(context)
        .formatMediumDate(order.deliveryDate);

    return CosechaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  order.code,
                  style: data.dataMono.copyWith(
                    color: context.cosechaContent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: CosechaSpace.xs),
              CosechaStatusTag(label: status.label, status: status.status),
            ],
          ),
          const SizedBox(height: CosechaSpace.inner),
          for (final line in order.lines)
            Padding(
              padding: const EdgeInsets.only(bottom: CosechaSpace.xxs),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      line.product.name,
                      style: textTheme.bodyMedium?.copyWith(
                        color: context.cosechaContent,
                      ),
                    ),
                  ),
                  Text(
                    '${line.quantity} ${line.product.unit}',
                    style: data.dataMonoSmall.copyWith(
                      color: context.cosechaContentSecondary,
                    ),
                  ),
                ],
              ),
            ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: CosechaSpace.xs),
            child: Divider(),
          ),
          Row(
            children: [
              Expanded(
                child: Text(
                  l10n.orderReviewTotal,
                  style: textTheme.titleSmall?.copyWith(
                    color: context.cosechaContent,
                  ),
                ),
              ),
              Text(
                formatSoles(order.total),
                style: data.dataMono.copyWith(
                  color: context.cosechaContent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: CosechaSpace.inner),
          CosechaInfoRow(
            icon: Icons.event_outlined,
            label: l10n.deliveryDateLabel,
            value: date,
          ),
          const SizedBox(height: CosechaSpace.xs),
          CosechaInfoRow(
            icon: Icons.place_outlined,
            label: l10n.deliveryAddressLabel,
            value: order.deliveryAddress,
          ),
          if (order.notes != null) ...[
            const SizedBox(height: CosechaSpace.xs),
            CosechaInfoRow(
              icon: Icons.sticky_note_2_outlined,
              label: l10n.orderNotes,
              value: order.notes!,
            ),
          ],
          if (onReportIncident != null) ...[
            const SizedBox(height: CosechaSpace.xs),
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: CosechaTextButton(
                label: l10n.qmReportIncident,
                icon: Icons.report_problem_outlined,
                onPressed: onReportIncident,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
