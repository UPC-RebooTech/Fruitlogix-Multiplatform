import 'package:geolocator/geolocator.dart';

import '../domain/geofence.dart';

enum LocationFailure { serviceDisabled, denied, deniedForever, unavailable }

class LocationException implements Exception {
  const LocationException(this.reason);
  final LocationFailure reason;

  @override
  String toString() => 'LocationException($reason)';
}

/// Current position of the phone, to set the warehouse zone (US65).
abstract interface class WarehouseLocator {
  /// Throws [LocationException].
  Future<GeoPoint> currentPosition();
}

class GeolocatorWarehouseLocator implements WarehouseLocator {
  const GeolocatorWarehouseLocator();

  @override
  Future<GeoPoint> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw const LocationException(LocationFailure.serviceDisabled);
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied) {
        throw const LocationException(LocationFailure.denied);
      }
      if (permission == LocationPermission.deniedForever) {
        throw const LocationException(LocationFailure.deniedForever);
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 20),
        ),
      );
      return GeoPoint(position.latitude, position.longitude);
    } on LocationException {
      rethrow;
    } catch (_) {
      throw const LocationException(LocationFailure.unavailable);
    }
  }
}

/// Fixed position (demo, tests).
class FixedWarehouseLocator implements WarehouseLocator {
  const FixedWarehouseLocator(this.position);
  final GeoPoint position;

  @override
  Future<GeoPoint> currentPosition() async => position;
}
