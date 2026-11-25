import '../domain/lot_timeline.dart';

/// `GET /orders/{id}/traceability` → [LotTimeline] (US72).
///
/// Stages: Harvest, Inspection, Dispatch, Reception, Invoice. Status:
/// Completed, Pending, NotApplicable (cancelled or rejected order).
/// `details` is a map of strings; the harvest one carries the lot status,
/// used as the inspection result.
abstract final class TraceabilityJsonParser {
  static LotTimeline parse(
    Object? body, {
    required String orderCode,
    String? productSummary,
  }) {
    if (body is! Map) throw const FormatException('Traceability: not an object');
    final stages = body['stages'];
    final byStage = <TraceStage, Map<dynamic, dynamic>>{
      if (stages is List)
        for (final item in stages)
          if (item is Map)
            ?stageOf(item['stage']): item,
    };
    final batchStatus = _details(byStage[TraceStage.harvested])['batchStatus'];
    final result = switch ('${batchStatus ?? ''}'.toLowerCase()) {
      'approved' => InspectionResult.approved,
      'rejected' => InspectionResult.rejected,
      _ => null,
    };
    final batchId = body['batchId'];
    return LotTimeline(
      orderCode: orderCode,
      productSummary: productSummary,
      lotCode: batchId == null
          ? null
          : 'LOT-${batchId.toString().padLeft(4, '0')}',
      events: [
        for (final stage in TraceStage.values)
          _event(
            stage,
            byStage[stage],
            inspection: stage == TraceStage.inspected ? result : null,
          ),
      ],
    );
  }

  static TraceStage? stageOf(Object? raw) =>
      switch ('${raw ?? ''}'.trim().toLowerCase()) {
        'harvest' => TraceStage.harvested,
        'inspection' => TraceStage.inspected,
        'dispatch' => TraceStage.loaded,
        'reception' => TraceStage.received,
        'invoice' => TraceStage.invoiced,
        _ => null,
      };

  static TraceEvent _event(
    TraceStage stage,
    Map<dynamic, dynamic>? json, {
    InspectionResult? inspection,
  }) {
    final status = '${json?['status'] ?? ''}'.trim().toLowerCase();
    final state = switch (status) {
      'completed' => TraceState.done,
      'notapplicable' => TraceState.notApplicable,
      _ => TraceState.pending,
    };
    final at = json?['occurredAt'];
    final responsible = json?['responsible'];
    return TraceEvent(
      stage: stage,
      state: state,
      // Older records can be completed without date or responsible.
      at: at is String ? DateTime.tryParse(at)?.toLocal() : null,
      responsible: responsible is String && responsible.trim().isNotEmpty
          ? responsible.trim()
          : null,
      inspectionResult: state == TraceState.done ? inspection : null,
    );
  }

  static Map<dynamic, dynamic> _details(Map<dynamic, dynamic>? stage) {
    final details = stage?['details'];
    return details is Map ? details : const {};
  }
}
