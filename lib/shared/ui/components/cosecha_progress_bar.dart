import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Progress bar: 8 high, capsule. On light: moss over
/// `surfaceContainerHigh`. On dark: lime over white at 14 %.
class CosechaProgressBar extends StatelessWidget {
  const CosechaProgressBar({required this.value, this.semanticLabel, super.key});

  /// 0.0 to 1.0, or null for indeterminate.
  final double? value;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = context.cosechaOnDark;
    return LinearProgressIndicator(
      value: value,
      minHeight: CosechaSize.progressBar,
      semanticsLabel: semanticLabel,
      borderRadius: const BorderRadius.all(
        Radius.circular(CosechaSize.progressBar / 2),
      ),
      color: dark ? scheme.primaryContainer : scheme.primary,
      backgroundColor: dark
          ? Colors.white.withValues(alpha: 0.14)
          : scheme.surfaceContainerHigh,
    );
  }
}
