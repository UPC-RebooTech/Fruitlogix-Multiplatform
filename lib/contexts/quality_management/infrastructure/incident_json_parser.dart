import '../domain/incident.dart';

/// Tolerant parser of the incidents returned by the platform API.
///
/// The Swagger contract does not document the response shape, so it accepts
/// common field names and status spellings (English/Spanish, any case).
abstract final class IncidentJsonParser {
  /// A JSON list, or an object wrapping it in `data`/`items`/`incidents`.
  static List<Incident> parseList(Object? body) {
    final list = switch (body) {
      List() => body,
      Map() => body['data'] ?? body['items'] ?? body['incidents'],
      null => const [],
      _ => null,
    };
    if (list is! List) throw const FormatException('Incidents: not a list');
    return [
      for (final item in list)
        if (item is Map) ?_tryParse(item),
    ];
  }

  static Incident? _tryParse(Map<dynamic, dynamic> json) {
    try {
      return parse(json);
    } on FormatException {
      return null;
    }
  }

  static Incident parse(Map<dynamic, dynamic> json) {
    final id = json['id'] ?? json['incidentId'];
    final batchId = _int(json['batchId'] ?? json['harvestBatchId']);
    if (id == null || batchId == null) {
      throw const FormatException('Incident without id or batchId');
    }
    return Incident(
      id: '$id',
      batchId: batchId,
      description: (json['description'] ?? '').toString().trim(),
      status: parseStatus(json['status'] ?? json['currentStatus']),
      reportedAt: _date(
            json['reportedAt'] ?? json['createdAt'] ?? json['reportDate'] ?? json['date'],
          ) ??
          DateTime.now(),
    );
  }

  /// Id of the incident returned by `POST /api/v1/incidents`, if any.
  static String? createdId(Object? body) {
    if (body is Map) {
      final id = body['id'] ?? body['incidentId'];
      return id?.toString();
    }
    if (body is num) return body.toString();
    return null;
  }

  static IncidentStatus parseStatus(Object? raw) {
    if (raw is num) {
      return switch (raw.toInt()) {
        1 => IncidentStatus.inReview,
        2 => IncidentStatus.resolved,
        3 => IncidentStatus.rejected,
        _ => IncidentStatus.open,
      };
    }
    final value = (raw ?? '').toString().trim().toLowerCase().replaceAll(RegExp(r'[\s_-]+'), '');
    if (value.isEmpty) return IncidentStatus.open;
    const inReview = ['inreview', 'reviewing', 'underreview', 'inprogress', 'investigating', 'enrevision', 'enrevisión', 'enproceso'];
    const resolved = ['resolved', 'closed', 'solved', 'resuelta', 'resuelto', 'cerrada', 'cerrado'];
    const rejected = ['rejected', 'dismissed', 'declined', 'rechazada', 'rechazado', 'descartada'];
    if (inReview.contains(value)) return IncidentStatus.inReview;
    if (resolved.contains(value)) return IncidentStatus.resolved;
    if (rejected.contains(value)) return IncidentStatus.rejected;
    return IncidentStatus.open;
  }

  static int? _int(Object? raw) => switch (raw) {
        int() => raw,
        num() => raw.toInt(),
        String() => int.tryParse(raw.trim()),
        _ => null,
      };

  static DateTime? _date(Object? raw) =>
      raw is String ? DateTime.tryParse(raw)?.toLocal() : null;
}
