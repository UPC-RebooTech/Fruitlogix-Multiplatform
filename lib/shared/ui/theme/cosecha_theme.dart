import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'cosecha_color_scheme.dart';
import 'cosecha_palette.dart';
import 'cosecha_status_colors.dart';
import 'cosecha_tokens.dart';
import 'cosecha_typography.dart';

/// `ThemeData` of the Cosecha design system (Material 3, light only for now).
///
/// Component themes follow `docs/cosecha-design-system.md`:
/// - FilledButton = primary CTA: lime pill, 56 high. One per screen.
/// - ElevatedButton = secondary: forest fill, radius 12, 56 high, no shadow.
/// - TextButton = moss text, 48 high.
/// - Card = white card with a thin green border (radius 18, flat). Dark cards
///   are an explicit component, not the default.
/// - Text fields: label above the field (rendered by the component), border
///   `outline`, radius 12, moss on focus, pomegranate on error.
abstract final class CosechaTheme {
  /// Status and navigation bars: deep forest with light icons.
  static const SystemUiOverlayStyle systemBars = SystemUiOverlayStyle(
    statusBarColor: CosechaPalette.forestDeep,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness: Brightness.dark, // iOS: light content
    systemNavigationBarColor: CosechaPalette.forestDeep,
    systemNavigationBarIconBrightness: Brightness.light,
    systemNavigationBarDividerColor: CosechaPalette.forestDeep,
  );

  static ThemeData get light => _build(cosechaLightColorScheme);

