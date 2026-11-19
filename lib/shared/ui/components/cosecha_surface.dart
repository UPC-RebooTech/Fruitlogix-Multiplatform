import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';

/// Tells the Cosecha components below it whether they sit on a dark surface
/// (forest cards, dialogs, bars), so they switch to their on-dark colors:
/// secondary and text buttons, status tags, progress bars and text colors.
///
/// Dark containers (`CosechaCard(tone: CosechaCardTone.dark)`, dialogs) set
/// it; light containers reset it. Without an ancestor, the surface is light.
class CosechaSurface extends InheritedWidget {
  const CosechaSurface({
    required this.onDark,
    required super.child,
    super.key,
  });

  final bool onDark;

  static bool isOnDark(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<CosechaSurface>()?.onDark ??
      false;

  @override
  bool updateShouldNotify(CosechaSurface oldWidget) =>
      oldWidget.onDark != onDark;
}

/// Surface-aware content colors.
extension CosechaSurfaceContext on BuildContext {
  bool get cosechaOnDark => CosechaSurface.isOnDark(this);

  /// Primary text and icon color for the current surface.
  Color get cosechaContent => cosechaOnDark
      ? CosechaStatusColors.of(this).onDarkPrimary
      : Theme.of(this).colorScheme.onSurface;

  /// Secondary text color for the current surface.
  Color get cosechaContentSecondary => cosechaOnDark
      ? CosechaStatusColors.of(this).onDarkSecondary
      : Theme.of(this).colorScheme.onSurfaceVariant;
}
