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
                onChanged?.call(value);
              },
              decoration: InputDecoration(
                hintText: hint,
                helperText: error == null ? helper : null,
                error: error == null
                    ? null
                    : Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 16,
                            color: scheme.error,
                          ),
                          const SizedBox(width: CosechaSpace.xxs),
                          Expanded(
                            child: Text(
                              error,
                              style: textTheme.bodySmall
                                  ?.copyWith(color: scheme.error),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
