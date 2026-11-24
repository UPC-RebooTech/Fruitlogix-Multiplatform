import 'package:flutter/foundation.dart';

import '../domain/commercial_order.dart';

/// US08 — Search and filters of the order history: text (order code or
/// product), status, delivery date range and producer. Empty values mean
/// "any".
@immutable
class OrderHistoryFilter {
  const OrderHistoryFilter({
    this.query = '',
    this.status,
    this.from,
    this.to,
    this.producerId,
  });

  static const OrderHistoryFilter none = OrderHistoryFilter();

  final String query;
  final OrderStatus? status;

  /// Inclusive calendar days of the delivery date.
  final DateTime? from;
  final DateTime? to;
  final int? producerId;

  bool get hasDateRange => from != null || to != null;

  bool get isActive =>
      query.trim().isNotEmpty ||
      status != null ||
      hasDateRange ||
      producerId != null;

  bool matches(CommercialOrder order) {
    if (status != null && order.status != status) return false;
    if (producerId != null && order.producerId != producerId) return false;
    final day = DateTime(
      order.deliveryDate.year,
      order.deliveryDate.month,
      order.deliveryDate.day,
    );
    final start = from == null
        ? null
        : DateTime(from!.year, from!.month, from!.day);
    final end = to == null ? null : DateTime(to!.year, to!.month, to!.day);
    if (start != null && day.isBefore(start)) return false;
    if (end != null && day.isAfter(end)) return false;
    final text = _normalize(query);
    if (text.isEmpty) return true;
    return _normalize(order.code).contains(text) ||
        _normalize(order.id).contains(text) ||
        order.lines.any((line) => _normalize(line.product.name).contains(text));
  }

  List<CommercialOrder> apply(Iterable<CommercialOrder> orders) =>
      orders.where(matches).toList(growable: false);

  OrderHistoryFilter copyWith({
    String? query,
    OrderStatus? Function()? status,
    DateTime? Function()? from,
    DateTime? Function()? to,
    int? Function()? producerId,
  }) => OrderHistoryFilter(
    query: query ?? this.query,
    status: status == null ? this.status : status(),
    from: from == null ? this.from : from(),
    to: to == null ? this.to : to(),
    producerId: producerId == null ? this.producerId : producerId(),
  );

  /// Case and accent insensitive ("Mangó" finds "mango").
  static String _normalize(String value) {
    const accents = {
      'á': 'a',
      'é': 'e',
      'í': 'i',
      'ó': 'o',
      'ú': 'u',
      'ü': 'u',
      'ñ': 'n',
    };
    final lower = value.trim().toLowerCase();
    final buffer = StringBuffer();
    for (final char in lower.split('')) {
      buffer.write(accents[char] ?? char);
    }
    return buffer.toString();
  }
}
