import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_tokens.dart';

/// One language of [CosechaLanguageButton].
@immutable
class CosechaLanguageOption {
  const CosechaLanguageOption({
    required this.locale,
    required this.code,
    required this.name,
  });

  final Locale locale;

  /// Short code shown in the bar ("EN").
  final String code;

  /// Name in its own language ("English", "Español").
  final String name;
}

/// Language selector for the dark top bar: an outlined pill with the
/// current code ("EN") that opens a menu with the available languages.
class CosechaLanguageButton extends StatelessWidget {
  const CosechaLanguageButton({
    required this.current,
    required this.options,
    required this.onSelected,
    required this.tooltip,
    super.key,
  });

  final Locale current;
  final List<CosechaLanguageOption> options;
  final ValueChanged<Locale> onSelected;
  final String tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final status = CosechaStatusColors.of(context);
    final selected = options.firstWhere(
      (option) => option.locale.languageCode == current.languageCode,
      orElse: () => options.first,
    );

    return PopupMenuButton<Locale>(
      tooltip: tooltip,
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        for (final option in options)
          CheckedPopupMenuItem<Locale>(
            value: option.locale,
            checked: option.locale.languageCode == current.languageCode,
            child: Text(option.name),
          ),
      ],
      child: Semantics(
        button: true,
        label: '$tooltip: ${selected.name}',
        excludeSemantics: true,
        child: SizedBox(
          height: CosechaSize.minTouch,
          child: Center(
            child: Container(
              height: 36,
              padding: const EdgeInsets.symmetric(horizontal: 10),
              decoration: ShapeDecoration(
                shape: StadiumBorder(
                  side: BorderSide(color: status.onDarkSecondary),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.translate,
                    size: CosechaSize.iconSm,
                    color: status.onDarkPrimary,
                  ),
                  const SizedBox(width: CosechaSpace.xxs + 2),
                  Text(
                    selected.code,
                    style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: status.onDarkPrimary,
                          height: 1,
                        ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    size: CosechaSize.iconSm,
                    color: scheme.primaryContainer,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
