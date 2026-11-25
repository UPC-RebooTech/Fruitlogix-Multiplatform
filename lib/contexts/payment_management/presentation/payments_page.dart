import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/financial_overview_controller.dart';
import '../application/invoice_reminder_service.dart';
import '../application/membership_controller.dart';
import '../domain/invoice.dart';
import 'invoice_reminders_card.dart';
import 'payment_error_message.dart';
import 'payment_status_view.dart';

/// Payments section (opened from "More"): balance, reminders (US70), the
/// client's invoices from the API and the Pro upgrade entry (US30).
/// The top bar already shows the section title.
class PaymentsPage extends StatelessWidget {
  const PaymentsPage({
    required this.overview,
    required this.reminders,
    required this.membership,
    required this.onOpenInvoice,
    required this.onOpenPro,
    super.key,
  });

  final FinancialOverviewController overview;
  final InvoiceReminderService reminders;
  final MembershipController membership;
  final ValueChanged<Invoice> onOpenInvoice;
  final VoidCallback onOpenPro;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([overview, membership]),
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final balance = overview.balance;
        final loading = !overview.hasData && overview.status != OverviewStatus.failure;

        return RefreshIndicator(
          onRefresh: overview.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              CosechaSpace.screenMargin,
              CosechaSpace.md,
              CosechaSpace.screenMargin,
              CosechaSpace.lg,
            ),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: CosechaKpiCard(
                      label: l10n.balanceDebt,
                      value: loading ? '…' : formatSoles(balance.accumulatedDebt),
                      icon: Icons.payments_outlined,
                    ),
                  ),
                  const SizedBox(width: CosechaSpace.xs),
                  Expanded(
                    child: CosechaKpiCard(
                      label: l10n.balanceOverdue,
                      value: loading ? '…' : formatSoles(balance.overdueAmount),
                      icon: Icons.warning_amber_outlined,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: CosechaSpace.md),
              UpcomingRemindersBanner(service: reminders),
              InvoiceRemindersCard(service: reminders),
              if (!membership.isPro) ...[
                const SizedBox(height: CosechaSpace.xs),
                CosechaActionRow(
                  icon: Icons.workspace_premium_outlined,
                  title: l10n.proUpgrade,
                  detail: l10n.proUpsellDetail,
                  onTap: onOpenPro,
                ),
              ],
              const SizedBox(height: CosechaSpace.md),
              CosechaOverline(l10n.paymentsInvoices),
              const SizedBox(height: CosechaSpace.xs),
              ..._invoiceList(context, l10n, loading),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _invoiceList(
    BuildContext context,
    AppLocalizations l10n,
    bool loading,
  ) {
    if (loading) {
      return [
        const Padding(
          padding: EdgeInsets.all(CosechaSpace.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (overview.status == OverviewStatus.failure && overview.invoices.isEmpty) {
      return [
        CosechaEmptyState(
          isError: true,
          title: paymentErrorMessage(
            overview.error,
            l10n,
            fallback: l10n.paymentsLoadError,
          ),
          action: CosechaTextButton(
            label: l10n.paymentsRetry,
            icon: Icons.refresh,
            onPressed: overview.load,
          ),
        ),
      ];
    }
    if (overview.invoices.isEmpty) {
      return [
        CosechaEmptyState(
          icon: Icons.receipt_long_outlined,
          title: l10n.paymentsEmpty,
        ),
      ];
    }
    return [
      for (final invoice in overview.invoices) ...[
        _InvoiceRow(invoice: invoice, onTap: () => onOpenInvoice(invoice)),
        const SizedBox(height: CosechaSpace.xs),
      ],
    ];
  }
}

class _InvoiceRow extends StatelessWidget {
  const _InvoiceRow({required this.invoice, required this.onTap});

  final Invoice invoice;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = paymentStatusView(invoice.status, l10n);
    final amount = formatMoney(invoice.amount, invoice.currency);
    final due = l10n.paymentDue(formatLongDate(context, invoice.dueDate));

    return CosechaCard(
      radius: CosechaRadius.button,
      padding: const EdgeInsets.all(CosechaSpace.inner),
      onTap: onTap,
      semanticLabel: '${l10n.invoiceTitle(invoice.code)}, $amount, ${status.label}, $due',
      child: Row(
        children: [
          const CosechaIconBox(icon: Icons.receipt_long_outlined),
          const SizedBox(width: CosechaSpace.inner),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  invoice.code,
                  style: data.dataMono.copyWith(
                    color: context.cosechaContent,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  amount,
                  style: data.dataMonoSmall.copyWith(color: context.cosechaContent),
                ),
                Text(
                  due,
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
