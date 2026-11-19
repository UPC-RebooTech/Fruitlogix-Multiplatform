import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';

/// Presentation of an order status: localized label + Cosecha semantic.
typedef StatusView = ({String label, CosechaStatus status});

/// Maps the domain status code of an order to its label and semantic state.
StatusView orderStatusView(String status, AppLocalizations l10n) =>
    switch (status.toUpperCase()) {
      'PREPARING' => (
          label: l10n.orderStatusPreparing,
          status: CosechaStatus.neutral,
        ),
      'IN_TRANSIT' => (
          label: l10n.orderStatusInTransit,
          status: CosechaStatus.info,
        ),
      'DELIVERED' => (
          label: l10n.orderStatusDelivered,
          status: CosechaStatus.success,
        ),
      'REJECTED' => (
          label: l10n.orderStatusRejected,
          status: CosechaStatus.critical,
        ),
      _ => (label: l10n.orderStatusPending, status: CosechaStatus.neutral),
    };
