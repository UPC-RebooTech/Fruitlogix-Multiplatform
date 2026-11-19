import 'package:flutter/material.dart';

/// Font families bundled in `assets/fonts/` (declared in pubspec.yaml).
abstract final class CosechaFonts {
  /// Display, headlines and titles (same as the landing page). 600, 700.
  static const String display = 'Poppins';

  /// Body, labels and buttons. Designed for low vision. 400–700.
  static const String body = 'AtkinsonHyperlegibleNext';

  /// Lot codes, plates, IDs, temperatures and amounts. 400–600.
  static const String mono = 'AtkinsonHyperlegibleMono';
}

/// The 15 Material 3 text styles of Cosecha.
///
/// Flutter values: `height = lineHeight / fontSize` and
/// `letterSpacing = trackingEm * fontSize`. Colors are left empty here; the
/// theme applies `onSurface`.
///
/// Rules: useful text never goes below 13 sp (12 sp only for UPPERCASE
/// overlines); status tags use sentence case; data always uses Mono
/// ([CosechaDataText]).
abstract final class CosechaTypography {
  static const TextTheme textTheme = TextTheme(
    // Hero numbers. Corrected to be the largest style of the scale
    // (was 30 sp in the Kotlin app; to be aligned there too).
    displayLarge: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: 40,
      height: 48 / 40,
      letterSpacing: -0.40,
    ),
    displayMedium: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: 36,
      height: 44 / 36,
      letterSpacing: -0.36,
    ),
    displaySmall: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: 32,
      height: 40 / 32,
      letterSpacing: -0.32,
    ),
    // Screen title.
    headlineLarge: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: 28,
      height: 36 / 28,
      letterSpacing: 0,
    ),
    // Screen title ("My account").
    headlineMedium: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: 24,
      height: 32 / 24,
      letterSpacing: 0,
    ),
    // Sub-screen / section title.
    headlineSmall: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w600,
      fontSize: 22,
      height: 30 / 22,
      letterSpacing: 0,
    ),
    // Top bar, dialog and sheet titles.
    titleLarge: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w600,
      fontSize: 20,
      height: 28 / 20,
      letterSpacing: 0,
    ),
    // Card titles.
    titleMedium: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w600,
      fontSize: 18,
      height: 26 / 18,
      letterSpacing: 0,
    ),
    // List rows, field labels.
    titleSmall: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 22 / 16,
      letterSpacing: 0,
    ),
    // Reading text, text inside fields.
    bodyLarge: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w400,
      fontSize: 17,
      height: 26 / 17,
      letterSpacing: 0,
    ),
    // Default text.
    bodyMedium: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w400,
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0,
    ),
    // Supporting text (minimum for useful content).
    bodySmall: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w400,
      fontSize: 13,
      height: 18 / 13,
      letterSpacing: 0.13,
    ),
    // Buttons.
    labelLarge: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 16,
      height: 24 / 16,
      letterSpacing: 0.16,
    ),
    // Chips, status tags.
    labelMedium: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 13,
      height: 18 / 13,
      letterSpacing: 0.26,
    ),
    // UPPERCASE overlines only.
    labelSmall: TextStyle(
      fontFamily: CosechaFonts.body,
      fontWeight: FontWeight.w600,
      fontSize: 12,
      height: 16 / 12,
      letterSpacing: 0.96,
    ),
  );
}

/// Extra data styles of Cosecha (numbers, codes, readings).
///
/// Usage: `CosechaDataText.of(context).dataMono`. Colors are empty so the
/// text inherits the color of its surface.
@immutable
class CosechaDataText extends ThemeExtension<CosechaDataText> {
  const CosechaDataText({
    required this.kpiNumber,
    required this.dataMono,
    required this.dataMonoSmall,
    required this.readingMono,
  });

  /// Large number of KPI cards. Shrinks to fit (min 18 sp, 13 sp compact)
  /// instead of being cut with "…".
  final TextStyle kpiNumber;

  /// Lot codes, plates, IDs, temperatures, amounts.
  final TextStyle dataMono;

  /// Times and IDs inside rows, @user.
  final TextStyle dataMonoSmall;

  /// Live readings (temperature, humidity).
  final TextStyle readingMono;

  static const CosechaDataText standard = CosechaDataText(
    kpiNumber: TextStyle(
      fontFamily: CosechaFonts.display,
      fontWeight: FontWeight.w700,
      fontSize: 34,
      height: 42 / 34,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
      fontFeatures: [FontFeature.tabularFigures()],
    ),
    dataMono: TextStyle(
      fontFamily: CosechaFonts.mono,
      fontWeight: FontWeight.w500,
      fontSize: 15,
      height: 22 / 15,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    dataMonoSmall: TextStyle(
      fontFamily: CosechaFonts.mono,
      fontWeight: FontWeight.w500,
      fontSize: 13,
      height: 18 / 13,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
    readingMono: TextStyle(
      fontFamily: CosechaFonts.mono,
      fontWeight: FontWeight.w600,
      fontSize: 30,
      height: 38 / 30,
      letterSpacing: 0,
      leadingDistribution: TextLeadingDistribution.even,
    ),
  );

  static CosechaDataText of(BuildContext context) =>
      Theme.of(context).extension<CosechaDataText>() ?? standard;

  @override
  CosechaDataText copyWith({
    TextStyle? kpiNumber,
    TextStyle? dataMono,
    TextStyle? dataMonoSmall,
    TextStyle? readingMono,
  }) =>
      CosechaDataText(
        kpiNumber: kpiNumber ?? this.kpiNumber,
        dataMono: dataMono ?? this.dataMono,
        dataMonoSmall: dataMonoSmall ?? this.dataMonoSmall,
        readingMono: readingMono ?? this.readingMono,
      );

  @override
  CosechaDataText lerp(
    covariant ThemeExtension<CosechaDataText>? other,
    double t,
  ) {
    if (other is! CosechaDataText) return this;
    return CosechaDataText(
      kpiNumber: TextStyle.lerp(kpiNumber, other.kpiNumber, t)!,
      dataMono: TextStyle.lerp(dataMono, other.dataMono, t)!,
      dataMonoSmall: TextStyle.lerp(dataMonoSmall, other.dataMonoSmall, t)!,
      readingMono: TextStyle.lerp(readingMono, other.readingMono, t)!,
    );
  }
}
