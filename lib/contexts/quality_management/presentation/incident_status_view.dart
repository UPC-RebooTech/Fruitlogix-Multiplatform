import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/incident.dart';
import '../infrastructure/fruitlogix_quality_api.dart';

/// Localized label + Cosecha semantic of an incident status.
({String label, CosechaStatus status}) incidentStatusView(
  IncidentStatus status,
  AppLocalizations l10n,
) =>
    switch (status) {
      IncidentStatus.open => (label: l10n.qmStatusOpen, status: CosechaStatus.warning),
      IncidentStatus.inReview => (label: l10n.qmStatusInReview, status: CosechaStatus.info),
      IncidentStatus.resolved => (label: l10n.qmStatusResolved, status: CosechaStatus.success),
      IncidentStatus.rejected => (label: l10n.qmStatusRejected, status: CosechaStatus.critical),
    };

/// User-facing text for a failed Quality Management request.
String qualityErrorMessage(
  Object? error,
  AppLocalizations l10n, {
  required String fallback,
}) =>
    switch (error) {
      QualityApiException(reason: QualityApiFailure.network) => l10n.authNetworkError,
      QualityApiException(reason: QualityApiFailure.unauthorized) => l10n.qmSessionExpired,
      QualityApiException(reason: QualityApiFailure.server) => l10n.authServerError,
      _ => fallback,
    };
