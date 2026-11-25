import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/invoice_reminder_service.dart';
import '../domain/invoice_reminder_policy.dart';

/// US70 — Reminder settings: on/off and anticipation window (1, 3, 7 days).
class InvoiceRemindersCard extends StatelessWidget {
  const InvoiceRemindersCard({required this.service, super.key});

  final InvoiceReminderService service;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final textTheme = Theme.of(context).textTheme;
        return CosechaCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  const CosechaIconBox(icon: Icons.notifications_active_outlined),
                  const SizedBox(width: CosechaSpace.inner),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.remindersTitle, style: textTheme.titleSmall),
                        Text(
                          l10n.remindersEnabled,
                          style: textTheme.bodySmall?.copyWith(
                            color: context.cosechaContentSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: service.enabled,
                    onChanged: (value) => service.updateSettings(enabled: value),
                  ),
                ],
              ),
              if (service.enabled) ...[
                const SizedBox(height: CosechaSpace.inner),
                Wrap(
                  spacing: CosechaSpace.xs,
                  runSpacing: CosechaSpace.xs,
                  children: [
                    for (final days in InvoiceReminderPolicy.allowedLeadDays)
                      CosechaFilterChip(
                        label: l10n.remindersLeadDays(days),
                        selected: service.leadDays == days,
                        onSelected: (_) => service.updateSettings(leadDays: days),
                      ),
                  ],
                ),
                if (service.permissionGranted == false) ...[
                  const SizedBox(height: CosechaSpace.inner),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.notifications_off_outlined,
                        size: CosechaSize.iconSm,
                        color: CosechaStatusColors.of(context).critical.color,
                      ),
                      const SizedBox(width: CosechaSpace.xs),
                      Expanded(
                        child: Text(
                          l10n.remindersPermissionDenied,
                          style: textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ],
          ),
        );
      },
    );
  }
}

/// US70 — In-app banner with the invoices inside the anticipation window.
class UpcomingRemindersBanner extends StatelessWidget {
  const UpcomingRemindersBanner({
    required this.service,
    this.onTap,
    super.key,
  });

  final InvoiceReminderService service;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: service,
      builder: (context, _) {
        final count = service.upcoming.length;
        if (count == 0) return const SizedBox.shrink();
        final l10n = AppLocalizations.of(context);
        return Padding(
          padding: const EdgeInsets.only(bottom: CosechaSpace.xs),
          child: CosechaActionRow(
            icon: Icons.notifications_active_outlined,
            title: l10n.remindersUpcoming(count),
            detail: l10n.remindersUpcomingDetail,
            onTap: onTap,
            trailing: onTap == null
                ? CosechaStatusTag(
                    label: '$count',
                    status: CosechaStatus.warning,
                  )
                : null,
          ),
        );
      },
    );
  }
}
