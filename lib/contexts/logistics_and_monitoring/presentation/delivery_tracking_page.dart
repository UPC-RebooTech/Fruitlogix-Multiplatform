import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/shipments_controller.dart';
import '../domain/shipment.dart';
import '../infrastructure/fruitlogix_logistics_api.dart';
import '../infrastructure/phone_dialer.dart';
import 'confirm_reception_page.dart';

/// Tracking of the client's deliveries: overview (dark highlight), driver
/// and vehicle with a call button (US38, US77), cold chain readings
/// (Glaciar, reserved for cold chain) and route checkpoints.
class DeliveryTrackingPage extends StatefulWidget {
  const DeliveryTrackingPage({
    required this.controller,
    required this.dialer,
    this.onReportIncident,
    this.onReceptionConfirmed,
    super.key,
  });

  final ShipmentsController controller;
  final PhoneDialer dialer;

  /// The platform registered a reception (e.g. to refresh the orders).
  final VoidCallback? onReceptionConfirmed;

  /// Opens the incident report (Quality Management) for an order code when
  /// the reception inspection flags an incident.
  final ValueChanged<String>? onReportIncident;

  @override
  State<DeliveryTrackingPage> createState() => _DeliveryTrackingPageState();
}

class _DeliveryTrackingPageState extends State<DeliveryTrackingPage> {
  String? _selectedId;

  Future<void> _confirmReception(DeliveryShipment shipment) async {
    final report = await Navigator.of(context).push<ReceptionReport>(
      MaterialPageRoute<ReceptionReport>(
        builder: (_) => ConfirmReceptionPage(
          shipment: shipment,
          // US35: sent with the optional rating and comment.
          onConfirm: (report) =>
              widget.controller.confirmReception(shipment, report),
        ),
      ),
    );
    if (!mounted || report == null) return;
    widget.onReceptionConfirmed?.call();
    // US11: an incident flagged at the dock goes straight to the report.
    if (report.hasIncidence) widget.onReportIncident?.call(shipment.orderId);
  }

  Future<void> _callDriver(DeliveryShipment shipment) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final opened = await widget.dialer.dial(shipment.driverPhone!);
    if (!opened) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.trackingCallError)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final shipments = controller.shipments;
        final loading =
            !controller.hasData && controller.status != ShipmentsStatus.failure;
        final selected = shipments.isEmpty
            ? null
            : shipments.firstWhere(
                (s) => s.id == _selectedId,
                orElse: () => shipments.first,
              );

        return RefreshIndicator(
          onRefresh: controller.load,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
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
              if (loading)
                const Padding(
                  padding: EdgeInsets.all(CosechaSpace.md),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (controller.status == ShipmentsStatus.failure &&
                  shipments.isEmpty)
                CosechaEmptyState(
                  isError: true,
                  title: _errorMessage(controller.error, l10n),
                  action: CosechaTextButton(
                    label: l10n.qmRetry,
                    icon: Icons.refresh,
                    onPressed: controller.load,
                  ),
                )
              else if (selected == null)
                CosechaEmptyState(
                  icon: Icons.local_shipping_outlined,
                  title: l10n.trackingEmptyTitle,
                  message: l10n.trackingEmptyMessage,
                )
              else ...[
                if (shipments.length > 1) ...[
                  CosechaOverline(l10n.trackingYourDeliveries),
                  const SizedBox(height: CosechaSpace.xs),
                  Wrap(
                    spacing: CosechaSpace.xs,
                    runSpacing: CosechaSpace.xs,
                    children: [
                      for (final shipment in shipments)
                        CosechaFilterChip(
                          label: shipment.orderId,
                          selected: shipment.id == selected.id,
                          onSelected: (_) =>
                              setState(() => _selectedId = shipment.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: CosechaSpace.sm),
                ],
                _ShipmentOverview(shipment: selected),
                const SizedBox(height: CosechaSpace.md),
                CosechaOverline(l10n.trackingDriverSection),
                const SizedBox(height: CosechaSpace.xs),
                _DriverCard(
                  shipment: selected,
                  onCall: selected.canCallDriver
                      ? () => _callDriver(selected)
                      : null,
                ),
                const SizedBox(height: CosechaSpace.md),
                CosechaOverline(l10n.trackingColdChain),
                const SizedBox(height: CosechaSpace.xs),
                if (selected.telemetry == null)
                  CosechaCard(
                    tone: CosechaCardTone.light,
                    child: Text(
                      l10n.trackingNoReadings,
                      style: Theme.of(context).textTheme.bodyMedium
                          ?.copyWith(color: context.cosechaContentSecondary),
                    ),
                  )
                else
                  _ColdChain(telemetry: selected.telemetry!),
                if (selected.events.isNotEmpty) ...[
                  const SizedBox(height: CosechaSpace.md),
                  CosechaOverline(l10n.trackingEvents),
                  const SizedBox(height: CosechaSpace.xs),
                  CosechaCard(
                    child: CosechaTimeline(
                      completedLabel: l10n.trackingEventDone,
                      pendingLabel: l10n.trackingEventPending,
                      steps: [
                        for (final event in selected.events)
                          CosechaTimelineStep(
                            time: event.time,
                            description: event.description,
                            completed: event.isCompleted,
                          ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: CosechaSpace.md),
                if (selected.isReceived)
                  CosechaCard(
                    tone: CosechaCardTone.tint,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
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
                        if (selected.rating != null) ...[
                          const SizedBox(height: CosechaSpace.xs),
                          _GivenRating(rating: selected.rating!),
                        ],
                      ],
                    ),
                  )
                // Only once the goods left the warehouse.
                else if (selected.status != ShipmentStatus.delivered &&
                    selected.status != ShipmentStatus.scheduled)
                  CosechaPrimaryButton(
                    label: l10n.trackingConfirmReception,
                    icon: Icons.fact_check_outlined,
                    onPressed: () => _confirmReception(selected),
                  ),
              ],
            ],
          ),
        );
      },
    );
  }

  static String _errorMessage(Object? error, AppLocalizations l10n) =>
      switch (error) {
        LogisticsApiException(reason: LogisticsApiFailure.network) =>
          l10n.authNetworkError,
        LogisticsApiException(reason: LogisticsApiFailure.unauthorized) =>
          l10n.qmSessionExpired,
        LogisticsApiException(reason: LogisticsApiFailure.server) =>
          l10n.authServerError,
        _ => l10n.trackingLoadError,
      };
}

