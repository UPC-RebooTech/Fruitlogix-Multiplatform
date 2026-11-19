import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';

/// Maps the domain status code of a payment to its label and Cosecha
/// semantic state.
({String label, CosechaStatus status}) paymentStatusView(
  String status,
  AppLocalizations l10n,
) =>
    switch (status.toUpperCase()) {
      'PAID' => (label: l10n.paymentStatusPaid, status: CosechaStatus.success),
      'OVERDUE' => (
          label: l10n.paymentStatusOverdue,
          status: CosechaStatus.critical,
        ),
      _ => (label: l10n.paymentStatusPending, status: CosechaStatus.neutral),
    };
