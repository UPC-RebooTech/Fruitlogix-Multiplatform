import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/invoice.dart';

/// Maps the domain status of an invoice to its label and Cosecha semantic
/// state.
({String label, CosechaStatus status}) paymentStatusView(
  InvoiceStatus status,
  AppLocalizations l10n,
) =>
    switch (status) {
      InvoiceStatus.paid => (label: l10n.paymentStatusPaid, status: CosechaStatus.success),
      InvoiceStatus.overdue => (
          label: l10n.paymentStatusOverdue,
          status: CosechaStatus.critical,
        ),
      InvoiceStatus.failed => (
          label: l10n.paymentStatusFailed,
          status: CosechaStatus.critical,
        ),
      InvoiceStatus.refunded => (
          label: l10n.paymentStatusRefunded,
          status: CosechaStatus.info,
        ),
      InvoiceStatus.pending => (
          label: l10n.paymentStatusPending,
          status: CosechaStatus.neutral,
        ),
    };