  static ThemeData _build(ColorScheme scheme) {
    final textTheme = CosechaTypography.textTheme.apply(
      bodyColor: scheme.onSurface,
      displayColor: scheme.onSurface,
    );
    const status = CosechaStatusColors.light;

    // Bars (top, bottom) use deep forest, which is not an M3 role.
    const barColor = CosechaPalette.forestDeep;

    final disabledFill = scheme.surfaceContainerHigh;
    final disabledContent = scheme.onSurfaceVariant;

    return ThemeData(
      useMaterial3: true,
      brightness: scheme.brightness,
      colorScheme: scheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: scheme.surface,
      canvasColor: scheme.surface,
      dividerColor: scheme.outlineVariant,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      visualDensity: VisualDensity.standard,
      extensions: const <ThemeExtension<dynamic>>[
        status,
        CosechaDataText.standard,
      ],
      iconTheme: IconThemeData(color: scheme.onSurface, size: CosechaSize.icon),

      // ── Bars ──────────────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: barColor,
        foregroundColor: status.onDarkPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        systemOverlayStyle: systemBars,
        titleTextStyle:
            textTheme.titleMedium?.copyWith(color: status.onDarkPrimary),
        toolbarTextStyle:
            textTheme.bodyMedium?.copyWith(color: status.onDarkPrimary),
        iconTheme: IconThemeData(
          color: status.onDarkPrimary,
          size: CosechaSize.icon,
        ),
        actionsIconTheme: IconThemeData(
          color: status.onDarkPrimary,
          size: CosechaSize.icon,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: barColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: CosechaSize.navBarHeight,
        indicatorColor: scheme.primaryContainer,
        indicatorShape: const StadiumBorder(),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => textTheme.labelSmall?.copyWith(
            letterSpacing: 0, // bar labels are not overlines
            color: states.contains(WidgetState.selected)
                ? status.onDarkPrimary
                : status.onDarkSecondary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(
            size: CosechaSize.icon,
            color: states.contains(WidgetState.selected)
                ? scheme.onPrimaryContainer
                : status.onDarkSecondary,
          ),
        ),
      ),

      // ── Buttons ───────────────────────────────────────────────────────
      // Primary CTA. Text shrinks to 13 sp before wrapping (handled by the
      // button component, max 2 lines).
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledFill
                : scheme.primaryContainer,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledContent
                : scheme.onPrimaryContainer,
          ),
          overlayColor: WidgetStatePropertyAll(
            scheme.onPrimaryContainer.withValues(alpha: 0.08),
          ),
          elevation: const WidgetStatePropertyAll(0),
          minimumSize: const WidgetStatePropertyAll(
            Size(64, CosechaSize.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: CosechaSpace.sm,
              vertical: CosechaSpace.xs,
            ),
          ),
          iconSize: const WidgetStatePropertyAll(CosechaSize.iconSm),
          shape: const WidgetStatePropertyAll(StadiumBorder()),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      // Secondary action on light surfaces.
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledFill
                : scheme.secondary,
          ),
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledContent
                : scheme.onSecondary,
          ),
          overlayColor: WidgetStatePropertyAll(
            scheme.onSecondary.withValues(alpha: 0.10),
          ),
          elevation: const WidgetStatePropertyAll(0),
          shadowColor: const WidgetStatePropertyAll(Colors.transparent),
          minimumSize: const WidgetStatePropertyAll(
            Size(64, CosechaSize.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: CosechaSpace.sm,
              vertical: CosechaSpace.xs,
            ),
          ),
          iconSize: const WidgetStatePropertyAll(CosechaSize.iconSm),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: CosechaRadius.buttonAll),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      // Not part of Cosecha's button set; kept consistent in case it is used.
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledContent
                : scheme.secondary,
          ),
          side: WidgetStateProperty.resolveWith(
            (states) => BorderSide(
              color: states.contains(WidgetState.disabled)
                  ? scheme.outlineVariant
                  : scheme.outline,
            ),
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(64, CosechaSize.buttonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: CosechaSpace.sm,
              vertical: CosechaSpace.xs,
            ),
          ),
          iconSize: const WidgetStatePropertyAll(CosechaSize.iconSm),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: CosechaRadius.buttonAll),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.disabled)
                ? disabledContent
                : scheme.primary,
          ),
          minimumSize: const WidgetStatePropertyAll(
            Size(CosechaSize.minTouch, CosechaSize.textButtonHeight),
          ),
          padding: const WidgetStatePropertyAll(
            EdgeInsets.symmetric(
              horizontal: CosechaSpace.sm,
              vertical: CosechaSpace.xs,
            ),
          ),
          iconSize: const WidgetStatePropertyAll(CosechaSize.iconSm),
          shape: const WidgetStatePropertyAll(
            RoundedRectangleBorder(borderRadius: CosechaRadius.buttonAll),
          ),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge),
        ),
      ),
      iconButtonTheme: const IconButtonThemeData(
        style: ButtonStyle(
          minimumSize: WidgetStatePropertyAll(
            Size(CosechaSize.minTouch, CosechaSize.minTouch),
          ),
          iconSize: WidgetStatePropertyAll(CosechaSize.icon),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: CosechaRadius.heroAll),
      ),

      // ── Surfaces ──────────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shadowColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: CosechaRadius.cardAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: scheme.inverseSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: CosechaRadius.dialogAll,
        ),
        titleTextStyle:
            textTheme.titleLarge?.copyWith(color: status.onDarkPrimary),
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: status.onDarkSecondary),
        iconColor: status.onDarkPrimary,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surface,
        modalBackgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        modalElevation: 0,
        showDragHandle: true,
        dragHandleColor: scheme.outline,
        shape: const RoundedRectangleBorder(
          borderRadius: CosechaRadius.bottomSheet,
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onInverseSurface),
        actionTextColor: scheme.inversePrimary,
        elevation: 0,
        shape: const RoundedRectangleBorder(borderRadius: CosechaRadius.tagAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: CosechaRadius.buttonAll,
          side: BorderSide(color: scheme.outlineVariant),
        ),
        textStyle: textTheme.bodyMedium,
      ),
      datePickerTheme: DatePickerThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: const RoundedRectangleBorder(
          borderRadius: CosechaRadius.dialogAll,
        ),
        headerBackgroundColor: scheme.inverseSurface,
        headerForegroundColor: scheme.onInverseSurface,
      ),

      // ── Inputs ────────────────────────────────────────────────────────
      // The label goes ABOVE the field (titleSmall), rendered by the text
      // field component; never use floating labels.
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surface,
        floatingLabelBehavior: FloatingLabelBehavior.never,
        isDense: false,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: CosechaSpace.sm,
          vertical: 15, // 15 + 26 (bodyLarge line) + 15 = 56
        ),
        hintStyle:
            textTheme.bodyLarge?.copyWith(color: scheme.onSurfaceVariant),
        helperStyle:
            textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
        errorStyle: textTheme.bodySmall?.copyWith(color: scheme.error),
        errorMaxLines: 2,
        helperMaxLines: 2,
        prefixIconColor: scheme.onSurfaceVariant,
        suffixIconColor: scheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: CosechaRadius.buttonAll,
          borderSide: BorderSide(color: scheme.outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: CosechaRadius.buttonAll,
          borderSide: BorderSide(color: scheme.outline),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: CosechaRadius.buttonAll,
          borderSide: BorderSide(color: scheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: CosechaRadius.buttonAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: CosechaRadius.buttonAll,
          borderSide: BorderSide(color: scheme.error, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: CosechaRadius.buttonAll,
          borderSide: BorderSide(color: scheme.outlineVariant),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: scheme.primary,
        selectionColor: scheme.primary.withValues(alpha: 0.24),
        selectionHandleColor: scheme.primary,
      ),

      // ── Selection controls ────────────────────────────────────────────
      // Filter chips: pill. Selected = forest + white text; unselected =
      // surfaceContainerHigh + onSurface. The exact 48 height is set by the
      // filter chip component.
      chipTheme: ChipThemeData(
        shape: const StadiumBorder(),
        side: BorderSide.none,
        showCheckmark: false,
        elevation: 0,
        pressElevation: 0,
        color: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.secondary
              : scheme.surfaceContainerHigh,
        ),
        labelStyle: textTheme.labelMedium?.copyWith(
          color: WidgetStateColor.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? scheme.onSecondary
                : scheme.onSurface,
          ),
        ),
        iconTheme: IconThemeData(
          size: CosechaSize.iconSm,
          color: scheme.onSurface,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: CosechaSpace.inner,
          vertical: CosechaSpace.xs,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.onPrimary
              : scheme.outline,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.surfaceContainerHigh,
        ),
        trackOutlineColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? Colors.transparent
              : scheme.outline,
        ),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : Colors.transparent,
        ),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outline, width: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(4)),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? scheme.primary
              : scheme.outline,
        ),
      ),

      // ── Lists, progress, dividers ─────────────────────────────────────
      listTileTheme: ListTileThemeData(
        minTileHeight: CosechaSize.settingsRow,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: CosechaSpace.sm),
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        titleTextStyle: textTheme.titleSmall,
        subtitleTextStyle:
            textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: scheme.primary,
        linearTrackColor: scheme.surfaceContainerHigh,
        circularTrackColor: scheme.surfaceContainerHigh,
        linearMinHeight: CosechaSize.progressBar,
        borderRadius: const BorderRadius.all(
          Radius.circular(CosechaSize.progressBar / 2),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
        thickness: 1,
        space: 1,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: scheme.inverseSurface,
          borderRadius: CosechaRadius.tagAll,
        ),
        textStyle:
            textTheme.bodySmall?.copyWith(color: scheme.onInverseSurface),
      ),
    );
  }
}
