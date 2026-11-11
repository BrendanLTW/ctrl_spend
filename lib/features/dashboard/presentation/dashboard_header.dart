import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// S09's header: the period and greeting, the bell and the avatar.
class DashboardHeader extends StatelessWidget {
  const new({
    required this.periodLabel,
    required this.name,
    required this.onBell,
    required this.onAvatar,
    super.key,
  });

  /// "15 Oct – 14 Nov"; shown uppercase.
  final String periodLabel;
  final String name;
  final VoidCallback onBell;
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
        // shortcut: no unread badge until the inbox (task 3.9).
        IconButton(
          onPressed: onBell,
          tooltip: l10n.notifications,
          style: IconButton.styleFrom(
            fixedSize: const Size(48, 48),
            backgroundColor: colors.raised,
            foregroundColor: colors.ink,
          ),
          icon: const Icon(Icons.notifications_none_rounded, size: 22),
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
              ? const Icon(Icons.person_outline_rounded, size: 22)
              : Text(
                  trimmed.characters.first.toUpperCase(),
                  style: text.header.copyWith(color: colors.onInk),
                ),
        ),
      ],
    );
  }
}
