import 'package:flutter/material.dart';

import 'cosecha_palette.dart';

/// Material 3 color roles of Cosecha, light theme.
///
/// Built explicitly (no `ColorScheme.fromSeed`) so every role matches the
/// specification and the Kotlin app exactly. The deprecated roles
/// `background`, `onBackground` and `surfaceVariant` are covered by
/// `surface`, `onSurface` and `surfaceContainerHighest`.
const ColorScheme cosechaLightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: CosechaPalette.moss,
  onPrimary: Color(0xFFFFFFFF),
  primaryContainer: CosechaPalette.lime,
  onPrimaryContainer: CosechaPalette.forestDeep,
  inversePrimary: CosechaPalette.lime,
  secondary: CosechaPalette.forest,
  onSecondary: Color(0xFFFFFFFF),
  secondaryContainer: CosechaPalette.mint,
  onSecondaryContainer: CosechaPalette.forestDeep,
  tertiary: CosechaPalette.glacier,
  onTertiary: Color(0xFFFFFFFF),
  tertiaryContainer: CosechaPalette.glacierSoft,
  onTertiaryContainer: CosechaPalette.onGlacierSoft,
  error: CosechaPalette.pomegranate,
  onError: Color(0xFFFFFFFF),
  errorContainer: CosechaPalette.pomegranateContainer,
  onErrorContainer: CosechaPalette.onPomegranateContainer,
  surface: CosechaPalette.neutral10,
  onSurface: CosechaPalette.forestDeep,
  onSurfaceVariant: CosechaPalette.neutralVariant,
  surfaceTint: CosechaPalette.moss,
  surfaceBright: CosechaPalette.neutral0,
  surfaceDim: CosechaPalette.neutral50,
  surfaceContainerLowest: CosechaPalette.neutral0,
  surfaceContainerLow: CosechaPalette.neutral20,
  surfaceContainer: CosechaPalette.neutral30,
  surfaceContainerHigh: CosechaPalette.neutral40,
  surfaceContainerHighest: CosechaPalette.neutral50,
  inverseSurface: CosechaPalette.forest,
  onInverseSurface: CosechaPalette.inverseOnSurface,
  outline: CosechaPalette.outline,
  outlineVariant: CosechaPalette.outlineVariant,
  scrim: Color(0xFF000000),
  shadow: Color(0xFF000000),
);
