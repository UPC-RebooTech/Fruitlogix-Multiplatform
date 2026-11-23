import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/formatters/money_format.dart';
import '../../../shared/ui/theme/theme.dart';
import '../application/financial_overview_controller.dart';
import 'payment_error_message.dart';

/// US36 — Total balance and accumulated debt on the dashboard.
///
/// Scenario 1: renders at once with a loading indicator, which is replaced
/// by the amounts in soles as soon as the API answers. The rest of the
/// dashboard and the navigation never wait for it.
class FinancialBalanceCard extends StatelessWidget {
  const FinancialBalanceCard({
    required this.controller,
    this.onOpenPayments,
    super.key,
  });

  final FinancialOverviewController controller;
  final VoidCallback? onOpenPayments;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        final l10n = AppLocalizations.of(context);
        final Widget content;
        if (controller.hasData) {
          content = _Loaded(controller: controller);
        } else if (controller.status == OverviewStatus.failure) {
          content = _Failed(
            message: paymentErrorMessage(
              controller.error,
              l10n,
              fallback: l10n.balanceError,
            ),
            onRetry: controller.load,
          );
        } else {
          content = const _Loading();
        }
        return Semantics(
          liveRegion: true,
          child: CosechaCard(
            tone: CosechaCardTone.dark,
            hero: true,
            onTap: controller.hasData ? onOpenPayments : null,
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 250),
              child: KeyedSubtree(
                key: ValueKey(controller.hasData ? 'ready' : controller.status),
                child: content,
              ),
            ),
          ),
        );
      },
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CosechaStatusColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CosechaOverline(l10n.balanceDebt, color: colors.onDarkSecondary),
        const SizedBox(height: CosechaSpace.inner),
        CosechaProgressBar(value: null, semanticLabel: l10n.balanceLoading),
        const SizedBox(height: CosechaSpace.xs),
        Text(
          l10n.balanceLoading,
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colors.onDarkSecondary),
        ),
      ],
    );
  }
}

class _Loaded extends StatelessWidget {
  const _Loaded({required this.controller});

  final FinancialOverviewController controller;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CosechaStatusColors.of(context);
    final data = CosechaDataText.of(context);
    final balance = controller.balance;
    final debt = formatSoles(balance.accumulatedDebt);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: CosechaOverline(l10n.balanceDebt, color: colors.onDarkSecondary),
            ),
            if (balance.overdueCount > 0)
              CosechaStatusTag(
                label: l10n.paymentStatusOverdue,
                status: CosechaStatus.critical,
              )
            else if (balance.outstandingCount == 0)
              CosechaStatusTag(
                label: l10n.balanceUpToDate,
                status: CosechaStatus.success,
              ),
          ],
        ),
        const SizedBox(height: CosechaSpace.xxs),
        Semantics(
          label: '${l10n.balanceDebt}: $debt',
          excludeSemantics: true,
          child: SizedBox(
            width: double.infinity,
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                debt,
                maxLines: 1,
                style: data.kpiNumber.copyWith(color: colors.onDarkPrimary),
              ),
            ),
          ),
        ),
        Text(
          l10n.balancePendingInvoices(balance.outstandingCount),
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: colors.onDarkSecondary),
        ),
        const SizedBox(height: CosechaSpace.sm),
        Row(
          children: [
            Expanded(
              child: _Figure(
                label: l10n.balanceTotal,
                value: formatSoles(balance.totalBilled),
              ),
            ),
            const SizedBox(width: CosechaSpace.xs),
            Expanded(
              child: _Figure(
                label: l10n.balanceOverdue,
                value: formatSoles(balance.overdueAmount),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _Figure extends StatelessWidget {
  const _Figure({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = CosechaStatusColors.of(context);
    return Semantics(
      label: '$label: $value',
      excludeSemantics: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CosechaOverline(label, color: colors.onDarkSecondary),
          const SizedBox(height: CosechaSpace.xxs),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              value,
              maxLines: 1,
              style: CosechaDataText.of(context)
                  .dataMono
                  .copyWith(color: colors.onDarkPrimary),
            ),
          ),
        ],
      ),
    );
  }
}

class _Failed extends StatelessWidget {
  const _Failed({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final colors = CosechaStatusColors.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CosechaOverline(l10n.balanceDebt, color: colors.onDarkSecondary),
        const SizedBox(height: CosechaSpace.xs),
        Text(
          message,
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: colors.onDarkPrimary),
        ),
        const SizedBox(height: CosechaSpace.xs),
        Align(
          alignment: AlignmentDirectional.centerStart,
          child: TextButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: Text(l10n.paymentsRetry),
            style: TextButton.styleFrom(foregroundColor: colors.onDarkPrimary),
          ),
        ),
      ],
    );
  }
}
