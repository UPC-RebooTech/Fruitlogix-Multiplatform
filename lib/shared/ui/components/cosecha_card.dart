import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Card tones of Cosecha.
enum CosechaCardTone {
  /// White card with a thin green border. The default for lists, details
  /// and grouped forms.
  white,

  /// Light card (`surfaceContainerLow`), no border.
  light,

  /// Mint tint (`secondaryContainer`).
  tint,

  /// Dark forest card. Only for KPIs and highlighted blocks (next action,
  /// account card, temperature alert).
  dark,
}

/// Flat card (no shadow): hierarchy comes from surface tone.
class CosechaCard extends StatelessWidget {
  const CosechaCard({
    required this.child,
    this.tone = CosechaCardTone.white,
    this.hero = false,
    this.radius,
    this.padding = const EdgeInsets.all(CosechaSpace.sm),
    this.onTap,
    this.semanticLabel,
    super.key,
  });

  final Widget child;
  final CosechaCardTone tone;

  /// Hero (highlighted) card: radius 24 instead of 18.
  final bool hero;

  /// Overrides the radius (e.g. 12 for action rows).
  final double? radius;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final status = CosechaStatusColors.of(context);
    final dark = tone == CosechaCardTone.dark;

    final background = switch (tone) {
      CosechaCardTone.white => scheme.surfaceContainerLowest,
      CosechaCardTone.light => scheme.surfaceContainerLow,
      CosechaCardTone.tint => scheme.secondaryContainer,
      CosechaCardTone.dark => scheme.inverseSurface,
    };
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(
        radius ?? (hero ? CosechaRadius.hero : CosechaRadius.card),
      ),
      side: tone == CosechaCardTone.white
          ? BorderSide(color: scheme.outlineVariant)
          : BorderSide.none,
    );
    final contentColor = dark ? scheme.onInverseSurface : scheme.onSurface;

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = Semantics(
        button: true,
        label: semanticLabel,
        child: InkWell(onTap: onTap, customBorder: shape, child: content),
      );
    }

    return CosechaSurface(
      onDark: dark,
      child: Material(
        color: background,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        textStyle: textTheme.bodyMedium?.copyWith(color: contentColor),
        child: IconTheme.merge(
          data: IconThemeData(
            color: dark ? status.onDarkPrimary : scheme.onSurface,
          ),
          child: content,
        ),
      ),
    );
  }
}