/// Label + Cosecha semantic of a delivery status.
({String label, CosechaStatus status}) shipmentStatusView(
  DeliveryShipment shipment,
  AppLocalizations l10n,
) {
  if (shipment.isReceived) {
    return (label: l10n.trackingStatusReceived, status: CosechaStatus.success);
  }
  return switch (shipment.status) {
    ShipmentStatus.scheduled => (
      label: l10n.trackingStatusScheduled,
      status: CosechaStatus.neutral,
    ),
    ShipmentStatus.dispatched => (
      label: l10n.trackingStatusDispatched,
      status: CosechaStatus.info,
    ),
    ShipmentStatus.inTransit => (
      label: l10n.orderStatusInTransit,
      status: CosechaStatus.info,
    ),
    ShipmentStatus.delayed => (
      label: l10n.trackingStatusDelayed,
      status: CosechaStatus.warning,
    ),
    ShipmentStatus.arrived => (
      label: l10n.receptionArrived,
      status: CosechaStatus.info,
    ),
    ShipmentStatus.delivered => (
      label: l10n.orderStatusDelivered,
      status: CosechaStatus.success,
    ),
  };
}

/// "23 de noviembre de 2026 · 3:45 p. m."
String _formatDateTime(BuildContext context, DateTime value) {
  final time = MaterialLocalizations.of(context)
      .formatTimeOfDay(TimeOfDay.fromDateTime(value));
  return '${formatLongDate(context, value)} · $time';
}

class _ShipmentOverview extends StatelessWidget {
  const _ShipmentOverview({required this.shipment});

  final DeliveryShipment shipment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final colors = CosechaStatusColors.of(context);
    final status = shipmentStatusView(shipment, l10n);
    final percent = (shipment.shipmentProgress * 100).round();
    final route = _route(l10n);

