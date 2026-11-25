import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/lot_timeline.dart';

/// Loads the platform timeline, then shows [LotTimelinePage] (US72).
class LotTimelineLoader extends StatefulWidget {
  const LotTimelineLoader({
    required this.orderCode,
    required this.load,
    super.key,
  });

  final String orderCode;
  final Future<LotTimeline> Function() load;

  @override
  State<LotTimelineLoader> createState() => _LotTimelineLoaderState();
}

class _LotTimelineLoaderState extends State<LotTimelineLoader> {
  late Future<LotTimeline> _timeline = widget.load();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return FutureBuilder<LotTimeline>(
      future: _timeline,
      builder: (context, snapshot) {
        if (snapshot.hasData) return LotTimelinePage(timeline: snapshot.data!);
        return CosechaSubpageScaffold(
          title: l10n.traceTitle(widget.orderCode),
          body: Center(
            child: snapshot.hasError
                ? Padding(
                    padding: const EdgeInsets.all(CosechaSpace.screenMargin),
                    child: CosechaEmptyState(
                      isError: true,
                      title: l10n.traceLoadError,
                      action: CosechaTextButton(
                        label: l10n.qmRetry,
                        icon: Icons.refresh,
                        onPressed: () =>
                            setState(() => _timeline = widget.load()),
                      ),
                    ),
                  )
                : const CircularProgressIndicator(),
          ),
        );
      },
    );
  }
}

/// US72 — Traceability of an order's lot: harvested, inspected, loaded,
/// received and invoiced, in chain (chronological) order, with date, time
/// and the person responsible. Pending stages read "To do".
class LotTimelinePage extends StatelessWidget {
  const LotTimelinePage({required this.timeline, super.key});

  final LotTimeline timeline;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final done = timeline.events
        .where((e) => e.state == TraceState.done)
        .length;

    return CosechaSubpageScaffold(
      title: l10n.traceTitle(timeline.orderCode),
      body: ListView(
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
                        timeline.orderCode,
                        style: data.dataMono.copyWith(
                          color: context.cosechaContent,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    CosechaStatusTag(
                      label: l10n.traceProgress(done, timeline.applicableCount),
                      status: timeline.isComplete
                          ? CosechaStatus.success
                          : CosechaStatus.info,
                    ),
                  ],
                ),
                if (timeline.productSummary != null) ...[
                  const SizedBox(height: CosechaSpace.xxs),
                  Text(
                    timeline.productSummary!,
                    style: textTheme.bodyMedium?.copyWith(
                      color: context.cosechaContentSecondary,
                    ),
                  ),
                ],
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: CosechaSpace.inner),
                  child: Divider(),
                ),
                CosechaInfoRow(
                  icon: Icons.inventory_2_outlined,
                  label: l10n.qmLot,
                  value: timeline.lotCode ?? l10n.traceLotUnknown,
                  mono: timeline.lotCode != null,
                ),
              ],
            ),
          ),
          const SizedBox(height: CosechaSpace.md),
          CosechaOverline(l10n.traceStagesTitle),
          const SizedBox(height: CosechaSpace.xs),
          CosechaCard(
            child: Column(
              children: [
                for (var i = 0; i < timeline.events.length; i++)
                  _StageRow(
                    event: timeline.events[i],
                    isLast: i == timeline.events.length - 1,
                    // Solid only between two stages that happened.
                    nextDone:
                        i + 1 < timeline.events.length &&
                        timeline.events[i].state != TraceState.pending &&
                        timeline.events[i + 1].state != TraceState.pending,
                  ),
              ],
            ),
          ),
          if (timeline.hasMissingRecords) ...[
            const SizedBox(height: CosechaSpace.xs),
            Text(
              l10n.traceNoRecordNote,
              style: textTheme.bodySmall?.copyWith(
                color: context.cosechaContentSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _StageRow extends StatelessWidget {
  const _StageRow({
    required this.event,
    required this.isLast,
    required this.nextDone,
  });

  final TraceEvent event;
  final bool isLast;

  /// The connector to the next stage is solid when that stage happened.
  final bool nextDone;

  static String stageName(TraceStage stage, AppLocalizations l10n) =>
      switch (stage) {
        TraceStage.harvested => l10n.traceHarvested,
        TraceStage.inspected => l10n.traceInspected,
        TraceStage.loaded => l10n.traceLoaded,
        TraceStage.received => l10n.traceReceived,
        TraceStage.invoiced => l10n.traceInvoiced,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final data = CosechaDataText.of(context);
    final success = CosechaStatusColors.of(context).success.color;

    final (IconData icon, Color color) = switch (event.state) {
      TraceState.done => (Icons.check_circle, success),
      TraceState.noRecord => (Icons.help_outline, scheme.onSurfaceVariant),
      TraceState.pending => (Icons.radio_button_unchecked, scheme.outline),
      TraceState.notApplicable => (Icons.remove_circle_outline, scheme.outline),
    };
    final name = stageName(event.stage, l10n);
    final when = event.at == null
        ? null
        : '${formatLongDate(context, event.at!)} · '
              '${MaterialLocalizations.of(context).formatTimeOfDay(TimeOfDay.fromDateTime(event.at!))}';
    final result = switch (event.inspectionResult) {
      InspectionResult.approved => l10n.traceInspectionApproved,
      InspectionResult.rejected => l10n.traceInspectionRejected,
      null => null,
    };
    final stateLabel = switch (event.state) {
      TraceState.done => null,
      TraceState.pending => l10n.tracePending,
      TraceState.noRecord => l10n.traceNoRecord,
      TraceState.notApplicable => l10n.traceNotApplicable,
    };

    final semantics = [
      name,
      ?stateLabel,
      if (event.state == TraceState.done) when ?? l10n.traceNoDate,
      if (event.responsible != null) l10n.traceResponsible(event.responsible!),
      ?result,
    ].join(', ');

    return Semantics(
      container: true,
      label: semantics,
      excludeSemantics: true,
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              width: CosechaSize.icon,
              child: Column(
                children: [
                  Icon(icon, size: CosechaSize.icon, color: color),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: nextDone ? success : scheme.outlineVariant,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: CosechaSpace.inner),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(bottom: isLast ? 0 : CosechaSpace.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            name,
                            style: textTheme.titleSmall?.copyWith(
                              color: event.state == TraceState.pending
                                  ? context.cosechaContentSecondary
                                  : context.cosechaContent,
                            ),
                          ),
                        ),
                        if (stateLabel != null)
                          CosechaStatusTag(
                            label: stateLabel,
                            status: CosechaStatus.neutral,
                          ),
                        if (result != null)
                          CosechaStatusTag(
                            label: result,
                            status:
                                event.inspectionResult ==
                                    InspectionResult.approved
                                ? CosechaStatus.success
                                : CosechaStatus.critical,
                          ),
                      ],
                    ),
                    if (event.state == TraceState.done)
                      Text(
                        when ?? l10n.traceNoDate,
                        style: data.dataMonoSmall.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
                      ),
                    if (event.responsible != null)
                      Text(
                        l10n.traceResponsible(event.responsible!),
                        style: textTheme.bodySmall?.copyWith(
                          color: context.cosechaContentSecondary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
