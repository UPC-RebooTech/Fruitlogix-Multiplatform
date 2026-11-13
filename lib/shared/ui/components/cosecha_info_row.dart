import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import '../theme/cosecha_typography.dart';
import 'cosecha_surface.dart';

/// Read-only data row: a secondary label (bodySmall) above its value.
/// Data values (IDs, amounts, RUC, phones, temperatures) use Mono.
class CosechaInfoRow extends StatelessWidget {
  const CosechaInfoRow({
    required this.label,
    required this.value,
    this.mono = false,
    this.icon,
    super.key,
  });

  final String label;
  final String value;
  final bool mono;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final valueStyle = mono
        ? CosechaDataText.of(context).dataMono
        : textTheme.bodyLarge;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label,
          style: textTheme.bodySmall
              ?.copyWith(color: context.cosechaContentSecondary),
        ),
        const SizedBox(height: 2),
        Text(value, style: valueStyle?.copyWith(color: context.cosechaContent)),
      ],
    );
    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: icon == null
          ? content
          : Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(
                    icon,
                    size: CosechaSize.iconSm,
                    color: context.cosechaContentSecondary,
                  ),
                ),
                const SizedBox(width: CosechaSpace.inner),
                Expanded(child: content),
              ],
            ),
    );
  }
}
