import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// What the app remembers about an incident it reported.
class IncidentLocalMeta {
  const IncidentLocalMeta({required this.orderCode});

  final String? orderCode;

  Map<String, Object?> toJson() => {'orderCode': orderCode};

  static IncidentLocalMeta fromJson(Object? json) => IncidentLocalMeta(
        orderCode: json is Map ? json['orderCode'] as String? : null,
      );
}

/// Ids of the incidents reported by the signed-in client on this device.
///
/// `GET /api/v1/incidents` is not filtered by client, so the app only shows
/// incidents it knows the user reported (never other clients' incidents).
abstract interface class IncidentIndex {
  Future<Map<String, IncidentLocalMeta>> load();
  Future<void> remember(String incidentId, IncidentLocalMeta meta);
}

class InMemoryIncidentIndex implements IncidentIndex {
  final Map<String, IncidentLocalMeta> _entries = {};

  @override
  Future<Map<String, IncidentLocalMeta>> load() async => Map.of(_entries);

  @override
  Future<void> remember(String incidentId, IncidentLocalMeta meta) async {
    _entries[incidentId] = meta;
  }
}

class SharedPreferencesIncidentIndex implements IncidentIndex {
  SharedPreferencesIncidentIndex({
    required int userId,
    SharedPreferencesAsync? preferences,
  })  : _key = 'quality_incidents_$userId',
        _preferences = preferences ?? SharedPreferencesAsync();

  final String _key;
  final SharedPreferencesAsync _preferences;

  @override
  Future<Map<String, IncidentLocalMeta>> load() async {
    final raw = await _preferences.getString(_key);
    if (raw == null || raw.isEmpty) return {};
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return {};
      return {
        for (final entry in decoded.entries)
          '${entry.key}': IncidentLocalMeta.fromJson(entry.value),
      };
    } on FormatException {
      return {};
    }
  }

  @override
  Future<void> remember(String incidentId, IncidentLocalMeta meta) async {
    final entries = await load();
    entries[incidentId] = meta;
    await _preferences.setString(
      _key,
      jsonEncode({for (final e in entries.entries) e.key: e.value.toJson()}),
    );
  }
}
