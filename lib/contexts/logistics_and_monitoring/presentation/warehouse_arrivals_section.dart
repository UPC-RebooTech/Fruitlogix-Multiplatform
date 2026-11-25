import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/arrivals_controller.dart';
import '../domain/geofence.dart';
import '../infrastructure/fruitlogix_logistics_api.dart';
import '../infrastructure/warehouse_locator.dart';

String _km(double value) =>
    value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(1);

/// US65 — "Arrivals at your warehouse" in Tracking: the zone (set from the
/// phone's location, 1/3/5 km) and the trucks that entered it.
class WarehouseArrivalsSection extends StatelessWidget {
  const WarehouseArrivalsSection({
    required this.controller,
    this.onZoneChanged,
    super.key,
  });

  final ArrivalsController controller;

  /// The zone was saved or resized: look for trucks already inside.
  final VoidCallback? onZoneChanged;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final zone = controller.zone;
        final arrivals = controller.arrivals;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CosechaOverline(l10n.arrivalsSection),
            const SizedBox(height: CosechaSpace.xs),
            CosechaActionRow(
              icon: Icons.warehouse_outlined,
              title: l10n.arrivalsZoneTitle,
              detail: zone == null
                  ? l10n.arrivalsZoneNotSet
                  : l10n.arrivalsZoneActive(_km(zone.radiusKm)),
              trailing: zone == null
                  ? null
                  : CosechaStatusTag(
                      label: l10n.arrivalsRadiusValue(_km(zone.radiusKm)),
                      status: CosechaStatus.success,
                      icon: Icons.notifications_active_outlined,
                    ),
              onTap: controller.loaded
                  ? () => showWarehouseZoneSheet(
                        context,
                        controller,
                        onZoneChanged: onZoneChanged,
                      )
                  : null,
            ),
            if (arrivals.isNotEmpty) ...[
              const SizedBox(height: CosechaSpace.xs),
              CosechaCard(
                padding: const EdgeInsets.symmetric(
                  horizontal: CosechaSpace.inner,
                  vertical: CosechaSpace.xs,
                ),
                child: Column(
                  children: [
                    for (final (index, arrival) in arrivals.indexed) ...[
                      if (index > 0) const Divider(),
                      _ArrivalRow(arrival: arrival),
                    ],
                  ],
                ),
              ),
            ] else if (zone != null) ...[
              const SizedBox(height: CosechaSpace.xs),
              CosechaEmptyState(
                icon: Icons.local_shipping_outlined,
                title: l10n.arrivalsEmptyTitle,
                message: l10n.arrivalsEmptyMessage,
              ),
            ],
          ],
        );
      },
    );
  }
}

class _ArrivalRow extends StatelessWidget {
  const _ArrivalRow({required this.arrival});

  final ArrivalRecord arrival;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final time = MaterialLocalizations.of(context)
        .formatTimeOfDay(TimeOfDay.fromDateTime(arrival.arrivedAt));
    final now = DateTime.now();
    final today = arrival.arrivedAt.year == now.year &&
        arrival.arrivedAt.month == now.month &&
        arrival.arrivedAt.day == now.day;
    final when = today ? time : '${formatNumericDate(arrival.arrivedAt)} · $time';
    final who = [?arrival.driverName, ?arrival.vehiclePlate].join(' · ');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: CosechaSpace.xs),
      child: Row(
        children: [
          const CosechaIconBox(icon: Icons.local_shipping_outlined),
          const SizedBox(width: CosechaSpace.inner),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.orderReference(arrival.orderCode),
                  style: textTheme.titleSmall,
                ),
                Text(
                  who.isEmpty ? arrival.trackingNumber : who,
                  style: textTheme.bodySmall
                      ?.copyWith(color: context.cosechaContentSecondary),
                ),
              ],
            ),
          ),
          const SizedBox(width: CosechaSpace.xs),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(when, style: data.dataMonoSmall),
              if (arrival.distanceKm case final km?)
                Text(
                  l10n.arrivalsDistance(km.toStringAsFixed(1)),
                  style: textTheme.bodySmall
                      ?.copyWith(color: context.cosechaContentSecondary),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Zone set-up: radius 1/3/5 km and the phone's current location as centre.
Future<void> showWarehouseZoneSheet(
  BuildContext context,
  ArrivalsController controller, {
  VoidCallback? onZoneChanged,
}) =>
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => _WarehouseZoneSheet(
        controller: controller,
        messenger: ScaffoldMessenger.of(context),
        onZoneChanged: onZoneChanged,
      ),
    );

class _WarehouseZoneSheet extends StatefulWidget {
  const _WarehouseZoneSheet({
    required this.controller,
    required this.messenger,
    this.onZoneChanged,
  });

