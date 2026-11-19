import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';
import '../infrastructure/in_memory_shipment_repository.dart';
import 'confirm_reception_page.dart';

/// Tracking of the active shipment: overview (dark highlight), cold chain
/// readings (Glaciar, reserved for cold chain) and route checkpoints.
class DeliveryTrackingPage extends StatefulWidget {
  const DeliveryTrackingPage({required this.repository, super.key});

  final InMemoryShipmentRepository repository;

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  Future<void> _confirmReception(DeliveryShipment shipment) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => ConfirmReceptionPage(
        shipment: shipment,
        onConfirmed: (notes, incidents) {
          setState(() {
            widget.repository.markAsReceived(
              shipment.trackingNumber,
              notes: notes,
              incidents: incidents,
            );
          });
        },
      ),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shipments = widget.repository.getActiveShipments();

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CosechaSpace.screenMargin,
        CosechaSpace.md,
        CosechaSpace.screenMargin,
        CosechaSpace.lg,
      ),
      children: [
        CosechaPageHeader(
          title: l10n.trackingTitle,
          subtitle: l10n.trackingSubtitle,
        ),
        const SizedBox(height: CosechaSpace.md),
        if (shipments.isEmpty)
          CosechaEmptyState(
            icon: Icons.local_shipping_outlined,
            title: l10n.trackingEmptyTitle,
            message: l10n.trackingEmptyMessage,
          )
        else ...[
          _ShipmentOverview(shipment: shipments.first),
          const SizedBox(height: CosechaSpace.md),
          CosechaOverline(l10n.trackingColdChain),
          const SizedBox(height: CosechaSpace.xs),
          _ColdChain(telemetry: shipments.first.telemetry),
          const SizedBox(height: CosechaSpace.md),
          CosechaOverline(l10n.trackingEvents),
          const SizedBox(height: CosechaSpace.xs),
          CosechaCard(
            child: CosechaTimeline(
              completedLabel: l10n.trackingEventDone,
              pendingLabel: l10n.trackingEventPending,
              steps: [
                for (final event in shipments.first.events)
                  CosechaTimelineStep(
                    time: event.time,
                    description: event.description,
                    completed: event.isCompleted,
                  ),
              ],
            ),
          ),
          const SizedBox(height: CosechaSpace.md),
          if (shipments.first.isReceived)
            CosechaCard(
              tone: CosechaCardTone.tint,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.trackingReceptionDoneMessage,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                  const SizedBox(width: CosechaSpace.xs),
                  CosechaStatusTag(
                    label: l10n.trackingReceptionDone,
                    status: CosechaStatus.success,
                    icon: Icons.check,
                  ),
                ],
              ),
            )
          else
            CosechaPrimaryButton(
              label: l10n.trackingConfirmReception,
              icon: Icons.fact_check_outlined,
              onPressed: () => _confirmReception(shipments.first),
            ),
        ],
      ],
    );
  }
}

class _ShipmentOverview extends StatelessWidget {
  const _ShipmentOverview({required this.shipment});

  final DeliveryShipment shipment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = CosechaStatusColors.of(context);
    final percent = (shipment.shipmentProgress * 100).round();

    return CosechaCard(
      tone: CosechaCardTone.dark,
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CosechaOverline(l10n.trackingActiveShipment)),
              CosechaStatusTag(
                label: shipment.isReceived
                    ? l10n.trackingStatusReceived
                    : l10n.orderStatusInTransit,
                status: shipment.isReceived
                    ? CosechaStatus.success
                    : CosechaStatus.info,
              ),
            ],
          ),
          const SizedBox(height: CosechaSpace.xs),
          Text(
            shipment.trackingNumber,
            style: data.dataMono.copyWith(
              color: status.onDarkPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            l10n.orderReference(shipment.orderId),
            style: textTheme.bodyMedium
                ?.copyWith(color: status.onDarkSecondary),
          ),
          const SizedBox(height: CosechaSpace.sm),
          CosechaProgressBar(
            value: shipment.shipmentProgress,
            semanticLabel: l10n.trackingProgress(percent),
          ),
          const SizedBox(height: CosechaSpace.sm),
          CosechaInfoRow(
            icon: Icons.schedule,
            label: l10n.trackingEta,
            value: shipment.estimatedArrival,
          ),
          const SizedBox(height: CosechaSpace.xs),
          CosechaInfoRow(
            icon: Icons.local_shipping_outlined,
            label: l10n.trackingTransport,
            value: shipment.transportStatus,
          ),
        ],
      ),
    );
  }
}

/// Cold chain readings on Glaciar (tertiary) containers.
class _ColdChain extends StatelessWidget {
  const _ColdChain({required this.telemetry});

  final TelemetryLog telemetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: _Reading(
                icon: Icons.thermostat,
                label: l10n.trackingTemperature,
                value: '${telemetry.temperatureC.toStringAsFixed(1)} °C',
              ),
            ),
            const SizedBox(width: CosechaSpace.xs),
            Expanded(
              child: _Reading(
                icon: Icons.water_drop_outlined,
                label: l10n.trackingHumidity,
                value: '${telemetry.humidityPercent.toStringAsFixed(0)} %',
              ),
            ),
          ],
        ),
        const SizedBox(height: CosechaSpace.xs),
        CosechaCard(
          padding: const EdgeInsets.all(CosechaSpace.inner),
          child: Row(
            children: [
              const CosechaIconBox(icon: Icons.ac_unit),
              const SizedBox(width: CosechaSpace.inner),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.trackingReefer,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: CosechaSpace.xxs),
                    CosechaStatusTag(
                      label: telemetry.reeferUnitStatus,
                      status: CosechaStatus.info,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Reading extends StatelessWidget {
  const _Reading({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
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
        padding: const EdgeInsets.all(CosechaSpace.sm),
        decoration: BoxDecoration(
          color: scheme.tertiaryContainer,
          borderRadius: CosechaRadius.cardAll,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: CosechaSize.iconSm, color: scheme.tertiary),
                const SizedBox(width: CosechaSpace.xxs),
                Expanded(
                  child: CosechaOverline(
                    label,
                    color: scheme.onTertiaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: CosechaSpace.xs),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                value,
                maxLines: 1,
                style: CosechaDataText.of(context)
                    .readingMono
                    .copyWith(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
