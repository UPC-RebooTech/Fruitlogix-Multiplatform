import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';
import '../infrastructure/fruitlogix_logistics_api.dart';

/// Reception inspection at the dock, with the service rating (US35).
///
/// A field action: full-width rows (the whole row is touchable) and a 56
/// primary button. The rating is optional (US35 · scenario 2). Pops with the
/// [ReceptionReport] once [onConfirm] succeeds.
class ConfirmReceptionPage extends StatefulWidget {
  const ConfirmReceptionPage({
    required this.shipment,
    required this.onConfirm,
    super.key,
  });

  final DeliveryShipment shipment;

  /// Sends the reception; throws when the platform rejects it.
  final Future<void> Function(ReceptionReport report) onConfirm;

  @override
  State<ConfirmReceptionPage> createState() => _ConfirmReceptionPageState();
}

class _ConfirmReceptionPageState extends State<ConfirmReceptionPage> {
  final _commentController = TextEditingController();
  bool _hasIncidents = false;
  bool _inspectionAccepted = true;
  int? _rating;
  bool _sending = false;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final comment = _commentController.text.trim();
    final report = ReceptionReport(
      rating: _rating,
      comment: comment.isEmpty ? null : comment,
      hasIncidence: _hasIncidents,
      sealAndTemperatureOk: _inspectionAccepted,
    );
    setState(() => _sending = true);
    try {
      await widget.onConfirm(report);
    } catch (error) {
      if (!mounted) return;
      setState(() => _sending = false);
      messenger.showSnackBar(
        SnackBar(content: Text(_errorMessage(error, l10n))),
      );
      return;
    }
    navigator.pop(report);
    messenger.showSnackBar(SnackBar(content: Text(l10n.receptionConfirmed)));
  }

  static String _errorMessage(Object error, AppLocalizations l10n) =>
      switch (error) {
        LogisticsApiException(reason: LogisticsApiFailure.network) =>
          l10n.authNetworkError,
        LogisticsApiException(reason: LogisticsApiFailure.unauthorized) =>
          l10n.qmSessionExpired,
        // The order is not in transit yet (dispatch pending).
        LogisticsApiException(reason: LogisticsApiFailure.conflict) =>
          l10n.receptionNotInTransit,
        LogisticsApiException(message: final String message)
            when message.isNotEmpty =>
          message,
        _ => l10n.receptionSendError,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final shipment = widget.shipment;
    final telemetry = shipment.telemetry;
    final temperature = telemetry == null
        ? null
        : '${telemetry.temperatureC.toStringAsFixed(1)} °C';

    return CosechaSubpageScaffold(
      title: l10n.trackingConfirmReception,
      body: AbsorbPointer(
        absorbing: _sending,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            CosechaSpace.screenMargin,
            CosechaSpace.md,
            CosechaSpace.screenMargin,
            CosechaSpace.lg,
          ),
          children: [
            CosechaCard(
              tone: CosechaCardTone.tint,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      shipment.trackingNumber,
                      style: CosechaDataText.of(context).dataMono.copyWith(
                        color: context.cosechaContent,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  CosechaStatusTag(
                    label: l10n.receptionArrived,
                    status: CosechaStatus.info,
                    icon: Icons.warehouse_outlined,
                  ),
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.md),

            CosechaOverline(l10n.receptionProducts),
            const SizedBox(height: CosechaSpace.xs),
            CosechaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (shipment.itemsSummary != null) ...[
                    Text(shipment.itemsSummary!, style: textTheme.bodyLarge),
                    const Padding(
                      padding: EdgeInsets.symmetric(
                        vertical: CosechaSpace.inner,
                      ),
                      child: Divider(),
                    ),
                  ],
                  CosechaInfoRow(
                    label: l10n.receptionOrderRef,
                    value: shipment.orderId,
                    mono: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.md),

            CosechaOverline(l10n.receptionInspection),
            const SizedBox(height: CosechaSpace.xs),
            CosechaCard(
              padding: EdgeInsets.zero,
              child: Column(
                children: [
                  SwitchListTile(
                    value: _inspectionAccepted,
                    onChanged: (v) => setState(() => _inspectionAccepted = v),
                    title: Text(l10n.receptionCompliant),
                    subtitle: temperature == null
                        ? null
                        : Text(l10n.receptionArrivalTemp(temperature)),
                  ),
                  const Divider(indent: CosechaSpace.sm),
                  CheckboxListTile(
                    value: _hasIncidents,
                    onChanged: (v) =>
                        setState(() => _hasIncidents = v ?? false),
                    title: Text(l10n.receptionReportIncident),
                    subtitle: Text(l10n.receptionReportIncidentDetail),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.md),

            // US35 — optional rating and comment.
            CosechaOverline(l10n.receptionRateSection),
            const SizedBox(height: CosechaSpace.xs),
            CosechaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.receptionRateQuestion,
                    style: textTheme.titleSmall?.copyWith(
                      color: context.cosechaContent,
                    ),
                  ),
                  Text(
                    l10n.receptionRateOptional,
                    style: textTheme.bodySmall?.copyWith(
                      color: context.cosechaContentSecondary,
                    ),
                  ),
                  const SizedBox(height: CosechaSpace.xs),
                  CosechaStarRating(
                    value: _rating,
                    onChanged: (value) => setState(() => _rating = value),
                    emptyLabel: l10n.receptionNotRated,
                    starLabel: (stars, max) => l10n.receptionStars(stars, max),
                    levelLabels: [
                      l10n.receptionRating1,
                      l10n.receptionRating2,
                      l10n.receptionRating3,
                      l10n.receptionRating4,
                      l10n.receptionRating5,
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.sm),
            CosechaTextField(
              label: l10n.receptionComment,
              hint: l10n.receptionCommentHint,
              controller: _commentController,
              maxLines: 3,
            ),
            const SizedBox(height: CosechaSpace.md),

            if (_sending) ...[
              CosechaProgressBar(
                value: null,
                semanticLabel: l10n.receptionSending,
              ),
              const SizedBox(height: CosechaSpace.sm),
            ],
            CosechaPrimaryButton(
              label: l10n.trackingConfirmReception,
              icon: Icons.check,
              onPressed: _sending ? null : _confirm,
            ),
          ],
        ),
      ),
    );
  }
}
