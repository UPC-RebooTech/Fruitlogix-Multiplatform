import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Optional 1–5 star rating (US35).
///
/// Each star is a 48 touch target. Tapping the selected star again clears
/// the rating. Stars use moss (lime is never used as a mark on light
/// surfaces) and the chosen level is also written as text, so the value
/// never relies on color alone.
class CosechaStarRating extends StatelessWidget {
  const CosechaStarRating({
    required this.value,
    required this.onChanged,
    required this.levelLabels,
    required this.starLabel,
    required this.emptyLabel,
    this.max = 5,
    super.key,
  }) : assert(levelLabels.length == max);

  /// 1..[max], or null when not rated.
  final int? value;
  final ValueChanged<int?>? onChanged;

  /// Text for each level ("Very bad" … "Excellent").
  final List<String> levelLabels;

  /// Screen reader label of a star: `(n, max) => "4 of 5 stars"`.
  final String Function(int stars, int max) starLabel;

  /// Shown when nothing is selected ("Not rated").
  final String emptyLabel;
  final int max;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final current = value ?? 0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            for (var star = 1; star <= max; star++)
              Semantics(
                button: true,
                selected: star <= current,
                label: starLabel(star, max),
                excludeSemantics: true,
                child: IconButton(
                  onPressed: onChanged == null
                      ? null
                      : () => onChanged!(star == value ? null : star),
                  iconSize: 32,
                  constraints: const BoxConstraints(
                    minWidth: CosechaSize.minTouch,
                    minHeight: CosechaSize.minTouch,
                  ),
                  icon: Icon(
                    star <= current
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    color: star <= current ? scheme.primary : scheme.outline,
                  ),
                ),
              ),
          ],
        ),
        Padding(
          padding: const EdgeInsetsDirectional.only(start: CosechaSpace.inner),
          child: Text(
            current == 0 ? emptyLabel : levelLabels[current - 1],
            style: Theme.of(context).textTheme.labelLarge?.copyWith(
              color: current == 0
                  ? context.cosechaContentSecondary
                  : context.cosechaContent,
            ),
          ),
        ),
      ],
    );
  }
}
