import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/commercial_order.dart';
import '../infrastructure/fruitlogix_orders_api.dart';

/// Presentation of an order status: localized label + Cosecha semantic.
typedef StatusView = ({String label, CosechaStatus status});

/// Maps the status of an order to its label and semantic state.
StatusView orderStatusView(OrderStatus status, AppLocalizations l10n) =>
    switch (status) {
      OrderStatus.pending => (
        label: l10n.orderStatusPending,
        status: CosechaStatus.neutral,
      ),
      OrderStatus.preparing => (
        label: l10n.orderStatusPreparing,
        status: CosechaStatus.neutral,
      ),
      OrderStatus.inTransit => (
        label: l10n.orderStatusInTransit,
        status: CosechaStatus.info,
      ),
      OrderStatus.delivered => (
        label: l10n.orderStatusDelivered,
        status: CosechaStatus.success,
      ),
      OrderStatus.cancelled => (
        label: l10n.orderStatusCancelled,
        status: CosechaStatus.neutral,
      ),
      OrderStatus.rejected => (
        label: l10n.orderStatusRejected,
        status: CosechaStatus.critical,
      ),
    };

/// User-facing text for a failed orders request.
String orderErrorMessage(
  Object? error,
  AppLocalizations l10n, {
  required String fallback,
}) => switch (error) {
  OrderApiException(reason: OrderApiFailure.network) => l10n.authNetworkError,
  OrderApiException(reason: OrderApiFailure.unauthorized) =>
    l10n.qmSessionExpired,
  OrderApiException(reason: OrderApiFailure.server) => l10n.authServerError,
  OrderApiException(
    reason: OrderApiFailure.invalid,
    message: final String message,
  )
      when message.isNotEmpty =>
    message,
  _ => fallback,
};
