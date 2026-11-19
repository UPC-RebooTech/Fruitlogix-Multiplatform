import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/shipment.dart';

/// Reception inspection at the dock. A field action: full-width rows
/// (whole row is touchable) and a 56 primary button.
class ConfirmReceptionPage extends StatefulWidget {
  const ConfirmReceptionPage({
    required this.shipment,
    required this.onConfirmed,
    super.key,
  });

  final DeliveryShipment shipment;
  final void Function(String notes, bool hasIncidents) onConfirmed;

  @override
  State<ConfirmReceptionPage> createState() => _ConfirmReceptionPageState();
}

class _ConfirmReceptionPageState extends State<ConfirmReceptionPage> {
  final _notesController = TextEditingController();
  bool _hasIncidents = false;
  bool _inspectionAccepted = true;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  void _confirm() {
    final messenger = ScaffoldMessenger.of(context);
    final message = AppLocalizations.of(context).receptionConfirmed;
    widget.onConfirmed(_notesController.text.trim(), _hasIncidents);
    Navigator.of(context).pop();
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final shipment = widget.shipment;
    final temperature =
        '${shipment.telemetry.temperatureC.toStringAsFixed(1)} °C';

    return CosechaSubpageScaffold(
      title: l10n.trackingConfirmReception,
      body: ListView(
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
                Text(shipment.itemsSummary, style: textTheme.bodyLarge),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
                  child: Divider(),
                ),
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
                  subtitle: Text(l10n.receptionArrivalTemp(temperature)),
                ),
                const Divider(indent: CosechaSpace.sm),
                CheckboxListTile(
                  value: _hasIncidents,
                  onChanged: (v) => setState(() => _hasIncidents = v ?? false),
                  title: Text(l10n.receptionReportIncident),
                  subtitle: Text(l10n.receptionReportIncidentDetail),
                ),
              ],
            ),
          ),
          const SizedBox(height: CosechaSpace.md),

          CosechaTextField(
            label: l10n.receptionNotes,
            hint: l10n.receptionNotesHint,
            controller: _notesController,
            maxLines: 3,
          ),
          const SizedBox(height: CosechaSpace.md),

          CosechaPrimaryButton(
            label: l10n.trackingConfirmReception,
            icon: Icons.check,
            onPressed: _confirm,
          ),
        ],
      ),
    );
  }
}
