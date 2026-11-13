import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/payment.dart';
import 'payment_status_view.dart';

/// Invoice detail, shown inside the shell (both bars visible). The top bar
/// shows the invoice title and the back button.
class PaymentDetailPage extends StatelessWidget {
  const PaymentDetailPage({required this.payment, super.key});

  final Payment payment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = CosechaDataText.of(context);
    final colors = CosechaStatusColors.of(context);
    final status = paymentStatusView(payment.status, l10n);

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CosechaSpace.screenMargin,
        CosechaSpace.md,
        CosechaSpace.screenMargin,
        CosechaSpace.lg,
      ),
      children: [
        CosechaCard(
          tone: CosechaCardTone.dark,
          hero: true,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: CosechaOverline(l10n.invoiceOverline)),
                  CosechaStatusTag(label: status.label, status: status.status),
                ],
              ),
              const SizedBox(height: CosechaSpace.xs),
              Text(
                payment.id,
                style: data.dataMono.copyWith(color: colors.onDarkSecondary),
              ),
              const SizedBox(height: CosechaSpace.xxs),
              Semantics(
                label: '${l10n.invoiceAmount}: ${formatSoles(payment.amount)}',
                excludeSemantics: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    formatSoles(payment.amount),
                    style: data.kpiNumber.copyWith(color: colors.onDarkPrimary),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: CosechaSpace.sm),
        CosechaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              CosechaInfoRow(
                icon: Icons.receipt_long_outlined,
                label: l10n.invoiceOrder,
                value: payment.orderId,
                mono: true,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
                child: Divider(),
              ),
              CosechaInfoRow(
                icon: Icons.event_outlined,
                label: l10n.invoiceDueDate,
                value: payment.dueDate,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
                child: Divider(),
              ),
              CosechaInfoRow(
                icon: Icons.account_balance_outlined,
                label: l10n.invoiceMethod,
                value: payment.method,
              ),
            ],
          ),
        ),
        const SizedBox(height: CosechaSpace.md),
        // Demo-only action, kept as a secondary text button.
        Center(
          child: CosechaTextButton(
            label: l10n.invoiceSimulate,
            icon: Icons.science_outlined,
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.invoiceSimulated)),
              );
            },
          ),
        ),
      ],
    );
  }
}
