import 'package:flutter/material.dart';

import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Primary action (lime pill, 56 high). Only one per screen.
///
/// By default it fills the available width; the label shrinks down to 13 sp
/// before wrapping to a second line (max 2 lines).
class CosechaPrimaryButton extends StatelessWidget {
  const CosechaPrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = FilledButton(
      onPressed: onPressed,
      child: _ButtonContent(label: label, icon: icon, adaptive: expand),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Secondary action (radius 12, 56 high). Forest fill with white text on
/// light surfaces; light fill with deep forest text on dark surfaces.
class CosechaSecondaryButton extends StatelessWidget {
  const CosechaSecondaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final button = ElevatedButton(
      onPressed: onPressed,
      style: context.cosechaOnDark
          ? ElevatedButton.styleFrom(
              backgroundColor: scheme.onInverseSurface,
              foregroundColor: scheme.onSurface,
            )
          : null,
      child: _ButtonContent(label: label, icon: icon, adaptive: expand),
    );
    return expand ? SizedBox(width: double.infinity, child: button) : button;
  }
}

/// Text-only action (48 high). Moss on light surfaces, lime on dark ones.
class CosechaTextButton extends StatelessWidget {
  const CosechaTextButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return TextButton(
      onPressed: onPressed,
      style: context.cosechaOnDark
          ? TextButton.styleFrom(foregroundColor: scheme.primaryContainer)
          : null,
      child: _ButtonContent(label: label, icon: icon, adaptive: false),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.icon,
    required this.adaptive,
  });

  final String label;
  final IconData? icon;

  /// Shrink-to-fit label. Only when the button has a bounded width.
  final bool adaptive;

  @override
  Widget build(BuildContext context) {
    final text = adaptive
        ? _AdaptiveLabel(label)
        : Text(
            label,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          );
    if (icon == null) return text;
    return Row(
      mainAxisSize: adaptive ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: CosechaSize.iconSm),
        const SizedBox(width: CosechaSpace.xs),
        adaptive ? Flexible(child: text) : text,
      ],
    );
  }
}

/// Keeps the label on one line by shrinking it from its theme size down to
/// 13 sp; below that, it wraps to two lines at 13 sp.
class _AdaptiveLabel extends StatelessWidget {
  const _AdaptiveLabel(this.label);

  final String label;

  static const double _minFontSize = 13;

  @override
  Widget build(BuildContext context) {
    final base = DefaultTextStyle.of(context).style;
    final scaler = MediaQuery.textScalerOf(context);
    final direction = Directionality.of(context);
    return LayoutBuilder(
      builder: (context, constraints) {
        final baseSize = base.fontSize ?? 16;
        for (var size = baseSize; size >= _minFontSize; size -= 1) {
          final style = base.copyWith(fontSize: size);
          final painter = TextPainter(
            text: TextSpan(text: label, style: style),
            maxLines: 1,
            textDirection: direction,
            textScaler: scaler,
          )..layout(maxWidth: constraints.maxWidth);
          final fits = !painter.didExceedMaxLines;
          painter.dispose();
          if (fits) {
            return Text(label, style: style, maxLines: 1, softWrap: false);
          }
        }
        return Text(
          label,
          style: base.copyWith(fontSize: _minFontSize),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
        );
      },
    );
  }
}
