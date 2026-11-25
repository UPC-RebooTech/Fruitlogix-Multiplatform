import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';

/// Square photo thumbnail (radius 12). Tapping opens it full screen.
class EvidenceThumbnail extends StatelessWidget {
  const EvidenceThumbnail({
    required this.bytes,
    required this.label,
    this.size = 96,
    super.key,
  });

  final Uint8List bytes;
  final String label;
  final double size;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      image: true,
      label: label,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerHigh,
        shape: RoundedRectangleBorder(
          borderRadius: CosechaRadius.buttonAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => showEvidenceViewer(context, bytes: bytes, label: label),
          child: Image.memory(
            bytes,
            width: size,
            height: size,
            fit: BoxFit.cover,
            gaplessPlayback: true,
            cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).round(),
            errorBuilder: (_, _, _) => SizedBox.square(
              dimension: size,
              child: Icon(Icons.broken_image_outlined, color: scheme.onSurfaceVariant),
            ),
          ),
        ),
      ),
    );
  }
}

/// Read-only grid of evidence photos.
class EvidenceGallery extends StatelessWidget {
  const EvidenceGallery({required this.photos, super.key});

  final List<Uint8List> photos;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Wrap(
      spacing: CosechaSpace.xs,
      runSpacing: CosechaSpace.xs,
      children: [
        for (var i = 0; i < photos.length; i++)
          EvidenceThumbnail(bytes: photos[i], label: l10n.qmPhotoLabel(i + 1)),
      ],
    );
  }
}

/// Full-screen photo with pinch to zoom, on a dark veil.
Future<void> showEvidenceViewer(
  BuildContext context, {
  required Uint8List bytes,
  required String label,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).closeButtonTooltip,
    barrierColor: scheme.onSurface.withValues(alpha: 0.94),
    pageBuilder: (dialogContext, _, _) => SafeArea(
      child: Stack(
        children: [
          Positioned.fill(
            child: InteractiveViewer(
              minScale: 1,
              maxScale: 5,
              child: Center(
                child: Semantics(
                  image: true,
                  label: label,
                  child: Image.memory(bytes, fit: BoxFit.contain),
                ),
              ),
            ),
          ),
          Positioned(
            top: CosechaSpace.xs,
            right: CosechaSpace.xs,
            child: IconButton.filled(
              tooltip: MaterialLocalizations.of(dialogContext).closeButtonTooltip,
              style: IconButton.styleFrom(
                backgroundColor: scheme.primaryContainer,
                foregroundColor: scheme.onPrimaryContainer,
              ),
              onPressed: () => Navigator.of(dialogContext).pop(),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
    ),
  );
}
