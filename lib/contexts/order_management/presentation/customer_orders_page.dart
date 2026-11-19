import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/commercial_order.dart';
import '../infrastructure/in_memory_order_repository.dart';
import 'order_status_view.dart';

class CustomerOrdersPage extends StatelessWidget {
  const CustomerOrdersPage({required this.onNewOrder, super.key});

  final VoidCallback onNewOrder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = InMemoryOrderRepository.instance;
    return AnimatedBuilder(
      animation: repository,
      builder: (context, _) {
        final orders = repository.orders;
        return ListView(
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
            if (orders.isEmpty)
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
              for (final order in orders) ...[
                _OrderCard(order: order),
                const SizedBox(height: CosechaSpace.xs),
              ],
            ],
          ],
        );
      },
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({required this.order});

  final CommercialOrder order;

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
                  order.id,
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
                      style: textTheme.bodyMedium
                          ?.copyWith(color: context.cosechaContent),
                    ),
                  ),
                  Text(
                    '${line.quantity} ${line.product.unit}',
                    style: data.dataMonoSmall
                        .copyWith(color: context.cosechaContentSecondary),
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
                  style: textTheme.titleSmall
                      ?.copyWith(color: context.cosechaContent),
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
        ],
      ),
    );
  }
}
