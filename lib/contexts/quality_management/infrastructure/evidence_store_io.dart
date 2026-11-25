import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../domain/incident.dart';
import 'evidence_store.dart';

EvidenceStore createDeviceEvidenceStore(String scope) =>
    FileEvidenceStore(scope: scope);

/// Saves photos in the app documents folder:
/// `incident_evidence/<scope>/<incidentId>/<n>.jpg`.
class FileEvidenceStore implements EvidenceStore {
  FileEvidenceStore({required this.scope, Future<Directory> Function()? root})
      : _root = root ?? getApplicationDocumentsDirectory;

  /// Separates users on a shared device (the IAM user id).
  final String scope;
  final Future<Directory> Function() _root;

  Future<Directory> _folder(String incidentId) async {
    final base = await _root();
    final safeId = incidentId.replaceAll(RegExp(r'[^A-Za-z0-9_-]'), '_');
    return Directory('${base.path}/incident_evidence/$scope/$safeId');
  }

  @override
  Future<List<EvidencePhoto>> save(String incidentId, List<Uint8List> photos) async {
    final folder = await _folder(incidentId);
    await folder.create(recursive: true);
    final saved = <EvidencePhoto>[];
    for (var i = 0; i < photos.length; i++) {
      await File('${folder.path}/$i.jpg').writeAsBytes(photos[i], flush: true);
      saved.add(EvidencePhoto(id: '$incidentId-$i', bytes: photos[i]));
    }
    return saved;
  }

  @override
  Future<List<EvidencePhoto>> load(String incidentId) async {
    final folder = await _folder(incidentId);
    if (!await folder.exists()) return const [];
    final files = await folder
        .list()
        .where((entity) => entity is File && entity.path.endsWith('.jpg'))
        .cast<File>()
        .toList();
    files.sort((a, b) => a.path.compareTo(b.path));
    return [
      for (var i = 0; i < files.length; i++)
        EvidencePhoto(id: '$incidentId-$i', bytes: await files[i].readAsBytes()),
    ];
  }
}
