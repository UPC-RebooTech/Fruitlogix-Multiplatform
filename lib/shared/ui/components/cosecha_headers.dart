import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// UPPERCASE overline (labelSmall, 12 sp). The only place where 12 sp and
/// uppercase are allowed. Used as section headers and KPI labels.
class CosechaOverline extends StatelessWidget {
  const CosechaOverline(this.text, {this.color, super.key});

  final String text;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      header: true,
      child: Text(
        text.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: color ?? context.cosechaContentSecondary,
            ),
      ),
    );
  }
}

/// Screen header: optional overline, title (headlineMedium) and subtitle.
class CosechaPageHeader extends StatelessWidget {
  const CosechaPageHeader({
    required this.title,
    this.overline,
    this.subtitle,
    this.trailing,
    super.key,
  });

  final String title;
  final String? overline;
  final String? subtitle;

  /// Optional widget aligned to the end of the title (e.g. a button).
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final heading = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (overline != null) ...[
          CosechaOverline(overline!),
          const SizedBox(height: CosechaSpace.xs),
        ],
        Semantics(
          header: true,
          child: Text(
            title,
            style: textTheme.headlineMedium
                ?.copyWith(color: context.cosechaContent),
          ),
        ),
        if (subtitle != null) ...[
          const SizedBox(height: CosechaSpace.xxs),
          Text(
            subtitle!,
            style: textTheme.bodyMedium
                ?.copyWith(color: context.cosechaContentSecondary),
          ),
        ],
      ],
    );
    if (trailing == null) return heading;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(child: heading),
        const SizedBox(width: CosechaSpace.sm),
        trailing!,
      ],
    );
  }
}
