import 'package:flutter/material.dart';

/// FruitLogix mark (the red apple), transparent background.
class FruitLogixLogo extends StatelessWidget {
  const FruitLogixLogo({this.size = 96, this.semanticLabel, super.key});

  static const String asset = 'assets/images/fruitlogix_logo.png';

  final double size;

  /// Null when it is decorative (e.g. next to the app name).
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) => Image.asset(
    asset,
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: semanticLabel,
    excludeFromSemantics: semanticLabel == null,
  );
}
