import 'package:flutter/material.dart';

import 'fruitlogix_theme.dart';

/// Temporary integration point until each feature branch is merged.
class FeaturePlaceholderPage extends StatelessWidget {
  const FeaturePlaceholderPage({
    required this.title,
    required this.boundedContext,
    super.key,
  });

  final String title;
  final String boundedContext;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(28),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.construction_rounded,
                    size: 48, color: FruitLogixPalette.lime),
                const SizedBox(height: 16),
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    )),
                const SizedBox(height: 10),
                const Text('Implementation pending',
                    style: TextStyle(color: FruitLogixPalette.lime)),
                const SizedBox(height: 8),
                Text(boundedContext,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: FruitLogixPalette.muted)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
