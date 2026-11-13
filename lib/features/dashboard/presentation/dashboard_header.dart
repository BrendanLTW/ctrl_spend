import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S09's header: the period and greeting, the bell and the avatar.
class DashboardHeader extends StatelessWidget {
  const new({
    required this.periodLabel,
    required this.name,
    required this.onBell,
    required this.onAvatar,
    this.unreadCount = 0,
    super.key,
  });

  /// "15 Oct – 14 Nov"; shown uppercase.
  final String periodLabel;
  final String name;
  final VoidCallback onBell;

  /// Shows a red dot on the bell when above 0 (S09).
  final int unreadCount;
  final VoidCallback onAvatar;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final trimmed = name.trim();
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                periodLabel.toUpperCase(),
                style: text.label.copyWith(color: colors.muted),
              ),
              const SizedBox(height: 2),
              Semantics(
                header: true,
                child: Text(
                  trimmed.isEmpty
                      ? l10n.greetingNoName
                      : l10n.greeting(trimmed),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: text.pageTitle.copyWith(color: colors.ink),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Semantics(
          container: true,
          label: l10n.notificationsUnread(unreadCount),
          button: true,
          excludeSemantics: true,
          child: Stack(
            children: [
              IconButton(
                onPressed: onBell,
                tooltip: l10n.notifications,
                style: IconButton.styleFrom(
                  fixedSize: const Size(48, 48),
                  backgroundColor: colors.raised,
                  foregroundColor: colors.ink,
                ),
                icon: const AppIconView(AppIcon.bell, size: 22),
              ),
              if (unreadCount > 0)
                Positioned(
                  top: 12,
                  right: 13,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: colors.negative,
                      shape: BoxShape.circle,
                      border: Border.all(color: colors.raised, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        IconButton(
          onPressed: onAvatar,
          tooltip: l10n.settings,
          style: IconButton.styleFrom(
            fixedSize: const Size(48, 48),
            backgroundColor: colors.ink,
            foregroundColor: colors.onInk,
          ),
          icon: trimmed.isEmpty
              ? const AppIconView(AppIcon.user, size: 22)
              : Text(
                  trimmed.characters.first.toUpperCase(),
                  style: text.header.copyWith(color: colors.onInk),
                ),
        ),
      ],
    );
  }
}
