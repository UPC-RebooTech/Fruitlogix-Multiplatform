import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_card.dart';
import 'cosecha_icon_box.dart';
import 'cosecha_surface.dart';

/// Action row: white card (radius 12) with a mint icon box, a title
/// (titleSmall), an optional detail (bodySmall) and a chevron. 64 high.
class CosechaActionRow extends StatelessWidget {
  const CosechaActionRow({
    required this.icon,
    required this.title,
    required this.onTap,
    this.detail,
    this.trailing,
    super.key,
  });

  final IconData icon;
  final String title;
  final String? detail;
  final VoidCallback? onTap;

  /// Replaces the chevron (e.g. a status tag).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return CosechaCard(
      radius: CosechaRadius.button,
      padding: const EdgeInsets.all(CosechaSpace.inner),
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: CosechaSize.fieldTouch - 2 * CosechaSpace.inner,
        ),
        child: Row(
          children: [
            CosechaIconBox(icon: icon),
            const SizedBox(width: CosechaSpace.inner),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    style: textTheme.titleSmall
                        ?.copyWith(color: context.cosechaContent),
                  ),
                  if (detail != null)
                    Text(
                      detail!,
                      style: textTheme.bodySmall
                          ?.copyWith(color: context.cosechaContentSecondary),
                    ),
                ],
              ),
            ),
            const SizedBox(width: CosechaSpace.xs),
            trailing ??
                Icon(
                  Icons.chevron_right,
                  color: context.cosechaContentSecondary,
                ),
          ],
        ),
      ),
    );
  }
}
