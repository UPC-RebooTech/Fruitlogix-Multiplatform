import '../domain/geofence.dart';
import '../domain/shipment.dart';

/// Reads `DeliveryResource`, `TrackingLogResource` and
/// `DeliveryEventResource` from the platform API. Statuses always come as
/// text (`PendingDispatch`, `InTransit`, `Delayed`, `Arrived`,
/// `Delivered`, `Failed`); unknown values never break the screen.
abstract final class DeliveryJsonParser {
  static List<Map<dynamic, dynamic>> list(Object? body) {
    final raw = switch (body) {
      List() => body,
      Map() => body['data'] ?? body['items'],
      null => const [],
      _ => null,
    };
    if (raw is! List) throw const FormatException('Not a list');
    return [
      for (final item in raw)
        if (item is Map) item,
    ];
  }

  static int? orderIdOf(Map<dynamic, dynamic> json) => _int(json['orderId']);
  static int? idOf(Map<dynamic, dynamic> json) => _int(json['id']);

  static DeliveryShipment parse(
    Map<dynamic, dynamic> json, {
    required ShipmentOrderRef order,
    TelemetryLog? telemetry,
    List<TrackingEventItem> events = const [],
  }) {
    final id = _int(json['id']);
    if (id == null) throw const FormatException('Delivery without id');
    final status = parseStatus(json['currentStatus'] ?? json['status']);
    return DeliveryShipment(
      id: '$id',
      trackingNumber: 'TRK-${id.toString().padLeft(4, '0')}',
      orderId: order.orderCode,
      orderNumber: order.orderId,
      itemsSummary: order.itemsSummary,
      status: status,
      // After a restart: no second reception for a delivered order.
      isReceived: order.isDelivered || status == ShipmentStatus.delivered,
      estimatedArrival: _date(json['estimatedTimeOfArrival']),
      driverName: _text(json['driverName']),
      driverPhone: _text(json['driverPhone']),
      vehiclePlate: _text(json['vehiclePlate']),
      vehicleType: _text(json['vehicleType']),
      routeOrigin: _text(json['routeOrigin']),
      routeDestination: _text(json['routeDestination']),
      routeDistanceKm: _double(json['routeDistanceKm']),
      dispatchedAt: _date(json['dispatchedAt']),
      arrivedAt: _date(json['arrivedAt']),
      telemetry: telemetry,
      events: events,
      rating: order.rating,
    );
  }

  /// `GET /deliveries/{id}/events` (chronological). Malformed items are
  /// skipped. Every event already happened, so all are completed.
  static List<TrackingEventItem> events(Object? body) {
    final parsed = <TrackingEventItem>[];
    for (final json in list(body)) {
      final at = _date(json['occurredAt']);
      if (at == null) continue;
      parsed.add(TrackingEventItem(
        time: '',
        description: _text(json['name']) ?? '',
        isCompleted: true,
        type: eventType(json['type']),
        occurredAt: at,
        place: _text(json['name']),
        note: _text(json['note']),
      ));
    }
    parsed.sort((a, b) => a.occurredAt!.compareTo(b.occurredAt!));
    return parsed;
  }

  static DeliveryEventType eventType(Object? raw) =>
      switch ((raw ?? '').toString().trim().toLowerCase()) {
        'created' => DeliveryEventType.created,
        'dispatched' => DeliveryEventType.dispatched,
        'delayed' => DeliveryEventType.delayed,
        'checkpoint' => DeliveryEventType.checkpoint,
        'arrived' => DeliveryEventType.arrived,
        'delivered' => DeliveryEventType.delivered,
        _ => DeliveryEventType.other,
      };

  /// The most recent `TrackingLogResource`, or null without readings.
  static TelemetryLog? latestReading(Object? body) {
    TelemetryLog? latest;
    for (final json in list(body)) {
      final temperature = _double(json['temperature']);
      final humidity = _double(json['humidity']);
      if (temperature == null || humidity == null) continue;
      final at = _date(json['timestamp']);
      if (latest != null &&
          (at == null ||
              (latest.recordedAt != null && !at.isAfter(latest.recordedAt!)))) {
        continue;
      }
      final lat = _double(json['latitude']);
      final lng = _double(json['longitude']);
      final position = lat == null || lng == null ? null : GeoPoint(lat, lng);
      latest = TelemetryLog(
        temperatureC: temperature,
        humidityPercent: humidity,
        recordedAt: at,
        position: position != null && position.isValid ? position : null,
      );
    }
    return latest;
  }

  /// Text only: the platform never sends numbers (their order differs).
  static ShipmentStatus parseStatus(Object? raw) {
    if (raw is! String) return ShipmentStatus.failed;
    final value = raw.trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]+'),
      '',
    );
    const scheduled = [
      'pendingdispatch',
      'scheduled',
      'pending',
      'programado',
    ];
    const dispatched = [
      'dispatched',
      'dispatchstarted',
      'started',
      'despachado',
    ];
    const inTransit = [
      'intransit',
      'onroute',
      'enroute',
      'shipped',
      'enruta',
      'entransito',
      'entránsito',
    ];
    const delayed = ['delayed', 'late', 'retrasado', 'conretraso'];
    const arrived = [
      'arrived',
      'atdestination',
      'atdock',
      'llego',
      'llegó',
      'enmuelle',
    ];
    const delivered = [
      'delivered',
      'completed',
      'received',
      'entregado',
      'recibido',
    ];
    if (scheduled.contains(value)) return ShipmentStatus.scheduled;
    if (dispatched.contains(value)) return ShipmentStatus.dispatched;
    if (inTransit.contains(value)) return ShipmentStatus.inTransit;
    if (delayed.contains(value)) return ShipmentStatus.delayed;
    if (arrived.contains(value)) return ShipmentStatus.arrived;
    if (delivered.contains(value)) return ShipmentStatus.delivered;
    // `Failed` and any status this version does not know yet.
    return ShipmentStatus.failed;
  }

  static String? _text(Object? raw) {
    final value = raw?.toString().trim() ?? '';
    return value.isEmpty ? null : value;
  }

  static int? _int(Object? raw) => switch (raw) {
    int() => raw,
    num() => raw.toInt(),
    String() => int.tryParse(raw.trim()),
    _ => null,
  };

  static double? _double(Object? raw) => switch (raw) {
    num() => raw.toDouble(),
    String() => double.tryParse(raw.trim()),
    _ => null,
  };

  static DateTime? _date(Object? raw) =>
      raw is String ? DateTime.tryParse(raw)?.toLocal() : null;
}
