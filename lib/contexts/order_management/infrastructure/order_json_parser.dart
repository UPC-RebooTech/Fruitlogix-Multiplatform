import '../domain/commercial_order.dart';
import '../domain/fruit_product.dart';

/// Converts between the platform API and the Order Management domain.
///
/// The Swagger contract documents the request (`CreateOrderResource`) but
/// not the responses, so parsing accepts common field names and status
/// spellings (English/Spanish, any case, numeric enums).
abstract final class OrderJsonParser {
  /// `CreateOrderResource` body of `POST /api/v1/orders`.
  static Map<String, Object?> toCreateBody(
    NewOrder order, {
    required int clientId,
  }) => {
    'commercialClientId': clientId,
    // Swagger `format: date` (.NET DateOnly): `2026-12-15`, no time. A full
    // timestamp is rejected with "One or more validation errors occurred".
    'deliveryDueDate': formatApiDate(order.deliveryDate),
    'deliveryAddress': order.deliveryAddress.trim(),
    'totalAmount': _money(order.total),
    'notes': order.notes?.trim() ?? '',
    'items': [
      for (final line in order.lines)
        {
          'productId': line.product.id,
          'productName': line.product.name,
          'quantityKg': line.quantity,
          'unitPrice': _money(line.product.price),
          'subtotal': _money(line.subtotal),
        },
    ],
  };

  /// A JSON list, or an object wrapping it in `data`/`items`/`orders`.
  /// Malformed items are skipped.
  static List<CommercialOrder> parseList(Object? body) {
    final list = switch (body) {
      List() => body,
      Map() => body['data'] ?? body['items'] ?? body['orders'],
      null => const [],
      _ => null,
    };
    if (list is! List) throw const FormatException('Orders: not a list');
    return [
      for (final item in list)
        if (item is Map) ?_tryParse(item),
    ];
  }

  static CommercialOrder? _tryParse(Map<dynamic, dynamic> json) {
    try {
      return parse(json);
    } on FormatException {
      return null;
    }
  }

  static CommercialOrder parse(Map<dynamic, dynamic> json) {
    final id = json['id'] ?? json['orderId'];
    if (id == null) throw const FormatException('Order without id');
    final items = json['items'] ?? json['orderItems'] ?? json['lines'];
    final delivery = _date(
      json['deliveryDueDate'] ?? json['deliveryDate'] ?? json['dueDate'],
    );
    final created = _date(
      json['createdAt'] ?? json['orderDate'] ?? json['created'],
    );
    if (delivery == null && created == null) {
      throw const FormatException('Order without dates');
    }
    final notes = (json['notes'] ?? '').toString().trim();
    return CommercialOrder(
      id: '$id',
      lines: [
        if (items is List)
          for (final item in items)
            if (item is Map) _line(item),
      ],
      deliveryAddress: (json['deliveryAddress'] ?? json['address'] ?? '')
          .toString()
          .trim(),
      deliveryDate: delivery ?? created!,
      createdAt: created,
      status: parseStatus(
        json['status'] ?? json['orderStatus'] ?? json['currentStatus'],
      ),
      notes: notes.isEmpty ? null : notes,
      producerId: _int(json['producerId']),
      totalAmount: _double(json['totalAmount'] ?? json['total']),
    );
  }

  /// `GET /api/v1/producers` → id → display name (`legalName`, then
  /// `fullName`). Malformed entries are skipped.
  static Map<int, String> parseProducerNames(Object? body) {
    final list = switch (body) {
      List() => body,
      Map() => body['data'] ?? body['items'],
      _ => null,
    };
    if (list is! List) return const {};
    final names = <int, String>{};
    for (final item in list) {
      if (item is! Map) continue;
      final id = _int(item['id']);
      final name = _producerName(item);
      if (id != null && name != null) names[id] = name;
    }
    return names;
  }

  static String? _producerName(Map<dynamic, dynamic> json) {
    for (final key in ['legalName', 'fullName', 'name']) {
      final value = (json[key] ?? '').toString().trim();
      if (value.isNotEmpty) return value;
    }
    return null;
  }

  static OrderLine _line(Map<dynamic, dynamic> json) {
    final quantity = _double(json['quantityKg'] ?? json['quantity']) ?? 0;
    final subtotal = _double(json['subtotal']);
    var unitPrice = _double(json['unitPrice'] ?? json['price']);
    if (unitPrice == null && subtotal != null && quantity > 0) {
      unitPrice = subtotal / quantity;
    }
    return OrderLine(
      product: FruitProduct(
        id: _int(json['productId']) ?? 0,
        name: (json['productName'] ?? json['name'] ?? '').toString().trim(),
        description: '',
        category: '',
        price: unitPrice ?? 0,
        stock: 0,
      ),
      // The app sells whole kilograms.
      quantity: quantity.round(),
    );
  }

  static OrderStatus parseStatus(Object? raw) {
    if (raw is num) {
      return switch (raw.toInt()) {
        1 => OrderStatus.preparing,
        2 => OrderStatus.inTransit,
        3 => OrderStatus.delivered,
        4 => OrderStatus.cancelled,
        5 => OrderStatus.rejected,
        _ => OrderStatus.pending,
      };
    }
    final value = (raw ?? '').toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]+'),
      '',
    );
    const preparing = [
      'preparing',
      'inpreparation',
      'accepted',
      'confirmed',
      'assigned',
      'producerassigned',
      'processing',
      'enpreparacion',
      'enpreparación',
      'aceptado',
      'confirmado',
      'asignado',
    ];
    const inTransit = [
      'intransit',
      'dispatched',
      'shipped',
      'onroute',
      'enroute',
      'enruta',
      'despachado',
      'entransito',
      'entránsito',
    ];
    const delivered = [
      'delivered',
      'received',
      'completed',
      'entregado',
      'recibido',
      'completado',
    ];
    const cancelled = ['cancelled', 'canceled', 'cancelado', 'anulado'];
    const rejected = ['rejected', 'rechazado'];
    if (preparing.contains(value)) return OrderStatus.preparing;
    if (inTransit.contains(value)) return OrderStatus.inTransit;
    if (delivered.contains(value)) return OrderStatus.delivered;
    if (cancelled.contains(value)) return OrderStatus.cancelled;
    if (rejected.contains(value)) return OrderStatus.rejected;
    return OrderStatus.pending;
  }

  /// Client id of a returned order, when the API includes it.
  static int? clientIdOf(Map<dynamic, dynamic> json) =>
      _int(json['commercialClientId'] ?? json['clientId']);

  /// `yyyy-MM-dd` of the calendar day of [date].
  static String formatApiDate(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static double _money(double value) => (value * 100).roundToDouble() / 100;

  static int? _int(Object? raw) => switch (raw) {
    int() => raw,
    num() => raw.toInt(),
    String() => int.tryParse(raw.trim()),
    _ => null,
  };

  static double? _double(Object? raw) => switch (raw) {
    num() => raw.toDouble(),
    String() => double.tryParse(raw.trim().replaceAll(',', '')),
    _ => null,
  };

  static DateTime? _date(Object? raw) =>
      raw is String ? DateTime.tryParse(raw)?.toLocal() : null;
}
