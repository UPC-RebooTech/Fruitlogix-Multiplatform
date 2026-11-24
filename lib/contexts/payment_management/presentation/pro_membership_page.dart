import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/date_format.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/membership_controller.dart';
import '../infrastructure/http_membership_repository.dart';
import 'payment_error_message.dart';
import 'pro_badge.dart';

/// US30 — "Miembro Pro" plan. The upgrade opens Stripe's native Payment
/// Sheet over this screen; the plan is shown as active only once the
/// backend confirms it through the signed webhook (TS17).
class ProMembershipPage extends StatelessWidget {
  const ProMembershipPage({
    required this.controller,
    required this.email,
    required this.name,
    super.key,
  });

  final MembershipController controller;
  final String email;
  final String name;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final textTheme = Theme.of(context).textTheme;
        final colors = CosechaStatusColors.of(context);
        final isPro = controller.isPro;

        return ListView(
          padding: const EdgeInsets.fromLTRB(
            CosechaSpace.screenMargin,
            CosechaSpace.md,
            CosechaSpace.screenMargin,
            CosechaSpace.lg,
          ),
          children: [
            CosechaCard(
              tone: CosechaCardTone.dark,
              hero: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(child: CosechaOverline(l10n.proOverline)),
                      if (isPro) const ProBadge(),
                    ],
                  ),
                  const SizedBox(height: CosechaSpace.xs),
                  Text(
                    isPro ? l10n.proActive : l10n.proHeadline,
                    style: textTheme.headlineSmall
                        ?.copyWith(color: colors.onDarkPrimary),
                  ),
                  const SizedBox(height: CosechaSpace.xxs),
                  Text(
                    isPro && controller.membership.activatedAt != null
                        ? l10n.proActiveSince(
                            formatLongDate(context, controller.membership.activatedAt!))
                        : l10n.proPrice(formatMoney(
                            HttpMembershipRepository.proMonthlyPrice, 'USD')),
                    style: CosechaDataText.of(context)
                        .dataMono
                        .copyWith(color: colors.onDarkSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.sm),
            CosechaCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (final (icon, text) in [
                    (Icons.bolt_outlined, l10n.proBenefitPriority),
                    (Icons.insights_outlined, l10n.proBenefitReports),
                    (Icons.ac_unit_outlined, l10n.proBenefitAlerts),
                  ])
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: CosechaSpace.xxs),
                      child: Row(
                        children: [
                          CosechaIconBox(icon: icon),
                          const SizedBox(width: CosechaSpace.inner),
                          Expanded(child: Text(text, style: textTheme.bodyMedium)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: CosechaSpace.md),
            if (!isPro) ..._checkout(context, l10n),
          ],
        );
      },
    );
  }

  List<Widget> _checkout(BuildContext context, AppLocalizations l10n) {
    final textTheme = Theme.of(context).textTheme;
    final stage = controller.stage;
    final available = controller.paymentsAvailable;

    final Widget? feedback = switch (stage) {
      ProCheckoutStage.preparing ||
      ProCheckoutStage.awaitingPayment =>
        _Progress(text: l10n.proPreparing),
      ProCheckoutStage.confirming => _Progress(text: l10n.proConfirming),
      ProCheckoutStage.pendingConfirmation => _Notice(
          icon: Icons.hourglass_top_outlined,
          status: CosechaStatus.warning,
          text: l10n.proPending,
          action: CosechaTextButton(
            label: l10n.proCheckAgain,
            icon: Icons.refresh,
            onPressed: controller.confirmAgain,
          ),
        ),
      ProCheckoutStage.canceled => _Notice(
          icon: Icons.info_outline,
          status: CosechaStatus.neutral,
          text: l10n.proCanceled,
        ),
      ProCheckoutStage.failure => _Notice(
          icon: Icons.error_outline,
          status: CosechaStatus.critical,
          text: controller.error is String
              ? '${l10n.proFailed} ${controller.error}'
              : paymentErrorMessage(controller.error, l10n, fallback: l10n.proFailed),
        ),
      _ => null,
    };

    return [
      if (feedback != null) ...[feedback, const SizedBox(height: CosechaSpace.sm)],
      if (!available)
        _Notice(
          icon: Icons.phonelink_erase_outlined,
          status: CosechaStatus.neutral,
          text: l10n.proUnavailable,
        )
      else
        CosechaPrimaryButton(
          label: l10n.proUpgrade,
          icon: Icons.workspace_premium_outlined,
          onPressed: controller.busy || stage == ProCheckoutStage.pendingConfirmation
              ? null
              : () => controller.upgradeToPro(email: email, name: name),
        ),
      const SizedBox(height: CosechaSpace.xs),
      Row(
        children: [
          Icon(
            Icons.lock_outline,
            size: CosechaSize.iconSm,
            color: context.cosechaContentSecondary,
          ),
          const SizedBox(width: CosechaSpace.xs),
          Expanded(
            child: Text(
              l10n.proSecureNote,
              style: textTheme.bodySmall
                  ?.copyWith(color: context.cosechaContentSecondary),
            ),
          ),
        ],
      ),
    ];
  }
}

class _Progress extends StatelessWidget {
  const _Progress({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) => Semantics(
        liveRegion: true,
        child: CosechaCard(
          child: Row(
            children: [
              const SizedBox.square(
                dimension: CosechaSize.iconSm,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: CosechaSpace.inner),
              Expanded(child: Text(text)),
            ],
          ),
        ),
      );
}

class _Notice extends StatelessWidget {
  const _Notice({
    required this.icon,
    required this.status,
    required this.text,
    this.action,
  });

  final IconData icon;
  final CosechaStatus status;
  final String text;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final tone = CosechaStatusColors.of(context).tone(status);
    return Semantics(
      liveRegion: true,
      child: CosechaCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(icon, color: tone.color),
                const SizedBox(width: CosechaSpace.inner),
                Expanded(child: Text(text)),
              ],
            ),
            if (action != null) ...[
              const SizedBox(height: CosechaSpace.xs),
              action!,
            ],
          ],
        ),
      ),
    );
  }
}
