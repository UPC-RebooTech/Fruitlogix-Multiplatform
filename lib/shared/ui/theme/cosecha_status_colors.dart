import 'package:flutter/material.dart';

import 'cosecha_palette.dart';

/// Semantic states of Cosecha. States never rely on color alone: always
/// combine the container color with an icon or dot and a text.
enum CosechaStatus {
  /// Maduro: delivered, approved, paid, on time.
  success,

  /// Mango: due today, delayed, offline.
  warning,

  /// Granada: rejected, overdue, out of range.
  critical,

  /// Glaciar: in transit, cold chain, syncing. Reserved for cold chain,
  /// sensors and information; never decorative.
  info,

  /// Menta: pending, draft, preparing.
  neutral,

  /// Lima: ready, user role.
  highlight,
}

/// The four colors of one semantic state.
@immutable
class StatusTone {
  const StatusTone({
    required this.color,
    required this.container,
    required this.onContainer,
    required this.onDark,
  });

  /// Dot, icon or accent text on light surfaces.
  final Color color;

  /// Tag background on light surfaces.
  final Color container;

  /// Text on [container].
  final Color onContainer;

  /// Accent on dark surfaces. The tag background on dark is this same color
  /// at [CosechaStatusColors.onDarkContainerAlpha].
  final Color onDark;

  static StatusTone lerp(StatusTone a, StatusTone b, double t) => StatusTone(
        color: Color.lerp(a.color, b.color, t)!,
        container: Color.lerp(a.container, b.container, t)!,
        onContainer: Color.lerp(a.onContainer, b.onContainer, t)!,
        onDark: Color.lerp(a.onDark, b.onDark, t)!,
      );
}

/// Semantic status colors and text colors for dark surfaces.
///
/// Usage: `Theme.of(context).extension<CosechaStatusColors>()!` or the
/// shortcut `CosechaStatusColors.of(context)`.
@immutable
class CosechaStatusColors extends ThemeExtension<CosechaStatusColors> {
  const CosechaStatusColors({
    required this.success,
    required this.warning,
    required this.critical,
    required this.info,
    required this.neutral,
    required this.highlight,
    required this.criticalAlertCard,
    required this.onDarkPrimary,
    required this.onDarkSecondary,
  });

  /// Opacity of a status tag background on dark surfaces.
  static const double onDarkContainerAlpha = 0.18;

  final StatusTone success;
  final StatusTone warning;
  final StatusTone critical;
  final StatusTone info;
  final StatusTone neutral;
  final StatusTone highlight;

  /// Background of a critical alert card (white text on top).
  final Color criticalAlertCard;

  /// Primary text on dark surfaces.
  final Color onDarkPrimary;

  /// Secondary text on dark surfaces.
  final Color onDarkSecondary;

  static const CosechaStatusColors light = CosechaStatusColors(
    success: StatusTone(
      color: CosechaPalette.ripe,
      container: CosechaPalette.ripeContainer,
      onContainer: CosechaPalette.onRipeContainer,
      onDark: CosechaPalette.successOnDark,
    ),
    warning: StatusTone(
      color: CosechaPalette.mango,
      container: CosechaPalette.mangoContainer,
      onContainer: CosechaPalette.onMangoContainer,
      onDark: CosechaPalette.warningOnDark,
    ),
    critical: StatusTone(
      color: CosechaPalette.pomegranate,
      container: CosechaPalette.pomegranateContainer,
      onContainer: CosechaPalette.onPomegranateContainer,
      onDark: CosechaPalette.criticalOnDark,
    ),
    info: StatusTone(
      color: CosechaPalette.glacier,
      container: CosechaPalette.glacierSoft,
      onContainer: CosechaPalette.onGlacierSoft,
      onDark: CosechaPalette.infoOnDark,
    ),
    neutral: StatusTone(
      color: CosechaPalette.neutralVariant,
      container: CosechaPalette.mint,
      onContainer: CosechaPalette.forestDeep,
      onDark: CosechaPalette.textSecondaryOnDark,
    ),
    highlight: StatusTone(
      color: CosechaPalette.forestDeep,
      container: CosechaPalette.lime,
      onContainer: CosechaPalette.forestDeep,
      onDark: CosechaPalette.lime,
    ),
    criticalAlertCard: CosechaPalette.criticalAlertCard,
    onDarkPrimary: CosechaPalette.textPrimaryOnDark,
    onDarkSecondary: CosechaPalette.textSecondaryOnDark,
  );

  static CosechaStatusColors of(BuildContext context) =>
      Theme.of(context).extension<CosechaStatusColors>() ?? light;

  StatusTone tone(CosechaStatus status) => switch (status) {
        CosechaStatus.success => success,
        CosechaStatus.warning => warning,
        CosechaStatus.critical => critical,
        CosechaStatus.info => info,
        CosechaStatus.neutral => neutral,
        CosechaStatus.highlight => highlight,
      };

  @override
  CosechaStatusColors copyWith({
    StatusTone? success,
    StatusTone? warning,
    StatusTone? critical,
    StatusTone? info,
    StatusTone? neutral,
    StatusTone? highlight,
    Color? criticalAlertCard,
    Color? onDarkPrimary,
    Color? onDarkSecondary,
  }) =>
      CosechaStatusColors(
        success: success ?? this.success,
        warning: warning ?? this.warning,
        critical: critical ?? this.critical,
        info: info ?? this.info,
        neutral: neutral ?? this.neutral,
        highlight: highlight ?? this.highlight,
        criticalAlertCard: criticalAlertCard ?? this.criticalAlertCard,
        onDarkPrimary: onDarkPrimary ?? this.onDarkPrimary,
        onDarkSecondary: onDarkSecondary ?? this.onDarkSecondary,
      );

  @override
  CosechaStatusColors lerp(
    covariant ThemeExtension<CosechaStatusColors>? other,
    double t,
  ) {
    if (other is! CosechaStatusColors) return this;
    return CosechaStatusColors(
      success: StatusTone.lerp(success, other.success, t),
      warning: StatusTone.lerp(warning, other.warning, t),
      critical: StatusTone.lerp(critical, other.critical, t),
      info: StatusTone.lerp(info, other.info, t),
      neutral: StatusTone.lerp(neutral, other.neutral, t),
      highlight: StatusTone.lerp(highlight, other.highlight, t),
      criticalAlertCard:
          Color.lerp(criticalAlertCard, other.criticalAlertCard, t)!,
      onDarkPrimary: Color.lerp(onDarkPrimary, other.onDarkPrimary, t)!,
      onDarkSecondary: Color.lerp(onDarkSecondary, other.onDarkSecondary, t)!,
    );
  }
}
