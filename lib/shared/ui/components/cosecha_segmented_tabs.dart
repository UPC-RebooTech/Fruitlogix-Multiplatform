import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';

/// Cosecha segmented tabs: a pill track (`surfaceContainerHigh`, 48 high,
/// padding 4) with 40-high segments. Active segment: moss with white text;
/// inactive: transparent with `onSurfaceVariant` text.
class CosechaSegmentedTabs extends StatelessWidget {
  const CosechaSegmentedTabs({
    required this.labels,
    required this.selectedIndex,
    required this.onSelected,
    super.key,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    return Container(
      height: CosechaSize.chipHeight,
      padding: const EdgeInsets.all(CosechaSpace.xxs),
      decoration: ShapeDecoration(
        color: scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: Semantics(
                button: true,
                selected: i == selectedIndex,
                inMutuallyExclusiveGroup: true,
                label: labels[i],
                excludeSemantics: true,
                child: Material(
                  color: i == selectedIndex
                      ? scheme.primary
                      : Colors.transparent,
                  shape: const StadiumBorder(),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => onSelected(i),
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: CosechaSpace.xs,
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            labels[i],
                            maxLines: 1,
                            style: textTheme.labelLarge?.copyWith(
                              color: i == selectedIndex
                                  ? scheme.onPrimary
                                  : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
