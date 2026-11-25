import 'evidence_store.dart';

/// Web: no file system, photos live for the session.
EvidenceStore createDeviceEvidenceStore(String scope) => MemoryEvidenceStore();
