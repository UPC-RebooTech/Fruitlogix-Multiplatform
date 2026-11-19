import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_tokens.dart';
import '../theme/cosecha_typography.dart';
import 'cosecha_card.dart';
import 'cosecha_headers.dart';
import 'cosecha_icon_box.dart';

/// Dark KPI card: 36 icon box (lime at 14 %), uppercase overline and a large
/// number that shrinks to fit instead of being cut with "…".
///
/// [compact]: padding 12, no icon, value in titleMedium. Used in rows of 3.
class CosechaKpiCard extends StatelessWidget {
  const CosechaKpiCard({
    required this.label,
    required this.value,
    this.icon,
    this.compact = false,
    super.key,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final status = CosechaStatusColors.of(context);
    final valueStyle = compact
        ? Theme.of(context).textTheme.titleMedium
        : CosechaDataText.of(context).kpiNumber;

    return Semantics(
      container: true,
      label: '$label: $value',
      excludeSemantics: true,
      child: CosechaCard(
        tone: CosechaCardTone.dark,
        padding: EdgeInsets.all(compact ? CosechaSpace.inner : CosechaSpace.sm),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null && !compact) ...[
              CosechaIconBox(
                icon: icon!,
                size: CosechaSize.kpiIconBox,
                iconSize: CosechaSize.iconSm,
              ),
              const SizedBox(height: CosechaSpace.inner),
            ],
            CosechaOverline(label, color: status.onDarkSecondary),
            const SizedBox(height: CosechaSpace.xxs),
            SizedBox(
              width: double.infinity,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  value,
                  maxLines: 1,
                  style: valueStyle?.copyWith(color: status.onDarkPrimary),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
