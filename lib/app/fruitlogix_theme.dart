import 'package:flutter/material.dart';

/// Shared presentation tokens. Business rules stay inside bounded contexts.
abstract final class FruitLogixPalette {
  static const Color background = Color(0xFFE8F3E6);
  static const Color forest = Color(0xFF1D2E23);
  static const Color forestSoft = Color(0xFF2B4133);
  static const Color lime = Color(0xFFC9E265);
  static const Color muted = Color(0xFFA8C1AE);
  static const Color warning = Color(0xFFFFC247);
}

abstract final class FruitLogixTheme {
  static ThemeData get light {
    final scheme = ColorScheme.fromSeed(
      seedColor: FruitLogixPalette.lime,
      brightness: Brightness.light,
      surface: FruitLogixPalette.background,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: FruitLogixPalette.background,
      appBarTheme: const AppBarTheme(
        backgroundColor: FruitLogixPalette.forestSoft,
        foregroundColor: Colors.white,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: FruitLogixPalette.forestSoft,
        indicatorColor: FruitLogixPalette.lime,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
          color: states.contains(WidgetState.selected)
              ? Colors.white
              : FruitLogixPalette.muted,
          fontWeight: states.contains(WidgetState.selected)
              ? FontWeight.w700
              : FontWeight.w400,
          fontSize: 11,
        )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
          color: states.contains(WidgetState.selected)
              ? FruitLogixPalette.forest
              : FruitLogixPalette.muted,
        )),
      ),
      cardTheme: CardThemeData(
        color: FruitLogixPalette.forest,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
    );
  }
}
