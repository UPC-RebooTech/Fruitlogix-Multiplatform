import 'package:flutter/foundation.dart';

/// US72 — Stages of a lot, in chain order (which is also chronological).
enum TraceStage { harvested, inspected, loaded, received, invoiced }

enum TraceState {
  /// Happened, with its record.
  done,

  /// Not reached yet ("To do").
  pending,

  /// Happened (a later stage is done) but the platform has no record.
  noRecord,
}

enum InspectionResult { approved, rejected }

@immutable
class TraceEvent {
  const TraceEvent({
    required this.stage,
    required this.state,
    this.at,
    this.responsible,
    this.inspectionResult,
  });

  final TraceStage stage;
  final TraceState state;
  final DateTime? at;
  final String? responsible;
  final InspectionResult? inspectionResult;
}

/// Harvest and quality data of a lot (Quality Management / harvest
/// batches). Null while orders are not linked to lots in the platform.
@immutable
class LotRecord {
  const LotRecord({
    required this.lotCode,
    this.harvestedAt,
    this.harvestedBy,
    this.inspectedAt,
    this.inspectedBy,
    this.inspectionResult,
    this.loadedAt,
  });

  final String lotCode;
  final DateTime? harvestedAt;
  final String? harvestedBy;
  final DateTime? inspectedAt;
  final String? inspectedBy;
  final InspectionResult? inspectionResult;
  final DateTime? loadedAt;
}

/// Lot records per order code.
abstract interface class LotRecordSource {
  LotRecord? forOrder(String orderCode);
}

/// What the other bounded contexts know about one order.
@immutable
class TraceInputs {
  const TraceInputs({
    required this.orderCode,
    this.productSummary,
    this.lot,
    this.loaded = false,
    this.loadedBy,
    this.received = false,
    this.receivedAt,
    this.receivedBy,
    this.invoiced = false,
    this.invoicedAt,
    this.invoicedBy,
  });

  final String orderCode;
  final String? productSummary;
  final LotRecord? lot;

  /// Dispatched (delivery dispatched or later, or order in transit).
  final bool loaded;
  final String? loadedBy;
  final bool received;
  final DateTime? receivedAt;
  final String? receivedBy;
  final bool invoiced;
  final DateTime? invoicedAt;
  final String? invoicedBy;
}

@immutable
class LotTimeline {
  const LotTimeline({
    required this.orderCode,
    required this.events,
    this.lotCode,
    this.productSummary,
  });

  final String orderCode;
  final String? lotCode;
  final String? productSummary;

  /// One event per stage, in chain (chronological) order.
  final List<TraceEvent> events;

  bool get isComplete => events.every((e) => e.state != TraceState.pending);
  bool get hasMissingRecords =>
      events.any((e) => e.state == TraceState.noRecord);
}

/// Builds the timeline: stages with data are done; stages without data
/// before the last done stage are "no record"; the rest are pending.
LotTimeline buildLotTimeline(TraceInputs input) {
  final lot = input.lot;
  final facts = <TraceStage, TraceEvent?>{
    TraceStage.harvested: lot?.harvestedAt == null
        ? null
        : TraceEvent(
            stage: TraceStage.harvested,
            state: TraceState.done,
            at: lot!.harvestedAt,
            responsible: lot.harvestedBy,
          ),
    TraceStage.inspected: lot?.inspectedAt == null
        ? null
        : TraceEvent(
            stage: TraceStage.inspected,
            state: TraceState.done,
            at: lot!.inspectedAt,
            responsible: lot.inspectedBy,
            inspectionResult: lot.inspectionResult,
          ),
    TraceStage.loaded: !input.loaded
        ? null
        : TraceEvent(
            stage: TraceStage.loaded,
            state: TraceState.done,
            at: lot?.loadedAt,
            responsible: input.loadedBy,
          ),
    TraceStage.received: !input.received
        ? null
        : TraceEvent(
            stage: TraceStage.received,
            state: TraceState.done,
            at: input.receivedAt,
            responsible: input.receivedBy,
          ),
    TraceStage.invoiced: !input.invoiced
        ? null
        : TraceEvent(
            stage: TraceStage.invoiced,
            state: TraceState.done,
            at: input.invoicedAt,
            responsible: input.invoicedBy,
          ),
  };

  // Only the physical chain proves that earlier stages happened: an invoice
  // can be issued before the goods arrive, so it never marks "received" as
  // done-without-record.
  const physical = [
    TraceStage.harvested,
    TraceStage.inspected,
    TraceStage.loaded,
    TraceStage.received,
  ];
  final lastDone = physical.lastIndexWhere((s) => facts[s] != null);
  return LotTimeline(
    orderCode: input.orderCode,
    lotCode: lot?.lotCode,
    productSummary: input.productSummary,
    events: [
      for (final stage in TraceStage.values)
        facts[stage] ??
            TraceEvent(
              stage: stage,
              state: stage.index < lastDone
                  ? TraceState.noRecord
                  : TraceState.pending,
            ),
    ],
  );
}
