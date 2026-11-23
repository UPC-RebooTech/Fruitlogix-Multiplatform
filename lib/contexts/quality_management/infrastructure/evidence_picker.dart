import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';

enum EvidenceSource { camera, gallery }

/// Takes or chooses incident photos (US11: direct capture with the camera).
abstract interface class EvidencePicker {
  /// False on platforms without a camera picker (web, desktop).
  bool get supportsCamera;

  /// Up to [max] photos; empty when the user cancels.
  Future<List<Uint8List>> pick(EvidenceSource source, {required int max});
}

class ImagePickerEvidencePicker implements EvidencePicker {
  ImagePickerEvidencePicker([ImagePicker? picker])
      : _picker = picker ?? ImagePicker();

  final ImagePicker _picker;

  /// Enough to see bruises and labels while keeping files small.
  static const double _maxSide = 1600;
  static const int _quality = 75;

  @override
  bool get supportsCamera {
    try {
      return _picker.supportsImageSource(ImageSource.camera);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<List<Uint8List>> pick(EvidenceSource source, {required int max}) async {
    if (max <= 0) return const [];
    final List<XFile> files;
    if (source == EvidenceSource.camera || max == 1) {
      final file = await _picker.pickImage(
        source: source == EvidenceSource.camera
            ? ImageSource.camera
            : ImageSource.gallery,
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
      );
      files = file == null ? const [] : [file];
    } else {
      files = await _picker.pickMultiImage(
        maxWidth: _maxSide,
        maxHeight: _maxSide,
        imageQuality: _quality,
        limit: max,
      );
    }
    return [for (final file in files.take(max)) await file.readAsBytes()];
  }
}
