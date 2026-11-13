import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import 'cosecha_buttons.dart';
import 'cosecha_surface.dart';

/// Confirmation dialog: forest background, radius 28, white title and
/// secondary message. Confirm is a lime pill, or red when [destructive].
/// Cancel is a text button. Returns true when confirmed.
Future<bool> showCosechaConfirmDialog({
  required BuildContext context,
  required String title,
  required String message,
  required String confirmLabel,
  required String cancelLabel,
  bool destructive = false,
}) async {
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (dialogContext) {
      final scheme = Theme.of(dialogContext).colorScheme;
      final status = CosechaStatusColors.of(dialogContext);
      return CosechaSurface(
        onDark: true,
        child: AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: [
            CosechaTextButton(
              label: cancelLabel,
              onPressed: () => Navigator.of(dialogContext).pop(false),
            ),
            FilledButton(
              style: destructive
                  ? FilledButton.styleFrom(
                      backgroundColor: status.critical.onDark,
                      foregroundColor: scheme.onSurface,
                    )
                  : null,
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: Text(confirmLabel),
            ),
          ],
        ),
      );
    },
  );
  return confirmed ?? false;
}
