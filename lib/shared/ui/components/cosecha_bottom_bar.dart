import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_theme.dart';
import '../theme/cosecha_tokens.dart';

/// One destination of [CosechaBottomBar].
@immutable
class CosechaNavItem {
  const CosechaNavItem({
    required this.icon,
    required this.label,
    IconData? selectedIcon,
  }) : selectedIcon = selectedIcon ?? icon;

  final IconData icon;
  final IconData selectedIcon;
  final String label;
}

/// Bottom bar: deep forest, 72 high, 4 tabs plus a "More" button (52 lime
/// circle). Active tab: lime pill behind the icon and a white label.
/// Inactive: secondary on-dark color. Labels are 12 sp.
///
/// While a section opened from "More" is shown, no tab is selected
/// ([selectedIndex] is null) and [moreSelected] draws a white ring around
/// the "More" button.
class CosechaBottomBar extends StatelessWidget {
  const CosechaBottomBar({
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    required this.onMore,
    required this.moreLabel,
    this.moreSelected = false,
    super.key,
  }) : assert(items.length == 4, 'Cosecha bottom bar has 4 tabs + More');

  final List<CosechaNavItem> items;
  final int? selectedIndex;
  final ValueChanged<int> onSelected;

  /// Called with the global rect of the "More" button, to anchor the
  /// speed dial.
  final ValueChanged<Rect> onMore;
  final String moreLabel;
  final bool moreSelected;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final background =
        NavigationBarTheme.of(context).backgroundColor ?? scheme.onSurface;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: CosechaTheme.systemBars,
      child: Material(
        color: background,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: CosechaSize.navBarHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: CosechaSpace.xxs),
              child: Row(
                children: [
                  for (var i = 0; i < items.length; i++)
                    Expanded(
                      child: _NavTab(
                        item: items[i],
                        selected: i == selectedIndex,
                        onTap: () => onSelected(i),
                      ),
                    ),
                  _MoreButton(
                    label: moreLabel,
                    selected: moreSelected,
                    onTap: onMore,
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

class _NavTab extends StatelessWidget {
  const _NavTab({
    required this.item,
    required this.selected,
    required this.onTap,
  });

  final CosechaNavItem item;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = CosechaStatusColors.of(context);
    final labelStyle = Theme.of(context).textTheme.labelSmall?.copyWith(
          letterSpacing: 0,
          color: selected ? status.onDarkPrimary : status.onDarkSecondary,
        );
    return Semantics(
      button: true,
      selected: selected,
      label: item.label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        borderRadius: CosechaRadius.buttonAll,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOut,
              width: 56,
              height: 32,
              decoration: ShapeDecoration(
                color: selected ? scheme.primaryContainer : Colors.transparent,
                shape: const StadiumBorder(),
              ),
              child: Icon(
                selected ? item.selectedIcon : item.icon,
                size: CosechaSize.icon,
                color: selected
                    ? scheme.onPrimaryContainer
                    : status.onDarkSecondary,
              ),
            ),
            const SizedBox(height: CosechaSpace.xxs),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(item.label, maxLines: 1, style: labelStyle),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MoreButton extends StatelessWidget {
  const _MoreButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final ValueChanged<Rect> onTap;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = CosechaStatusColors.of(context);
    return SizedBox(
      width: CosechaSize.navMoreButton + 2 * CosechaSpace.xs + 4,
      child: Center(
        child: Tooltip(
          message: label,
          child: Semantics(
            button: true,
            selected: selected,
            label: label,
            excludeSemantics: true,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.all(3),
              decoration: ShapeDecoration(
                shape: CircleBorder(
                  side: BorderSide(
                    color: selected
                        ? status.onDarkPrimary
                        : Colors.transparent,
                    width: 2,
                  ),
                ),
              ),
              child: Material(
                color: scheme.primaryContainer,
                shape: const CircleBorder(),
                clipBehavior: Clip.antiAlias,
                child: Builder(
                  builder: (buttonContext) => InkWell(
                    onTap: () {
                      final box =
                          buttonContext.findRenderObject()! as RenderBox;
                      onTap(box.localToGlobal(Offset.zero) & box.size);
                    },
                    child: SizedBox.square(
                      dimension: CosechaSize.navMoreButton,
                      child: Icon(
                        Icons.more_horiz,
                        size: CosechaSize.icon,
                        color: scheme.onPrimaryContainer,
                      ),
                    ),
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
