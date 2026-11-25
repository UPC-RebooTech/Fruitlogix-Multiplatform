import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../shared/ui/components/components.dart';
import '../../../shared/ui/theme/theme.dart';
import '../domain/commercial_order.dart';
import '../domain/order_edit.dart';

/// Collects only the fields accepted by UpdateOrderResource.
/// Product quantities and prices cannot be edited through that endpoint.
Future<OrderUpdate?> showOrderEditSheet({
  required BuildContext context,
  required CommercialOrder order,
}) => showModalBottomSheet<OrderUpdate>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _EditOrderSheet(order: order),
);

/// Cancellation remains an explicit user action. A reason is optional in the
/// backend contract, and the order remains visible in the history.
Future<OrderCancellation?> showOrderCancelSheet({
  required BuildContext context,
  required CommercialOrder order,
}) => showModalBottomSheet<OrderCancellation>(
  context: context,
  isScrollControlled: true,
  showDragHandle: true,
  builder: (_) => _CancelOrderSheet(order: order),
);

class _EditOrderSheet extends StatefulWidget {
  const _EditOrderSheet({required this.order});

  final CommercialOrder order;

  @override
  State<_EditOrderSheet> createState() => _EditOrderSheetState();
}

class _EditOrderSheetState extends State<_EditOrderSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _address = TextEditingController(
    text: widget.order.deliveryAddress,
  );
  late final TextEditingController _notes = TextEditingController(
    text: widget.order.notes ?? '',
  );
  late DateTime _date = widget.order.deliveryDate;

  @override
  void dispose() {
    _address.dispose();
    _notes.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.of(context).pop(OrderUpdate(
      orderId: widget.order.id,
      deliveryDate: _date,
      deliveryAddress: _address.text.trim(),
      notes: _notes.text.trim().isEmpty ? null : _notes.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDate = _date.isBefore(today) ? _date : today;
    final lastDate = today.add(const Duration(days: 365));
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CosechaSpace.md),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(l10n.ordersEditTitle, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: CosechaSpace.xs),
                Text(
                  l10n.orderReference(widget.order.code),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: CosechaSpace.sm),
                Text(
                  l10n.ordersEditRestrictions,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: CosechaSpace.md),
                CosechaTextField(
                  label: l10n.deliveryAddressLabel,
                  controller: _address,
                  keyboardType: TextInputType.streetAddress,
                  validator: (value) => (value ?? '').trim().isEmpty
                      ? l10n.deliveryAddressRequired
                      : null,
                ),
                const SizedBox(height: CosechaSpace.sm),
                CosechaDateField(
                  label: l10n.deliveryDateLabel,
                  firstDate: firstDate,
                  lastDate: lastDate,
                  initialValue: _date,
                  onChanged: (date) => _date = date,
                  validator: (date) {
                    if (date == null) return l10n.deliveryDateRequired;
                    final day = DateTime(date.year, date.month, date.day);
                    return day.isBefore(today) ? l10n.ordersDatePast : null;
                  },
                ),
                const SizedBox(height: CosechaSpace.sm),
                CosechaTextField(
                  label: l10n.orderNotesLabel,
                  controller: _notes,
                  maxLines: 3,
                  textInputAction: TextInputAction.newline,
                ),
                const SizedBox(height: CosechaSpace.md),
                CosechaPrimaryButton(label: l10n.ordersSaveChanges, onPressed: _submit),
                const SizedBox(height: CosechaSpace.xs),
                Center(
                  child: CosechaTextButton(
                    label: l10n.cancel,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CancelOrderSheet extends StatefulWidget {
  const _CancelOrderSheet({required this.order});

  final CommercialOrder order;

  @override
  State<_CancelOrderSheet> createState() => _CancelOrderSheetState();
}

class _CancelOrderSheetState extends State<_CancelOrderSheet> {
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  void _confirm() {
    final reason = _reason.text.trim();
    Navigator.of(context).pop(OrderCancellation(
      orderId: widget.order.id,
      reason: reason.isEmpty ? null : reason,
    ));
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return SafeArea(
      top: false,
      child: Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(CosechaSpace.md),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(l10n.ordersCancelTitle, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: CosechaSpace.xs),
              Text(l10n.ordersCancelDescription),
              const SizedBox(height: CosechaSpace.sm),
              Text(l10n.orderReference(widget.order.code)),
              const SizedBox(height: CosechaSpace.md),
              CosechaTextField(
                label: l10n.ordersCancelReasonLabel,
                hint: l10n.ordersCancelReasonHint,
                controller: _reason,
                maxLines: 3,
                textInputAction: TextInputAction.newline,
              ),
              const SizedBox(height: CosechaSpace.md),
              CosechaPrimaryButton(
                label: l10n.ordersConfirmCancellation,
                onPressed: _confirm,
              ),
              const SizedBox(height: CosechaSpace.xs),
              Center(
                child: CosechaTextButton(
                  label: l10n.cancel,
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
