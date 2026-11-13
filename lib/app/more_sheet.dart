import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../shared/ui/components/components.dart';
import '../shared/ui/theme/theme.dart';

/// Destinations reachable from the "More" button of the bottom bar.
///
/// Reserved for later sprints (not shown yet): incident history, messages,
/// Pro plan (Stripe) and biometric sign-in settings.
enum MoreDestination { payments, profile }

/// Bottom sheet opened by the "More" button. Returns the chosen destination,
/// or null when dismissed.
Future<MoreDestination?> showMoreSheet(BuildContext context) {
  return showModalBottomSheet<MoreDestination>(
    context: context,
    isScrollControlled: true,
    builder: (sheetContext) {
      final l10n = AppLocalizations.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            CosechaSpace.md,
            0,
            CosechaSpace.md,
            CosechaSpace.lg,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Semantics(
                header: true,
                child: Text(
                  l10n.moreSheetTitle,
                  style: Theme.of(sheetContext).textTheme.titleLarge,
                ),
              ),
              const SizedBox(height: CosechaSpace.sm),
              CosechaActionRow(
                icon: Icons.account_balance_wallet_outlined,
                title: l10n.paymentsTitle,
                detail: l10n.paymentsDetail,
                onTap: () =>
                    Navigator.of(sheetContext).pop(MoreDestination.payments),
              ),
              const SizedBox(height: CosechaSpace.xs),
              CosechaActionRow(
                icon: Icons.storefront_outlined,
                title: l10n.profileTitle,
                detail: l10n.profileDetail,
                onTap: () =>
                    Navigator.of(sheetContext).pop(MoreDestination.profile),
              ),
            ],
          ),
        ),
      );
    },
  );
}
