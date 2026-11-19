import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../shared/ui/components/components.dart';

/// Temporary integration point for features that are not implemented yet.
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
    final l10n = AppLocalizations.of(context);
    return CosechaEmptyState(
      icon: Icons.construction_outlined,
      title: title,
      message: '${l10n.featurePending} · $boundedContext',
    );
  }
}
