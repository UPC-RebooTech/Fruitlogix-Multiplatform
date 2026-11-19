import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Status tag: radius 8, padding 10×4, a 6 dot (or an icon) plus a
/// sentence-case label ("Due today", not "DUE TODAY").
///
/// States never rely on color alone: container + dot/icon + text.
class CosechaStatusTag extends StatelessWidget {
  const CosechaStatusTag({
    required this.label,
    required this.status,
    this.icon,
    super.key,
  });

  final String label;
  final CosechaStatus status;

  /// Optional icon instead of the dot.
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final tone = CosechaStatusColors.of(context).tone(status);
    final dark = context.cosechaOnDark;
    final background = dark
        ? tone.onDark.withValues(alpha: CosechaStatusColors.onDarkContainerAlpha)
        : tone.container;
    final foreground = dark ? tone.onDark : tone.onContainer;
    final accent = dark ? tone.onDark : tone.color;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: CosechaRadius.tagAll,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null)
            Icon(icon, size: 16, color: accent)
          else
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
            ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: foreground),
            ),
          ),
        ],
      ),
    );
  }
}
