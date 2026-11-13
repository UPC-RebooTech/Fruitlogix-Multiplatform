import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Rounded square (radius 12) holding an icon, used in rows and cards.
///
/// On light surfaces: mint box with a deep forest icon. On dark surfaces:
/// lime at 14 % opacity with a lime icon (KPI cards).
class CosechaIconBox extends StatelessWidget {
  const CosechaIconBox({
    required this.icon,
    this.size = CosechaSize.iconBox,
    this.iconSize = CosechaSize.icon,
    this.background,
    this.foreground,
    super.key,
  });

  final IconData icon;
  final double size;
  final double iconSize;
  final Color? background;
  final Color? foreground;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dark = context.cosechaOnDark;
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background ??
            (dark
                ? scheme.primaryContainer.withValues(alpha: 0.14)
                : scheme.secondaryContainer),
        borderRadius: CosechaRadius.buttonAll,
      ),
      child: Icon(
        icon,
        size: iconSize,
        color: foreground ??
            (dark ? scheme.primaryContainer : scheme.onSecondaryContainer),
      ),
    );
  }
}
