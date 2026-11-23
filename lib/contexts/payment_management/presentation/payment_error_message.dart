import '../../../l10n/app_localizations.dart';
import '../infrastructure/fruitlogix_payments_api.dart';

/// User-facing text for a failed payments request.
String paymentErrorMessage(Object? error, AppLocalizations l10n, {required String fallback}) =>
    switch (error) {
      PaymentApiException(reason: PaymentApiFailure.network) => l10n.authNetworkError,
      PaymentApiException(reason: PaymentApiFailure.unauthorized) => l10n.paymentsSessionExpired,
      PaymentApiException(reason: PaymentApiFailure.server) => l10n.authServerError,
      _ => fallback,
    };