    return CosechaCard(
      tone: CosechaCardTone.dark,
      hero: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: CosechaOverline(l10n.trackingActiveShipment)),
              CosechaStatusTag(label: status.label, status: status.status),
            ],
          ),
          const SizedBox(height: CosechaSpace.xs),
          Text(
            shipment.trackingNumber,
            style: data.dataMono.copyWith(
              color: colors.onDarkPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            l10n.orderReference(shipment.orderId),
            style: textTheme.bodyMedium?.copyWith(
              color: colors.onDarkSecondary,
            ),
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
            value: shipment.estimatedArrival == null
                ? l10n.trackingEtaUnknown
                : _formatDateTime(context, shipment.estimatedArrival!),
          ),
          if (route != null) ...[
            const SizedBox(height: CosechaSpace.xs),
            CosechaInfoRow(
              icon: Icons.route_outlined,
              label: l10n.trackingRoute,
              value: route,
            ),
          ],
        ],
      ),
    );
  }

  String? _route(AppLocalizations l10n) {
    final origin = shipment.routeOrigin,
        destination = shipment.routeDestination;
    if (origin == null && destination == null) return null;
    final path = l10n.trackingRouteValue(origin ?? '—', destination ?? '—');
    final km = shipment.routeDistanceKm;
    return km == null || km <= 0 ? path : '$path · ${km.toStringAsFixed(0)} km';
  }
}

/// US38 — who transports the order; US77 — call them.
class _DriverCard extends StatelessWidget {
  const _DriverCard({required this.shipment, required this.onCall});

  final DeliveryShipment shipment;
  final VoidCallback? onCall;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);

    Widget divider() => const Padding(
      padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
      child: Divider(),
    );

    final vehicle = shipment.vehicleType;
    final plate = shipment.vehiclePlate;

    return CosechaCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const CosechaIconBox(icon: Icons.badge_outlined),
              const SizedBox(width: CosechaSpace.inner),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      shipment.hasDriver
                          ? shipment.driverName!
                          : l10n.trackingDriverPending,
                      style: textTheme.titleSmall?.copyWith(
                        color: shipment.hasDriver
                            ? context.cosechaContent
                            : context.cosechaContentSecondary,
                      ),
                    ),
                    if (shipment.driverPhone != null)
                      Text(
                        shipment.driverPhone!,
                        style: data.dataMonoSmall.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          if (vehicle != null || plate != null) ...[
            divider(),
            Row(
              children: [
                if (vehicle != null)
                  Expanded(
                    child: CosechaInfoRow(
                      icon: Icons.local_shipping_outlined,
                      label: l10n.trackingVehicle,
                      value: vehicle,
                    ),
                  ),
                if (plate != null)
                  Expanded(
                    child: CosechaInfoRow(
                      icon: Icons.pin_outlined,
                      label: l10n.trackingPlate,
                      value: plate,
                      mono: true,
                    ),
                  ),
              ],
            ),
          ],
          if (onCall != null) ...[
            const SizedBox(height: CosechaSpace.sm),
            Semantics(
              hint: l10n.trackingCallDriverHint(shipment.driverName ?? ''),
              child: CosechaSecondaryButton(
                label: l10n.trackingCallDriver,
                icon: Icons.call_outlined,
                onPressed: onCall,
              ),
            ),
          ],
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
    final recordedAt = telemetry.recordedAt;
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
        if (recordedAt != null) ...[
          const SizedBox(height: CosechaSpace.xxs),
          Text(
            l10n.trackingLastReading(_formatDateTime(context, recordedAt)),
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.cosechaContentSecondary),
          ),
        ],
        if (telemetry.reeferUnitStatus != null) ...[
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
                        label: telemetry.reeferUnitStatus!,
                        status: CosechaStatus.info,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
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
                style: CosechaDataText.of(context).readingMono
                    .copyWith(color: scheme.onTertiaryContainer),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Stars the client gave at reception (US35), read-only.
class _GivenRating extends StatelessWidget {
  const _GivenRating({required this.rating});

  final int rating;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      container: true,
      label: l10n.receptionYourRating(
        l10n.receptionStars(rating, ReceptionReport.maxRating),
      ),
      excludeSemantics: true,
      child: Row(
        children: [
          Text(
            l10n.receptionYourRatingLabel,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: context.cosechaContentSecondary),
          ),
          const SizedBox(width: CosechaSpace.xs),
          for (var star = 1; star <= ReceptionReport.maxRating; star++)
            Icon(
              star <= rating ? Icons.star_rounded : Icons.star_outline_rounded,
              size: CosechaSize.iconSm,
              color: star <= rating ? scheme.primary : scheme.outline,
            ),
        ],
      ),
    );
  }
}
