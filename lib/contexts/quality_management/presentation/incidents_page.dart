import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/incidents_controller.dart';
import '../domain/incident.dart';
import 'evidence_photos.dart';
import 'incident_status_view.dart';

enum _IncidentFilter { all, open, inReview, closed }

/// Main screen of Quality Management for the Commercial Client
/// ("More → Incidents"): counters, the report action and the history.
class IncidentsPage extends StatefulWidget {
  const IncidentsPage({
    required this.controller,
    required this.onOpenIncident,
    required this.onReport,
    super.key,
  });

  final IncidentsController controller;
  final ValueChanged<Incident> onOpenIncident;
  final VoidCallback onReport;

  @override
  State<IncidentsPage> createState() => _IncidentsPageState();
}

class _IncidentsPageState extends State<IncidentsPage> {
  _IncidentFilter _filter = _IncidentFilter.all;

  bool _matches(Incident incident) => switch (_filter) {
    _IncidentFilter.all => true,
    _IncidentFilter.open => incident.status == IncidentStatus.open,
    _IncidentFilter.inReview => incident.status == IncidentStatus.inReview,
    _IncidentFilter.closed => incident.status.isClosed,
  };

  String _filterLabel(AppLocalizations l10n, _IncidentFilter filter) =>
      switch (filter) {
        _IncidentFilter.all => l10n.qmFilterAll,
        _IncidentFilter.open => l10n.qmKpiOpen,
        _IncidentFilter.inReview => l10n.qmKpiInReview,
        _IncidentFilter.closed => l10n.qmKpiClosed,
      };

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final loading =
            !controller.hasData && controller.status != IncidentsStatus.failure;
        String count(int value) => loading ? '…' : '$value';

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
              // Same height for the three counters even if a label wraps.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: CosechaKpiCard(
                        compact: true,
                        label: l10n.qmKpiOpen,
                        value: count(controller.openCount),
                      ),
                    ),
                    const SizedBox(width: CosechaSpace.xs),
                    Expanded(
                      child: CosechaKpiCard(
                        compact: true,
                        label: l10n.qmKpiInReview,
                        value: count(controller.inReviewCount),
                      ),
                    ),
                    const SizedBox(width: CosechaSpace.xs),
                    Expanded(
                      child: CosechaKpiCard(
                        compact: true,
                        label: l10n.qmKpiClosed,
                        value: count(controller.closedCount),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: CosechaSpace.sm),
              // The one primary action of the screen.
              CosechaPrimaryButton(
                label: l10n.qmReportIncident,
                icon: Icons.add_a_photo_outlined,
                onPressed: widget.onReport,
              ),
              const SizedBox(height: CosechaSpace.md),
              CosechaOverline(l10n.qmYourIncidents),
              const SizedBox(height: CosechaSpace.xs),
              Wrap(
                spacing: CosechaSpace.xs,
                runSpacing: CosechaSpace.xs,
                children: [
                  for (final filter in _IncidentFilter.values)
                    CosechaFilterChip(
                      label: _filterLabel(l10n, filter),
                      selected: _filter == filter,
                      onSelected: (_) => setState(() => _filter = filter),
                    ),
                ],
              ),
              const SizedBox(height: CosechaSpace.sm),
              ..._list(context, l10n, loading),
            ],
          ),
        );
      },
    );
  }

  List<Widget> _list(
    BuildContext context,
    AppLocalizations l10n,
    bool loading,
  ) {
    final controller = widget.controller;
    if (loading) {
      return const [
        Padding(
          padding: EdgeInsets.all(CosechaSpace.md),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (controller.status == IncidentsStatus.failure &&
        controller.incidents.isEmpty) {
      return [
        CosechaEmptyState(
          isError: true,
          title: qualityErrorMessage(
            controller.error,
            l10n,
            fallback: l10n.qmLoadError,
          ),
          action: CosechaTextButton(
            label: l10n.qmRetry,
            icon: Icons.refresh,
            onPressed: controller.load,
          ),
        ),
      ];
    }
    if (controller.incidents.isEmpty) {
      return [
        CosechaEmptyState(
          icon: Icons.fact_check_outlined,
          title: l10n.qmEmptyTitle,
          message: l10n.qmEmptyMessage,
        ),
      ];
    }
    final visible = controller.incidents.where(_matches).toList();
    if (visible.isEmpty) {
      return [
        CosechaEmptyState(icon: Icons.filter_list, title: l10n.qmEmptyFilter),
      ];
    }
    return [
      for (final incident in visible) ...[
        _IncidentCard(
          incident: incident,
          onTap: () => widget.onOpenIncident(incident),
        ),
        const SizedBox(height: CosechaSpace.xs),
      ],
    ];
  }
}

class _IncidentCard extends StatelessWidget {
  const _IncidentCard({required this.incident, required this.onTap});

  final Incident incident;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final status = incidentStatusView(incident.status, l10n);
    final reference = incident.orderCode == null
        ? incident.lotCode
        : l10n.qmTargetValue(incident.orderCode!, incident.lotCode);
    final date = formatLongDate(context, incident.reportedAt);
    final photos = incident.evidence.length;

    return CosechaCard(
      onTap: onTap,
      semanticLabel:
          '${l10n.qmIncidentTitle(incident.code)}, ${status.label}, '
          '$reference, $date, ${l10n.qmPhotoCount(photos)}',
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        incident.code,
                        style: data.dataMono.copyWith(
                          color: context.cosechaContent,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: CosechaSpace.xs),
                    CosechaStatusTag(
                      label: status.label,
                      status: status.status,
                    ),
                  ],
                ),
                const SizedBox(height: CosechaSpace.xxs),
                Text(
                  incident.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.bodyMedium?.copyWith(
                    color: context.cosechaContent,
                  ),
                ),
                const SizedBox(height: CosechaSpace.xs),
                Text(
                  reference,
                  style: data.dataMonoSmall.copyWith(
                    color: context.cosechaContentSecondary,
                  ),
                ),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        date,
                        style: textTheme.bodySmall?.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
                      ),
                    ),
                    if (photos > 0) ...[
                      Icon(
                        Icons.photo_camera_outlined,
                        size: 16,
                        color: context.cosechaContentSecondary,
                      ),
                      const SizedBox(width: CosechaSpace.xxs),
                      Text(
                        l10n.qmPhotoCount(photos),
                        style: textTheme.bodySmall?.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (photos > 0) ...[
            const SizedBox(width: CosechaSpace.inner),
            ExcludeSemantics(
              child: IgnorePointer(
                child: EvidenceThumbnail(
                  bytes: incident.evidence.first.bytes,
                  label: l10n.qmPhotoLabel(1),
                  size: 64,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
