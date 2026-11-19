import 'package:flutter/painting.dart';

/// Raw brand values of the Cosecha design system (shared with the Kotlin app
/// and the landing page).
///
/// Only the theme files in this folder should read these values. Screens and
/// components use roles instead: `Theme.of(context).colorScheme`,
/// [CosechaStatusColors] and [CosechaDataText]. That way a future dark theme
/// does not force changes in every screen.
abstract final class CosechaPalette {
  // Brand
  static const Color lime = Color(0xFFD4E952);
  static const Color limeSoft = Color(0xFFE9F6AE); // reserved
  static const Color forest = Color(0xFF192E21);
  static const Color forestDeep = Color(0xFF13241A);
  static const Color moss = Color(0xFF406C47);
  static const Color mint = Color(0xFFDFEBE0);
  static const Color glacier = Color(0xFF00676B);
  static const Color glacierSoft = Color(0xFFC8EEF0);
  static const Color onGlacierSoft = Color(0xFF002022);

  // Neutrals (leaf tone)
  static const Color neutral0 = Color(0xFFFFFFFF);
  static const Color neutral10 = Color(0xFFF7FAF6);
  static const Color neutral20 = Color(0xFFF0F5EF);
  static const Color neutral30 = Color(0xFFE8F1E6);
  static const Color neutral40 = Color(0xFFDFEBE0);
  static const Color neutral50 = Color(0xFFD5E3D6);
  static const Color neutralVariant = Color(0xFF4A5A4F);
  static const Color outline = Color(0xFF74857A);
  static const Color outlineVariant = Color(0xFFC9D6CB);

  // Error (Granada)
  static const Color pomegranate = Color(0xFFC2302F);
  static const Color pomegranateContainer = Color(0xFFFFDAD5);
  static const Color onPomegranateContainer = Color(0xFF5C0B0A);

  // Status on light surfaces: color / container / text on container
  static const Color ripe = Color(0xFF2D7A3F);
  static const Color ripeContainer = Color(0xFFCFF3D3);
  static const Color onRipeContainer = Color(0xFF0B3A17);
  static const Color mango = Color(0xFF8A5300);
  static const Color mangoContainer = Color(0xFFFFE2B8);
  static const Color onMangoContainer = Color(0xFF3D2400);

  // Accents on dark surfaces (forest cards, dialogs, bars)
  static const Color successOnDark = Color(0xFF6FD98A);
  static const Color warningOnDark = Color(0xFFF2B544);
  static const Color criticalOnDark = Color(0xFFFF6B5E);
  static const Color infoOnDark = Color(0xFF7DD5DA);
  static const Color textSecondaryOnDark = Color(0xFFA9C2AC);
  static const Color criticalAlertCard = Color(0xFF8E2422);

  // Text on dark
  static const Color textPrimaryOnDark = Color(0xFFFFFFFF);
  static const Color inverseOnSurface = Color(0xFFEEF5EC);
}
