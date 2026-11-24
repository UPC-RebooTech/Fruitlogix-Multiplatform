import '../domain/shipment.dart';

/// Reads `DeliveryResource` and `TrackingLogResource` from the platform API.
/// Status spellings are not documented, so it accepts common variants.
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
  }) {
    final id = _int(json['id']);
    if (id == null) throw const FormatException('Delivery without id');
    return DeliveryShipment(
      id: '$id',
      trackingNumber: 'TRK-${id.toString().padLeft(4, '0')}',
      orderId: order.orderCode,
      itemsSummary: order.itemsSummary,
      status: parseStatus(json['currentStatus'] ?? json['status']),
      estimatedArrival: _date(json['estimatedTimeOfArrival']),
      driverName: _text(json['driverName']),
      driverPhone: _text(json['driverPhone']),
      vehiclePlate: _text(json['vehiclePlate']),
      vehicleType: _text(json['vehicleType']),
      routeOrigin: _text(json['routeOrigin']),
      routeDestination: _text(json['routeDestination']),
      routeDistanceKm: _double(json['routeDistanceKm']),
      telemetry: telemetry,
    );
  }

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
      latest = TelemetryLog(
        temperatureC: temperature,
        humidityPercent: humidity,
        recordedAt: at,
      );
    }
    return latest;
  }

  static ShipmentStatus parseStatus(Object? raw) {
    if (raw is num) {
      return switch (raw.toInt()) {
        1 => ShipmentStatus.dispatched,
        2 => ShipmentStatus.inTransit,
        3 => ShipmentStatus.delayed,
        4 => ShipmentStatus.arrived,
        5 => ShipmentStatus.delivered,
        _ => ShipmentStatus.scheduled,
      };
    }
    final value = (raw ?? '').toString().trim().toLowerCase().replaceAll(
      RegExp(r'[\s_-]+'),
      '',
    );
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
    if (dispatched.contains(value)) return ShipmentStatus.dispatched;
    if (inTransit.contains(value)) return ShipmentStatus.inTransit;
    if (delayed.contains(value)) return ShipmentStatus.delayed;
    if (arrived.contains(value)) return ShipmentStatus.arrived;
    if (delivered.contains(value)) return ShipmentStatus.delivered;
    return ShipmentStatus.scheduled;
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
