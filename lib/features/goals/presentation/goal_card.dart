import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/large_text.dart';
import 'package:ctrl_spend/features/goals/domain/goal.dart';
import 'package:ctrl_spend/features/goals/domain/goal_calculations.dart';
import 'package:ctrl_spend/features/goals/presentation/goal_style.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/// An active goal on S29: its tile, name, "Travel · by Mar 2027", the
/// percentage, a bar in the goal's colour, and Saved and To go.
class GoalCard extends StatelessWidget {
  const new({
    required this.goal,
    required this.savedMinor,
    required this.currency,
    required this.onTap,
    this.completedOn,
    super.key,
  });

  final Goal goal;
  final int savedMinor;
  final Currency currency;
  final VoidCallback onTap;

  /// "Completed 3 Oct" in place of the type and date, for S29's
  /// completed group.
  final DateTime? completedOn;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final formatter = MoneyFormatter(currency);
    final colour = goalColour(goal.iconKey);
    final tint = context.categoryColors.of(colour);
    final progress = goalProgress(goal, savedMinor);
    final percent = (progress * 100).floor();
    final chip = switch (completedOn) {
      final day? => l10n.goalCompletedOn(
        DateFormat('d MMM', locale).format(day),
      ),
      null => l10n.goalChip(
        l10n.goalTypeOf(goal.iconKey),
        DateFormat('MMM y', locale).format(goal.targetMonth),
      ),
    };
    final saved = formatter.formatCompact(savedMinor);
    final toGo = formatter.formatCompact(toGoMinor(goal, savedMinor));

    Widget figure(String label, String value, {bool end = false}) => Column(
      crossAxisAlignment: end && !largeText(context)
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: text.labelSm.copyWith(color: colors.muted),
        ),
        Text(value, style: text.header.copyWith(color: colors.ink)),
      ],
    );

    return Semantics(
      button: true,
      label: l10n.goalCardLabel(goal.name, chip, percent, saved, toGo),
      excludeSemantics: true,
      child: Material(
        color: colors.surface,
        borderRadius: BorderRadius.circular(AppRadius.r32),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          highlightColor: colors.raised,
          splashFactory: NoSplash.splashFactory,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CategoryTile.forKey(goal.iconKey, color: colour),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            goal.name,
                            style: text.header.copyWith(color: colors.ink),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 2,
                            ),
                            decoration: ShapeDecoration(
                              color: tint.tile,
                              shape: const StadiumBorder(),
                            ),
                            child: Text(
                              chip,
                              style: text.rowTitleSm.copyWith(color: tint.icon),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      l10n.goalPercent(percent),
                      style: text.header.copyWith(color: colors.ink),
                    ),
                  ],
                ),
                const SizedBox(height: 18),
                AppProgressBar(
                  value: progress,
                  color: tint.icon,
                  trackColor: tint.tile,
                  semanticLabel: l10n.goalProgressLabel(
                    percent,
                    formatter.formatCompact(goal.targetMinor),
                  ),
                ),
                const SizedBox(height: 14),
                PairOrStack(
                  children: [
                    figure(l10n.goalSavedLabel, saved),
                    figure(l10n.goalToGoLabel, toGo, end: true),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
