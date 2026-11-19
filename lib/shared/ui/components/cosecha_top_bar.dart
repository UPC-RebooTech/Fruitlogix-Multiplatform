import 'package:flutter/material.dart';

import '../theme/cosecha_status_colors.dart';
import '../theme/cosecha_tokens.dart';
import 'cosecha_surface.dart';

/// Main top bar: deep forest, 36 lime avatar, white title (titleMedium) and
/// an uppercase subtitle (labelSmall) in secondary on-dark text.
///
/// With [onBack] (sections opened from "More") the avatar is replaced by a
/// back button.
class CosechaTopBar extends StatelessWidget implements PreferredSizeWidget {
  const CosechaTopBar({
    required this.title,
    required this.initials,
    this.subtitle,
    this.onAvatarTap,
    this.avatarTooltip,
    this.onBack,
    this.actions,
    super.key,
  });

  final String title;
  final String? subtitle;
  final String initials;
  final VoidCallback? onAvatarTap;
  final String? avatarTooltip;
  final VoidCallback? onBack;
  final List<Widget>? actions;

  static const double height = 64;

  @override
  Size get preferredSize => const Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final status = CosechaStatusColors.of(context);
    return CosechaSurface(
      onDark: true,
      child: AppBar(
        automaticallyImplyLeading: false,
        toolbarHeight: height,
        titleSpacing: CosechaSpace.xs,
        actions: actions,
        title: Row(
          children: [
            if (onBack != null)
              IconButton(
                onPressed: onBack,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                icon: const BackButtonIcon(),
                color: status.onDarkPrimary,
              )
            else
              CosechaAvatar(
                initials: initials,
                onTap: onAvatarTap,
                tooltip: avatarTooltip,
              ),
            const SizedBox(width: CosechaSpace.xxs),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.titleMedium
                        ?.copyWith(color: status.onDarkPrimary),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.labelSmall
                          ?.copyWith(color: status.onDarkSecondary),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Circular lime avatar (36) with initials, inside a 48 touch target.
class CosechaAvatar extends StatelessWidget {
  const CosechaAvatar({
    required this.initials,
    this.onTap,
    this.tooltip,
    super.key,
  });

  final String initials;
  final VoidCallback? onTap;
  final String? tooltip;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    Widget avatar = SizedBox.square(
      dimension: CosechaSize.minTouch,
      child: Center(
        child: Container(
          width: CosechaSize.topBarAvatar,
          height: CosechaSize.topBarAvatar,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: scheme.primaryContainer,
            shape: BoxShape.circle,
          ),
          child: Text(
            initials,
            style: Theme.of(context)
                .textTheme
                .labelLarge
                ?.copyWith(color: scheme.onPrimaryContainer, height: 1),
          ),
        ),
      ),
    );
    if (onTap != null) {
      avatar = InkResponse(
        onTap: onTap,
        radius: CosechaSize.minTouch / 2,
        child: avatar,
      );
    }
    avatar = Semantics(
      button: onTap != null,
      label: tooltip,
      excludeSemantics: true,
      child: avatar,
    );
    return tooltip == null ? avatar : Tooltip(message: tooltip, child: avatar);
  }
}

/// Scaffold for pushed sub-screens: deep forest top bar with the back button
/// and the title in titleLarge.
class CosechaSubpageScaffold extends StatelessWidget {
  const CosechaSubpageScaffold({
    required this.title,
    required this.body,
    this.actions,
    super.key,
  });

  final String title;
  final Widget body;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    final status = CosechaStatusColors.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        titleTextStyle: Theme.of(context)
            .textTheme
            .titleLarge
            ?.copyWith(color: status.onDarkPrimary),
        actions: actions,
      ),
      body: body,
    );
  }
}
