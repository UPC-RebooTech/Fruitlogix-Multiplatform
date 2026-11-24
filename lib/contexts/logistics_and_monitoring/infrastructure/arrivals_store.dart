import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../domain/geofence.dart';

/// Warehouse zone and arrivals list, kept on the device (the platform API
/// has no geofence yet).
abstract interface class ArrivalsStore {
  Future<WarehouseZone?> loadZone();
  Future<void> saveZone(WarehouseZone? zone);
  Future<List<ArrivalRecord>> loadArrivals();
  Future<void> saveArrivals(List<ArrivalRecord> arrivals);
}

class InMemoryArrivalsStore implements ArrivalsStore {
  InMemoryArrivalsStore({WarehouseZone? zone}) : _zone = zone;

  WarehouseZone? _zone;
  List<ArrivalRecord> _arrivals = const [];

  @override
  Future<WarehouseZone?> loadZone() async => _zone;

  @override
  Future<void> saveZone(WarehouseZone? zone) async => _zone = zone;

  @override
  Future<List<ArrivalRecord>> loadArrivals() async => _arrivals;

  @override
  Future<void> saveArrivals(List<ArrivalRecord> arrivals) async =>
      _arrivals = List.unmodifiable(arrivals);
}

/// Per signed-in user, so a shared phone does not mix warehouses.
class SharedPreferencesArrivalsStore implements ArrivalsStore {
  SharedPreferencesArrivalsStore({
    required int userId,
    SharedPreferencesAsync? preferences,
  })  : _zoneKey = 'warehouse_zone_$userId',
        _arrivalsKey = 'warehouse_arrivals_$userId',
        _preferences = preferences ?? SharedPreferencesAsync();

  final String _zoneKey;
  final String _arrivalsKey;
  final SharedPreferencesAsync _preferences;

  /// Keeps the list short: the latest arrivals are the useful ones.
  static const int maxArrivals = 50;

  @override
  Future<WarehouseZone?> loadZone() async =>
      WarehouseZone.fromJson(_decode(await _preferences.getString(_zoneKey)));

  @override
  Future<void> saveZone(WarehouseZone? zone) async {
    if (zone == null) {
      await _preferences.remove(_zoneKey);
    } else {
      await _preferences.setString(_zoneKey, jsonEncode(zone.toJson()));
    }
  }

  @override
  Future<List<ArrivalRecord>> loadArrivals() async {
    final decoded = _decode(await _preferences.getString(_arrivalsKey));
    if (decoded is! List) return const [];
    return [for (final item in decoded) ?ArrivalRecord.fromJson(item)];
  }

  @override
  Future<void> saveArrivals(List<ArrivalRecord> arrivals) => _preferences.setString(
        _arrivalsKey,
        jsonEncode([for (final a in arrivals.take(maxArrivals)) a.toJson()]),
      );

  static Object? _decode(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }
}
