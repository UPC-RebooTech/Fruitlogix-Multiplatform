import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/payment.dart';
import '../infrastructure/in_memory_payment_repository.dart';
import 'payment_status_view.dart';

/// Payments section (opened from "More"). Consultation only for now.
/// The top bar already shows the section title.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({required this.onOpenPayment, super.key});

  final ValueChanged<Payment> onOpenPayment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final repository = InMemoryPaymentRepository();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CosechaSpace.screenMargin,
        CosechaSpace.md,
        CosechaSpace.screenMargin,
        CosechaSpace.lg,
      ),
      children: [
        CosechaKpiCard(
          label: l10n.kpiPendingBalance,
          value: formatSoles(repository.pendingBalance),
          icon: Icons.payments_outlined,
        ),
        const SizedBox(height: CosechaSpace.md),
        CosechaOverline(l10n.paymentsInvoices),
        const SizedBox(height: CosechaSpace.xs),
        if (repository.payments.isEmpty)
          CosechaEmptyState(
            icon: Icons.receipt_long_outlined,
            title: l10n.paymentsEmpty,
          ),
        for (final payment in repository.payments) ...[
          _PaymentRow(
            payment: payment,
            onTap: () => onOpenPayment(payment),
          ),
          const SizedBox(height: CosechaSpace.xs),
        ],
      ],
    );
  }
}

class _PaymentRow extends StatelessWidget {
  const _PaymentRow({required this.payment, required this.onTap});

  final Payment payment;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = paymentStatusView(payment.status, l10n);

    return CosechaCard(
      radius: CosechaRadius.button,
      padding: const EdgeInsets.all(CosechaSpace.inner),
      onTap: onTap,
      semanticLabel:
          '${l10n.invoiceTitle(payment.id)}, ${formatSoles(payment.amount)}, '
          '${status.label}',
      child: Row(
        children: [
          const CosechaIconBox(icon: Icons.receipt_long_outlined),
          const SizedBox(width: CosechaSpace.inner),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.id,
                  style: data.dataMono.copyWith(
                    color: context.cosechaContent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  formatSoles(payment.amount),
                  style: data.dataMonoSmall
                      .copyWith(color: context.cosechaContent),
                ),
                Text(
                  l10n.paymentDue(payment.dueDate),
                  style: textTheme.bodySmall
                      ?.copyWith(color: context.cosechaContentSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: CosechaSpace.xs),
          CosechaStatusTag(label: status.label, status: status.status),
          Icon(Icons.chevron_right, color: context.cosechaContentSecondary),
        ],
      ),
    );
  }
}
