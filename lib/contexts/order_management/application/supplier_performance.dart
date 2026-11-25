import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';

/// US24 — On-time and late orders of one supplier (producer).
@immutable
class SupplierPerformance {
  const SupplierPerformance({
    required this.producerId,
    required this.onTime,
    required this.late,
  });

  final int producerId;
  final int onTime;
  final int late;

  int get total => onTime + late;

  /// 0..1; 0 when there is nothing to measure.
  double get onTimeRate => total == 0 ? 0 : onTime / total;

  int get onTimePercent => (onTimeRate * 100).round();
  int get latePercent => total == 0 ? 0 : 100 - onTimePercent;
}

/// Overall result plus one row per supplier.
@immutable
class SupplierPerformanceReport {
  const SupplierPerformanceReport({
    required this.overall,
    required this.suppliers,
  });

  /// `producerId` is 0 for the overall row.
  final SupplierPerformance overall;

  /// Most measured orders first.
  final List<SupplierPerformance> suppliers;

  bool get hasData => overall.total > 0;
}

/// Measures delivery compliance per producer.
///
/// - Delivered with a completion date: on time when completed on or before
///   the delivery due date (calendar days), late otherwise.
/// - Still active after its due date: late.
/// - Cancelled, rejected, not yet due, without producer or without
///   completion date: not counted.
SupplierPerformanceReport measureSupplierPerformance(
  Iterable<CommercialOrder> orders, {
  required DateTime today,
}) {
  DateTime day(DateTime d) => DateTime(d.year, d.month, d.day);
  final now = day(today);
  final onTime = <int, int>{};
  final late = <int, int>{};

  for (final order in orders) {
    final producer = order.producerId;
    if (producer == null) continue;
    final due = day(order.deliveryDate);
    bool? wasOnTime;
    if (order.status.isDelivered && order.completedAt != null) {
      wasOnTime = !day(order.completedAt!).isAfter(due);
    } else if (order.status.isActive && due.isBefore(now)) {
      wasOnTime = false;
    }
    if (wasOnTime == null) continue;
    final bucket = wasOnTime ? onTime : late;
    bucket[producer] = (bucket[producer] ?? 0) + 1;
  }

  final producers = {...onTime.keys, ...late.keys};
  final suppliers =
      [
        for (final id in producers)
          SupplierPerformance(
            producerId: id,
            onTime: onTime[id] ?? 0,
            late: late[id] ?? 0,
          ),
      ]..sort((a, b) {
        final byTotal = b.total.compareTo(a.total);
        return byTotal != 0 ? byTotal : a.producerId.compareTo(b.producerId);
      });

  return SupplierPerformanceReport(
    overall: SupplierPerformance(
      producerId: 0,
      onTime: onTime.values.fold(0, (a, b) => a + b),
      late: late.values.fold(0, (a, b) => a + b),
    ),
    suppliers: List.unmodifiable(suppliers),
  );
}
