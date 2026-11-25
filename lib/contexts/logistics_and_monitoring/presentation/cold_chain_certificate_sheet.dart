import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';

/// Cold-chain certificate of a trip: target range, monitored time and the
/// temperatures of its tracking logs (average, minimum, maximum), with the
/// share of readings inside the range.
class ColdChainCertificateSheet extends StatelessWidget {
  const ColdChainCertificateSheet({
    required this.certificate,
    required this.trackingNumber,
    required this.orderCode,
    super.key,
  });

  final ColdChainCertificate certificate;
  final String trackingNumber;
  final String orderCode;

  static Future<void> show(
    BuildContext context, {
    required ColdChainCertificate certificate,
    required String trackingNumber,
    required String orderCode,
  }) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (_) => ColdChainCertificateSheet(
      certificate: certificate,
      trackingNumber: trackingNumber,
      orderCode: orderCode,
    ),
  );

  static String _temp(double value) => '${value.toStringAsFixed(1)} °C';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final colors = CosechaStatusColors.of(context);
    final tone = certificate.isCompliant ? colors.success : colors.warning;
    final monitored = certificate.monitored;
    final last = certificate.lastReadingAt;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          CosechaSpace.md,
          0,
          CosechaSpace.md,
          CosechaSpace.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    l10n.coldChainCertificateTitle,
                    style: textTheme.titleLarge,
                  ),
                ),
                CosechaStatusTag(
                  label: l10n.coldChainCompliance(
                    certificate.compliancePercent.toStringAsFixed(0),
                  ),
                  status: certificate.isCompliant
                      ? CosechaStatus.success
                      : CosechaStatus.warning,
                  icon: certificate.isCompliant
                      ? Icons.verified_outlined
                      : Icons.warning_amber_rounded,
                ),
              ],
            ),
            const SizedBox(height: CosechaSpace.xxs),
            Text(
              l10n.coldChainReadings(
                certificate.inRangeCount,
                certificate.readingsCount,
              ),
              style: textTheme.bodyMedium?.copyWith(color: tone.color),
            ),
            const SizedBox(height: CosechaSpace.md),
            CosechaCard(
              tone: CosechaCardTone.light,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  CosechaInfoRow(
                    icon: Icons.receipt_long_outlined,
                    label: l10n.coldChainOrder,
                    value: '$orderCode · $trackingNumber',
                  ),
                  const SizedBox(height: CosechaSpace.xs),
                  CosechaInfoRow(
                    icon: Icons.thermostat,
                    label: l10n.coldChainTargetRange,
                    value:
                        '${_temp(ColdChainCertificate.rangeMinC)} – '
                        '${_temp(ColdChainCertificate.rangeMaxC)}',
                  ),
                  if (monitored != null) ...[
                    const SizedBox(height: CosechaSpace.xs),
                    CosechaInfoRow(
                      icon: Icons.schedule,
                      label: l10n.coldChainMonitored,
                      value: l10n.coldChainHours(
                        (monitored.inMinutes / 60).toStringAsFixed(1),
                      ),
                    ),
                  ],
                  if (last != null) ...[
                    const SizedBox(height: CosechaSpace.xs),
                    CosechaInfoRow(
                      icon: Icons.update,
                      label: l10n.coldChainLastReading,
                      value: formatLongDate(context, last),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.md),
            CosechaOverline(l10n.coldChainMetrics),
            const SizedBox(height: CosechaSpace.xs),
            Row(
              children: [
                Expanded(
                  child: _Metric(
                    label: l10n.coldChainAverage,
                    value: _temp(certificate.averageTempC),
                  ),
                ),
                const SizedBox(width: CosechaSpace.xs),
                Expanded(
                  child: _Metric(
                    label: l10n.coldChainMinimum,
                    value: _temp(certificate.minTempC),
                  ),
                ),
                const SizedBox(width: CosechaSpace.xs),
                Expanded(
                  child: _Metric(
                    label: l10n.coldChainMaximum,
                    value: _temp(certificate.maxTempC),
                  ),
                ),
              ],
            ),
            const SizedBox(height: CosechaSpace.sm),
            Text(
              l10n.coldChainSource,
              style: textTheme.bodySmall?.copyWith(
                color: context.cosechaContentSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Glaciar (cold chain) tile, like the live readings.
class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.all(CosechaSpace.xs),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: CosechaRadius.cardAll,
        ),
        child: Column(
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: CosechaDataText.of(context).dataMono.copyWith(
                  color: scheme.onTertiaryContainer,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(height: CosechaSpace.xxs),
            Text(
              label,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
