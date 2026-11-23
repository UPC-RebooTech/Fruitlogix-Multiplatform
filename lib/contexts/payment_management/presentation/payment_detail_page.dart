import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/invoice_reminder_service.dart';
import '../domain/invoice.dart';
import 'payment_status_view.dart';

/// Invoice detail, shown inside the shell (both bars visible). The top bar
/// shows the invoice title and the back button.
class PaymentDetailPage extends StatelessWidget {
  const PaymentDetailPage({
    required this.invoice,
    required this.reminders,
    super.key,
  });

  final Invoice invoice;
  final InvoiceReminderService reminders;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final data = CosechaDataText.of(context);
    final colors = CosechaStatusColors.of(context);
    final status = paymentStatusView(invoice.status, l10n);
    final amount = formatMoney(invoice.amount, invoice.currency);

    Widget divider() => const Padding(
          padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
          child: Divider(),
        );

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
                invoice.code,
                style: data.dataMono.copyWith(color: colors.onDarkSecondary),
              ),
              const SizedBox(height: CosechaSpace.xxs),
              Semantics(
                label: '${l10n.invoiceAmount}: $amount',
                excludeSemantics: true,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    amount,
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
              if (invoice.orderCode != null) ...[
                CosechaInfoRow(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.invoiceOrder,
                  value: invoice.orderCode!,
                  mono: true,
                ),
                divider(),
              ],
              CosechaInfoRow(
                icon: Icons.event_outlined,
                label: l10n.invoiceDueDate,
                value: formatLongDate(context, invoice.dueDate),
              ),
              if (invoice.issuedAt != null) ...[
                divider(),
                CosechaInfoRow(
                  icon: Icons.description_outlined,
                  label: l10n.invoiceIssued,
                  value: formatLongDate(context, invoice.issuedAt!),
                ),
              ],
              if (invoice.paidAt != null) ...[
                divider(),
                CosechaInfoRow(
                  icon: Icons.check_circle_outline,
                  label: l10n.invoicePaidAt,
                  value: formatLongDate(context, invoice.paidAt!),
                ),
              ],
              divider(),
              ListenableBuilder(
                listenable: reminders,
                builder: (context, _) => CosechaInfoRow(
                  icon: Icons.notifications_outlined,
                  label: l10n.invoiceReminder,
                  value: _reminderText(l10n),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _reminderText(AppLocalizations l10n) {
    if (!invoice.isOutstanding) return l10n.invoiceReminderNone;
    if (invoice.status == InvoiceStatus.overdue) return l10n.invoiceReminderOverdue;
    if (!reminders.enabled) return l10n.invoiceReminderOff;
    return l10n.remindersLeadDays(reminders.leadDays);
  }
}
