import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';

/// Filter chip: pill, 48 high. Selected: forest with white text.
/// Unselected: `surfaceContainerHigh` with `onSurface` text.
class CosechaFilterChip extends StatelessWidget {
  const CosechaFilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
    super.key,
  });

  final String label;
  final bool selected;
  final ValueChanged<bool>? onSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final foreground = selected ? scheme.onSecondary : scheme.onSurface;
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? scheme.secondary : scheme.surfaceContainerHigh,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onSelected == null ? null : () => onSelected!(!selected),
          child: Container(
            height: CosechaSize.chipHeight,
            constraints: const BoxConstraints(minWidth: CosechaSize.minTouch),
            padding: const EdgeInsets.symmetric(horizontal: CosechaSpace.sm),
            alignment: Alignment.center,
            child: Text(
              label,
              maxLines: 1,
              style: Theme.of(context)
                  .textTheme
                  .labelMedium
                  ?.copyWith(color: foreground),
            ),
          ),
        ),
      ),
    );
  }
}