  final ArrivalsController controller;
  final ScaffoldMessengerState messenger;
  final VoidCallback? onZoneChanged;

  @override
  State<_WarehouseZoneSheet> createState() => _WarehouseZoneSheetState();
}

class _WarehouseZoneSheetState extends State<_WarehouseZoneSheet> {
  late double _radius =
      widget.controller.zone?.radiusKm ?? WarehouseZone.defaultRadiusKm;
  String? _error;

  ArrivalsController get _controller => widget.controller;

  Future<void> _useCurrentLocation() async {
    final l10n = AppLocalizations.of(context);
    setState(() => _error = null);
    try {
      await _controller.setZoneAtCurrentPosition(_radius);
    } on LocationException catch (error) {
      if (mounted) setState(() => _error = _locationMessage(error.reason, l10n));
      return;
    } catch (error) {
      _showSaveError(error, l10n);
      return;
    }
    widget.onZoneChanged?.call();
    _close(l10n.arrivalsZoneSaved);
  }

  Future<void> _saveRadius() async {
    final l10n = AppLocalizations.of(context);
    try {
      await _controller.changeRadius(_radius);
    } catch (error) {
      _showSaveError(error, l10n);
      return;
    }
    widget.onZoneChanged?.call();
    _close(l10n.arrivalsZoneSaved);
  }

  /// The platform rejected the warehouse (e.g. coordinates) or is offline.
  void _showSaveError(Object error, AppLocalizations l10n) {
    if (!mounted) return;
    setState(() {
      _error = switch (error) {
        LogisticsApiException(reason: LogisticsApiFailure.network) =>
          l10n.authNetworkError,
        LogisticsApiException(message: final String message)
            when message.isNotEmpty =>
          message,
        _ => l10n.arrivalsZoneSaveError,
      };
    });
  }

  Future<void> _remove() async {
    final l10n = AppLocalizations.of(context);
    await _controller.clearZone();
    _close(l10n.arrivalsZoneRemoved);
  }

  void _close(String message) {
    if (!mounted) return;
    Navigator.of(context).pop();
    widget.messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  static String _locationMessage(LocationFailure reason, AppLocalizations l10n) =>
      switch (reason) {
        LocationFailure.serviceDisabled => l10n.arrivalsLocationDisabled,
        LocationFailure.denied => l10n.arrivalsLocationDenied,
        LocationFailure.deniedForever => l10n.arrivalsLocationDeniedForever,
        LocationFailure.unavailable => l10n.arrivalsLocationUnavailable,
      };

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final textTheme = Theme.of(context).textTheme;
        final zone = _controller.zone;
        final locating = _controller.locating;
        return SafeArea(
          child: Padding(
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
                Text(l10n.arrivalsZoneTitle, style: textTheme.titleLarge),
                const SizedBox(height: CosechaSpace.xxs),
                Text(
                  l10n.arrivalsSheetMessage,
                  style: textTheme.bodyMedium
                      ?.copyWith(color: context.cosechaContentSecondary),
                ),
                const SizedBox(height: CosechaSpace.md),
                CosechaOverline(l10n.arrivalsRadiusLabel),
                const SizedBox(height: CosechaSpace.xs),
                Wrap(
                  spacing: CosechaSpace.xs,
                  children: [
                    for (final radius in WarehouseZone.radiiKm)
                      CosechaFilterChip(
                        label: l10n.arrivalsRadiusValue(_km(radius)),
                        selected: radius == _radius,
                        onSelected: locating
                            ? null
                            : (_) => setState(() => _radius = radius),
                      ),
                  ],
                ),
                if (_error case final error?) ...[
                  const SizedBox(height: CosechaSpace.sm),
                  CosechaFieldError(error),
                ],
                const SizedBox(height: CosechaSpace.md),
                if (locating)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  if (zone != null && zone.radiusKm != _radius) ...[
                    CosechaPrimaryButton(
                      label: l10n.arrivalsSaveRadius,
                      icon: Icons.check,
                      onPressed: _saveRadius,
                    ),
                    const SizedBox(height: CosechaSpace.xs),
                  ],
                  if (zone == null)
                    CosechaPrimaryButton(
                      label: l10n.arrivalsUseLocation,
                      icon: Icons.my_location,
                      onPressed: _useCurrentLocation,
                    )
                  else
                    CosechaSecondaryButton(
                      label: l10n.arrivalsUpdateLocation,
                      icon: Icons.my_location,
                      onPressed: _useCurrentLocation,
                    ),
                  if (zone != null && _controller.canClearZone) ...[
                    const SizedBox(height: CosechaSpace.xs),
                    CosechaTextButton(
                      label: l10n.arrivalsRemoveZone,
                      icon: Icons.location_off_outlined,
                      onPressed: _remove,
                    ),
                  ],
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
