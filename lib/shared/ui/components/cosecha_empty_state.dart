import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Centered empty or error state: padding 24, optional icon, titleMedium
/// title and a secondary bodyMedium message. Errors use a 48 pomegranate
/// icon.
class CosechaEmptyState extends StatelessWidget {
  const CosechaEmptyState({
    required this.title,
    this.message,
    this.icon,
    this.isError = false,
    this.action,
    super.key,
  });

  final String title;
  final String? message;
  final IconData? icon;
  final bool isError;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final effectiveIcon = icon ?? (isError ? Icons.error_outline : null);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(CosechaSpace.md),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (effectiveIcon != null) ...[
              Icon(
                effectiveIcon,
                size: CosechaSpace.xl,
                color: isError ? scheme.error : context.cosechaContentSecondary,
              ),
              const SizedBox(height: CosechaSpace.sm),
            ],
            Text(
              title,
              textAlign: TextAlign.center,
              style: textTheme.titleMedium
                  ?.copyWith(color: context.cosechaContent),
            ),
            if (message != null) ...[
              const SizedBox(height: CosechaSpace.xs),
              Text(
                message!,
                textAlign: TextAlign.center,
                style: textTheme.bodyMedium
                    ?.copyWith(color: context.cosechaContentSecondary),
              ),
            ],
            if (action != null) ...[
              const SizedBox(height: CosechaSpace.md),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
