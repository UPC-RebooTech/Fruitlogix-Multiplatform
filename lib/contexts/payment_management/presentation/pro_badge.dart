import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/theme/theme.dart';

/// "Miembro Pro" insignia: lime pill shown in the top bar once the backend
/// confirms the plan.
class ProBadge extends StatelessWidget {
  const ProBadge({this.compact = false, super.key});

  /// Only the "PRO" word (narrow top bars).
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      label: l10n.proBadge,
      excludeSemantics: true,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: CosechaSpace.xs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: scheme.primaryContainer,
          borderRadius: CosechaRadius.tagAll,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.workspace_premium, size: 14, color: scheme.onPrimaryContainer),
            const SizedBox(width: 2),
            Text(
              compact ? 'PRO' : l10n.proBadge.toUpperCase(),
              style: Theme.of(context)
                  .textTheme
                  .labelSmall
                  ?.copyWith(color: scheme.onPrimaryContainer, height: 1.2),
            ),
          ],
        ),
      ),
    );
  }
}
