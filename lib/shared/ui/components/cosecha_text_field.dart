import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';

/// Text field with the label ABOVE the field (titleSmall), never floating.
///
/// 56 high, `outline` border, radius 12, `surface` background; moss border on
/// focus. Errors show a pomegranate border plus a warning icon and a
/// bodySmall message below. Validation runs when the form is validated
/// (on Continue/Save), not while typing.
class CosechaTextField extends StatelessWidget {
  const CosechaTextField({
    required this.label,
    required this.controller,
    this.hint,
    this.helper,
    this.validator,
    this.keyboardType,
    this.textInputAction,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.onChanged,
    super.key,
  });

  final String label;
  final TextEditingController controller;
  final String? hint;
  final String? helper;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return FormField<String>(
      initialValue: controller.text,
      // Always validate the controller's current text (it can be changed
      // programmatically, e.g. when a form is reset).
      validator: validator == null ? null : (_) => validator!(controller.text),
      enabled: enabled,
      builder: (field) {
        final error = field.errorText;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: CosechaSpace.xs),
            TextField(
              controller: controller,
              readOnly: readOnly,
              enabled: enabled,
              maxLines: maxLines,
              keyboardType: keyboardType,
              textInputAction: textInputAction,
              style: textTheme.bodyLarge?.copyWith(color: scheme.onSurface),
              onChanged: (value) {
                field.didChange(value);
                // First validation happens on Save; once a field shows an
                // error, it updates while the user corrects it.
                if (field.hasError) field.validate();
                onChanged?.call(value);
              },
              decoration: InputDecoration(
                hintText: hint,
                helperText: error == null ? helper : null,
                error: error == null ? null : CosechaFieldError(error),
              ),
            ),
          ],
        );
      },
    );
  }
}

/// Field error: warning icon + bodySmall message in pomegranate.
class CosechaFieldError extends StatelessWidget {
  const CosechaFieldError(this.message, {super.key});

  final String message;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Row(
      children: [
        Icon(Icons.error_outline, size: 16, color: scheme.error),
        const SizedBox(width: CosechaSpace.xxs),
        Expanded(
          child: Text(
            message,
            style: Theme.of(context)
                .textTheme
                .bodySmall
                ?.copyWith(color: scheme.error),
          ),
        ),
      ],
    );
  }
}

/// Date field with the label above. Looks like [CosechaTextField]; tapping
/// it opens the date picker. Validated with the form.
class CosechaDateField extends StatelessWidget {
  const CosechaDateField({
    required this.label,
    required this.firstDate,
    required this.lastDate,
    this.initialValue,
    this.hint,
    this.validator,
    this.onChanged,
    super.key,
  });

  final String label;
  final DateTime firstDate;
  final DateTime lastDate;
  final DateTime? initialValue;
  final String? hint;
  final String? Function(DateTime?)? validator;
  final ValueChanged<DateTime>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final textTheme = theme.textTheme;
    final localizations = MaterialLocalizations.of(context);

    return FormField<DateTime>(
      initialValue: initialValue,
      validator: validator,
      builder: (field) {
        final value = field.value;
        final error = field.errorText;

        Future<void> pick() async {
          final now = DateTime.now();
          final suggested = value ?? now.add(const Duration(days: 1));
          final picked = await showDatePicker(
            context: context,
            initialDate: suggested.isBefore(firstDate)
                ? firstDate
                : (suggested.isAfter(lastDate) ? lastDate : suggested),
            firstDate: firstDate,
            lastDate: lastDate,
          );
          if (picked == null || !field.mounted) return;
          field.didChange(picked);
          if (field.hasError) field.validate();
          onChanged?.call(picked);
        }

        final display = value == null ? null : localizations.formatMediumDate(value);
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: textTheme.titleSmall?.copyWith(color: scheme.onSurface),
            ),
            const SizedBox(height: CosechaSpace.xs),
            Semantics(
              button: true,
              label: label,
              value: display,
              excludeSemantics: true,
              child: InkWell(
                onTap: pick,
                borderRadius: CosechaRadius.buttonAll,
                child: InputDecorator(
                  isEmpty: value == null,
                  decoration: InputDecoration(
                    hintText: hint,
                    suffixIcon: const Icon(Icons.calendar_month_outlined),
                    error: error == null ? null : CosechaFieldError(error),
                  ),
                  child: Text(
                    display ?? '',
                    style: textTheme.bodyLarge
                        ?.copyWith(color: scheme.onSurface),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
