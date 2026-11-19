import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_tokens.dart';
import '../theme/cosecha_typography.dart';
import 'cosecha_surface.dart';

/// One step of [CosechaTimeline].
@immutable
class CosechaTimelineStep {
  const CosechaTimelineStep({
    required this.time,
    required this.description,
    required this.completed,
  });

  final String time;
  final String description;
  final bool completed;
}

/// Vertical timeline (tracking events, lot history). Completed steps use a
/// success check; pending ones an outlined circle and secondary text, so the
/// state never relies on color alone.
class CosechaTimeline extends StatelessWidget {
  const CosechaTimeline({
    required this.steps,
    required this.completedLabel,
    required this.pendingLabel,
    super.key,
  });

  final List<CosechaTimelineStep> steps;

  /// Screen reader state labels.
  final String completedLabel;
  final String pendingLabel;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final success = CosechaStatusColors.of(context).success.color;
    final textTheme = Theme.of(context).textTheme;
    final mono = CosechaDataText.of(context).dataMonoSmall;

    return Column(
      children: [
        for (var i = 0; i < steps.length; i++)
          Semantics(
            container: true,
            label: '${steps[i].time}, ${steps[i].description}, '
                '${steps[i].completed ? completedLabel : pendingLabel}',
            excludeSemantics: true,
            child: IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SizedBox(
                    width: CosechaSize.icon,
                    child: Column(
                      children: [
                        Icon(
                          steps[i].completed
                              ? Icons.check_circle
                              : Icons.radio_button_unchecked,
                          size: CosechaSize.icon,
                          color: steps[i].completed ? success : scheme.outline,
                        ),
                        if (i < steps.length - 1)
                          Expanded(
                            child: Container(
                              width: 2,
                              margin: const EdgeInsets.symmetric(vertical: 2),
                              color: steps[i].completed
                                  ? success
                                  : scheme.outlineVariant,
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: CosechaSpace.inner),
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        bottom: i < steps.length - 1 ? CosechaSpace.sm : 0,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            steps[i].time,
                            style: mono.copyWith(
                              color: context.cosechaContentSecondary,
                            ),
                          ),
                          Text(
                            steps[i].description,
                            style: textTheme.bodyMedium?.copyWith(
                              color: steps[i].completed
                                  ? context.cosechaContent
                                  : context.cosechaContentSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
