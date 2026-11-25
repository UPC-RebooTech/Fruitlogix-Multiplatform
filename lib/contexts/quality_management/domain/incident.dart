import 'dart:typed_data';

/// Lifecycle of a quality incident reported by the Commercial Client.
enum IncidentStatus {
  /// Just reported, waiting for the distributor.
  open,

  /// The distributor is reviewing it.
  inReview,

  /// Solved (replacement, credit note…).
  resolved,

  /// Not accepted by the distributor.
  rejected;

  bool get isClosed => this == resolved || this == rejected;
}

/// A photo attached as evidence (US11). The platform keeps its URL; this
/// phone also keeps the bytes of the photos it took.
class EvidencePhoto {
  const EvidencePhoto({required this.id, required this.bytes});

  final String id;
  final Uint8List bytes;
}

/// What an incident is about: one order and the harvest lot it came from.
///
/// The platform links incidents to a lot (`batchId`, linked to the order by
/// the producer) and, optionally, to the order (`orderId`).
class IncidentTarget {
  const IncidentTarget({
    required this.orderCode,
    required this.batchId,
    this.orderId,
    this.productSummary,
  });

  final String orderCode;
  final int batchId;

  /// Platform order id; null for demo orders.
  final int? orderId;

  /// Short description of the goods (e.g. "Mango Kent · 2 kg").
  final String? productSummary;

  String get lotCode => 'LOT-$batchId';

  @override
  bool operator ==(Object other) =>
      other is IncidentTarget &&
      other.orderCode == orderCode &&
      other.batchId == batchId;

  @override
  int get hashCode => Object.hash(orderCode, batchId);
}

/// Quality incident (EP02 · US11).
class Incident {
  const Incident({
    required this.id,
    required this.batchId,
    required this.description,
    required this.reportedAt,
    required this.status,
    this.orderCode,
    this.evidence = const [],
    this.evidenceUrls = const [],
  });

  final String id;
  final int batchId;
  final String description;
  final DateTime reportedAt;
  final IncidentStatus status;

  /// Known only for incidents reported from this app (the API stores lots).
  final String? orderCode;
  final List<EvidencePhoto> evidence;

  /// Photos stored by the platform (`evidenceUrls`).
  final List<String> evidenceUrls;

  /// Display code: `INC-0007`.
  String get code {
    final numeric = int.tryParse(id);
    return numeric == null ? id : 'INC-${numeric.toString().padLeft(4, '0')}';
  }

  String get lotCode => 'LOT-$batchId';

  Incident copyWith({
    IncidentStatus? status,
    String? orderCode,
    List<EvidencePhoto>? evidence,
  }) =>
      Incident(
        id: id,
        batchId: batchId,
        description: description,
        reportedAt: reportedAt,
        status: status ?? this.status,
        orderCode: orderCode ?? this.orderCode,
        evidence: evidence ?? this.evidence,
        evidenceUrls: evidenceUrls,
      );
}

/// Why a [NewIncident] cannot be sent.
enum IncidentDraftError { missingTarget, descriptionTooShort, tooManyPhotos }

/// An incident the client is about to report.
class NewIncident {
  const NewIncident({
    required this.target,
    required this.description,
    this.photos = const [],
  });

  static const int minDescriptionLength = 10;
  /// The platform accepts up to 5 images of 5 MB per incident.
  static const int maxPhotos = 4;

  final IncidentTarget? target;
  final String description;
  final List<Uint8List> photos;

  static IncidentDraftError? validateDescription(String? value) =>
      (value ?? '').trim().length < minDescriptionLength
          ? IncidentDraftError.descriptionTooShort
          : null;

  /// First problem found, or null when the incident can be sent.
  IncidentDraftError? validate() {
    if (target == null) return IncidentDraftError.missingTarget;
    final description = validateDescription(this.description);
    if (description != null) return description;
    if (photos.length > maxPhotos) return IncidentDraftError.tooManyPhotos;
    return null;
  }
}
