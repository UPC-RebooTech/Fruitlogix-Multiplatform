import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';

/// One option of [showCosechaSpeedDial].
@immutable
class CosechaSpeedDialItem<T> {
  const CosechaSpeedDialItem({
    required this.value,
    required this.icon,
    required this.label,
  });

  final T value;
  final IconData icon;
  final String label;
}

/// Opens the "More" speed dial anchored to the button at [anchor] (global
/// coordinates). Returns the chosen value, or null when dismissed.
///
/// - Opaque deep forest veil so the content behind does not distract.
/// - Each option is a single touch target (label + icon), 56 high.
/// - Closes when tapping outside, with the system back button or the X,
///   which sits exactly over the original button.
/// - Staggered entrance, nearest option first. With "reduce motion" the
///   options only fade.
Future<T?> showCosechaSpeedDial<T>({
  required BuildContext context,
  required Rect anchor,
  required List<CosechaSpeedDialItem<T>> items,
  required String closeLabel,
}) {
  final scheme = Theme.of(context).colorScheme;
  return showGeneralDialog<T>(
    context: context,
    barrierDismissible: true,
    barrierLabel: closeLabel,
    barrierColor: scheme.onSurface.withValues(alpha: 0.86),
    transitionDuration: const Duration(milliseconds: 320),
    pageBuilder: (dialogContext, animation, _) => _SpeedDial<T>(
      anchor: anchor,
      items: items,
      closeLabel: closeLabel,
      animation: animation,
    ),
    // The page animates itself (staggered); no global transition.
    transitionBuilder: (_, _, _, child) => child,
  );
}

class _SpeedDial<T> extends StatelessWidget {
  const _SpeedDial({
    required this.anchor,
    required this.items,
    required this.closeLabel,
    required this.animation,
  });

  final Rect anchor;
  final List<CosechaSpeedDialItem<T>> items;
  final String closeLabel;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final count = items.length;

    final options = <Widget>[];
    for (var i = 0; i < count; i++) {
      // Distance from the button: the last item is the nearest one and
      // enters first.
      final order = count - 1 - i;
      final start = (order * 0.12).clamp(0.0, 0.6);
      final curved = CurvedAnimation(
        parent: animation,
        curve: Interval(start, (start + 0.55).clamp(0.0, 1.0),
            curve: Curves.easeOutCubic),
        reverseCurve: Curves.easeIn,
      );
      Widget option = _SpeedDialOption<T>(item: items[i]);
      if (!reduceMotion) {
        option = SlideTransition(
          position: Tween(begin: const Offset(0, 0.35), end: Offset.zero)
              .animate(curved),
          child: ScaleTransition(
            scale: Tween(begin: 0.92, end: 1.0).animate(curved),
            alignment: Alignment.centerRight,
            child: option,
          ),
        );
      }
      options.add(FadeTransition(opacity: curved, child: option));
      if (i < count - 1) {
        options.add(const SizedBox(height: CosechaSpace.inner));
      }
    }

    return Stack(
      children: [
        Positioned(
          right: size.width - anchor.right,
          bottom: size.height - anchor.top + CosechaSpace.sm,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: options,
          ),
        ),
        Positioned.fromRect(
          rect: anchor,
          child: _CloseButton(label: closeLabel, animation: animation),
        ),
      ],
    );
  }
}

class _SpeedDialOption<T> extends StatelessWidget {
  const _SpeedDialOption({required this.item});

  final CosechaSpeedDialItem<T> item;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      label: item.label,
      excludeSemantics: true,
      child: Material(
        color: scheme.surfaceContainerLowest,
        shape: const StadiumBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.of(context).pop(item.value),
          child: SizedBox(
            height: CosechaSize.fieldTouch,
            child: Padding(
              padding: const EdgeInsetsDirectional.only(
                start: CosechaSpace.md - CosechaSpace.xxs,
                end: CosechaSpace.xxs + 2,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.label,
                    style: Theme.of(context)
                        .textTheme
                        .titleSmall
                        ?.copyWith(color: scheme.onSurface),
                  ),
                  const SizedBox(width: CosechaSpace.inner),
                  Container(
                    width: 44,
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: scheme.secondaryContainer,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      item.icon,
                      size: CosechaSize.icon,
                      color: scheme.onSecondaryContainer,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Lime circle with an X, drawn over the "More" button that opened the dial.
class _CloseButton extends StatelessWidget {
  const _CloseButton({required this.label, required this.animation});

  final String label;
  final Animation<double> animation;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Tooltip(
        message: label,
        child: Semantics(
          button: true,
          label: label,
          excludeSemantics: true,
          child: Material(
            color: scheme.primaryContainer,
            shape: const CircleBorder(),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: () => Navigator.of(context).pop(),
              child: SizedBox.square(
                dimension: CosechaSize.navMoreButton,
                child: RotationTransition(
                  turns: Tween(begin: -0.25, end: 0.0).animate(
                    CurvedAnimation(parent: animation, curve: Curves.easeOut),
                  ),
                  child: Icon(
                    Icons.close,
                    size: CosechaSize.icon,
                    color: scheme.onPrimaryContainer,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
