import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';

/// In-transit delay of a delivery: the reason the distributor reported
/// (`report-delay`, the `Delayed` event) and the current ETA.
class DelayAlertBanner extends StatelessWidget {
  const DelayAlertBanner({
    required this.delay,
    required this.eta,
    super.key,
  });

  /// The `Delayed` event; null when the platform has no event yet.
  final TrackingEventItem? delay;

  /// Current ETA, already formatted; null when unknown.
  final String? eta;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final warning = CosechaStatusColors.of(context).warning;
    final reportedAt = delay?.occurredAt;
    final reason = delay?.note;

    return Semantics(
      container: true,
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(CosechaSpace.inner),
        decoration: BoxDecoration(
          color: warning.container,
          borderRadius: CosechaRadius.cardAll,
          border: Border.all(color: warning.color),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: CosechaSize.iconSm,
                  color: warning.onContainer,
                ),
                const SizedBox(width: CosechaSpace.xxs),
                Expanded(
                  child: Text(
                    l10n.trackingDelayTitle,
                    style: textTheme.titleSmall?.copyWith(
                      color: warning.onContainer,
                    ),
                  ),
                ),
                if (reportedAt != null)
                  Text(
                    MaterialLocalizations.of(context).formatTimeOfDay(
                      TimeOfDay.fromDateTime(reportedAt),
                    ),
                    style: CosechaDataText.of(context).dataMonoSmall.copyWith(
                      color: warning.onContainer,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: CosechaSpace.xs),
            Text(
              reason ?? l10n.trackingDelayNoReason,
              style: textTheme.bodyMedium?.copyWith(
                color: warning.onContainer,
              ),
            ),
            if (eta != null) ...[
              const SizedBox(height: CosechaSpace.xxs),
              Text(
                l10n.trackingDelayEta(eta!),
                style: textTheme.bodySmall?.copyWith(
                  color: warning.onContainer,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
