import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/incident.dart';
import 'evidence_photos.dart';
import 'incident_status_view.dart';

/// Incident detail, shown inside the shell (both bars visible). The top bar
/// shows "Incident INC-0007" and the back button.
class IncidentDetailPage extends StatelessWidget {
  const IncidentDetailPage({required this.incident, super.key});

  final Incident incident;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = incidentStatusView(incident.status, l10n);

    Widget divider() => const Padding(
          padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
          child: Divider(),
        );

    return ListView(
      padding: const EdgeInsets.fromLTRB(
        CosechaSpace.screenMargin,
        CosechaSpace.md,
        CosechaSpace.screenMargin,
        CosechaSpace.lg,
      ),
      children: [
        CosechaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      incident.code,
                      style: data.dataMono.copyWith(
                        color: context.cosechaContent,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                  CosechaStatusTag(label: status.label, status: status.status),
                ],
              ),
              divider(),
              if (incident.orderCode != null) ...[
                CosechaInfoRow(
                  icon: Icons.receipt_long_outlined,
                  label: l10n.qmOrder,
                  value: incident.orderCode!,
                  mono: true,
                ),
                divider(),
              ],
              CosechaInfoRow(
                icon: Icons.inventory_2_outlined,
                label: l10n.qmLot,
                value: incident.lotCode,
                mono: true,
              ),
              divider(),
              CosechaInfoRow(
                icon: Icons.event_outlined,
                label: l10n.qmReportedAt,
                value: formatLongDate(context, incident.reportedAt),
              ),
            ],
          ),
        ),
        const SizedBox(height: CosechaSpace.md),
        CosechaOverline(l10n.qmDescription),
        const SizedBox(height: CosechaSpace.xs),
        CosechaCard(
          child: Text(
            incident.description,
            style: textTheme.bodyLarge?.copyWith(color: context.cosechaContent),
          ),
        ),
        const SizedBox(height: CosechaSpace.md),
        CosechaOverline(l10n.qmPhotos),
        const SizedBox(height: CosechaSpace.xs),
        if (incident.evidence.isEmpty && incident.evidenceUrls.isNotEmpty)
          // Photos taken on another phone: shown from the platform.
          Wrap(
            spacing: CosechaSpace.xs,
            runSpacing: CosechaSpace.xs,
            children: [
              for (final (i, url) in incident.evidenceUrls.indexed)
                ClipRRect(
                  borderRadius: CosechaRadius.cardAll,
                  child: Image.network(
                    url,
                    width: 96,
                    height: 96,
                    fit: BoxFit.cover,
                    semanticLabel: l10n.qmPhotoLabel(i + 1),
                    errorBuilder: (_, _, _) => const SizedBox(
                      width: 96,
                      height: 96,
                      child: Icon(Icons.broken_image_outlined),
                    ),
                  ),
                ),
            ],
          )
        else if (incident.evidence.isEmpty)
          Text(
            l10n.qmPhotoCount(0),
            style: textTheme.bodyMedium
                ?.copyWith(color: context.cosechaContentSecondary),
          )
        else ...[
          EvidenceGallery(
            photos: [for (final photo in incident.evidence) photo.bytes],
          ),
          const SizedBox(height: CosechaSpace.xs),
          Text(
            l10n.qmPhotosLocalNote,
            style: textTheme.bodySmall
                ?.copyWith(color: context.cosechaContentSecondary),
          ),
        ],
      ],
    );
  }
}
