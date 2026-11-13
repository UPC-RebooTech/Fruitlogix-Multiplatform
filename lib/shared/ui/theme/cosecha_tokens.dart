import 'package:flutter/painting.dart';

/// Corner radii of the Cosecha design system.
///
/// Flat design: cards have no shadows, hierarchy comes from surface tone.
abstract final class CosechaRadius {
  /// Status tags, badges, snackbar.
  static const double tag = 8;

  /// Secondary button, text fields, menu chips, icon box.
  static const double button = 12;

  /// List cards, KPI cards.
  static const double card = 18;

  /// Hero card, FAB.
  static const double hero = 24;

  /// Dialogs and the top corners of bottom sheets.
  static const double dialog = 28;

  static const BorderRadius tagAll = BorderRadius.all(Radius.circular(tag));
  static const BorderRadius buttonAll = BorderRadius.all(Radius.circular(button));
  static const BorderRadius cardAll = BorderRadius.all(Radius.circular(card));
  static const BorderRadius heroAll = BorderRadius.all(Radius.circular(hero));
  static const BorderRadius dialogAll = BorderRadius.all(Radius.circular(dialog));
  static const BorderRadius bottomSheet = BorderRadius.vertical(
    top: Radius.circular(dialog),
  );

  // Pill (full capsule) is only for the primary button, the navigation
  // indicator, filter chips, segmented tabs, avatars and progress bars.
  // Use StadiumBorder for those.
}

/// 8 dp spacing grid. [xxs] and [inner] are only for use inside components
/// (icon to text, chip padding); layouts use the steps of 8.
abstract final class CosechaSpace {
  static const double xxs = 4;
  static const double xs = 8;
  static const double inner = 12;

  /// Screen margin and card padding.
  static const double sm = 16;

  /// Between sections, horizontal padding of bottom sheets.
  static const double md = 24;

  /// Large gaps, bottom padding of bottom sheets.
  static const double lg = 32;

  /// Very large gaps (empty states).
  static const double xl = 48;

  /// Default screen margin.
  static const double screenMargin = sm;
}

/// Touch targets, icon sizes and fixed component heights.
abstract final class CosechaSize {
  /// Minimum touch target for any control.
  static const double minTouch = 48;

  /// Field actions (scan, confirm reception...), quick action circle.
  static const double fieldTouch = 56;

  /// Primary and secondary button height.
  static const double buttonHeight = 56;

  /// Text button height.
  static const double textButtonHeight = 48;

  /// Text field height.
  static const double fieldHeight = 56;

  /// Settings row (navigation, switch, radio).
  static const double settingsRow = 64;

  /// Filter chip and segmented tabs height.
  static const double chipHeight = 48;

  /// Bottom navigation bar height.
  static const double navBarHeight = 72;

  /// "More" button of the bottom bar (lime circle).
  static const double navMoreButton = 52;

  /// Top bar avatar.
  static const double topBarAvatar = 36;

  /// Progress bar thickness (capsule).
  static const double progressBar = 8;

  static const double iconSm = 20;
  static const double icon = 24;
  static const double iconBox = 40;
  static const double kpiIconBox = 36;
}
