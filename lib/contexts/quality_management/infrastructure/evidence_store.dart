import 'dart:typed_data';

import '../domain/incident.dart';
import 'evidence_store_stub.dart'
    if (dart.library.io) 'evidence_store_io.dart' as platform;

/// Keeps incident photos on the device (the platform API only accepts
/// evidence URLs and has no upload endpoint yet).
abstract interface class EvidenceStore {
  Future<List<EvidencePhoto>> save(String incidentId, List<Uint8List> photos);
  Future<List<EvidencePhoto>> load(String incidentId);

  /// Files on Android/iOS/desktop (per signed-in user); memory on the web.
  factory EvidenceStore.device({required String scope}) =>
      platform.createDeviceEvidenceStore(scope);
}

/// Session-only store (demo mode, tests, web).
class MemoryEvidenceStore implements EvidenceStore {
  final Map<String, List<EvidencePhoto>> _photos = {};

  @override
  Future<List<EvidencePhoto>> save(String incidentId, List<Uint8List> photos) async {
    final saved = [
      for (var i = 0; i < photos.length; i++)
        EvidencePhoto(id: '$incidentId-$i', bytes: photos[i]),
    ];
    _photos[incidentId] = saved;
    return saved;
  }

  @override
  Future<List<EvidencePhoto>> load(String incidentId) async =>
      _photos[incidentId] ?? const [];
}
