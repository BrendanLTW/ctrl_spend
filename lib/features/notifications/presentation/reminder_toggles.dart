import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily reminder, Budget alerts and Weekly summary as toggles that save
/// straight away (S07). Scheduling follows the
/// saved settings.
class ReminderToggles extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final locale = Localizations.localeOf(context).toLanguageTag();
    void save(Preferences Function(Preferences) change) =>
        ref.read(preferencesRepositoryProvider).update(change);
    return ListGroup(
      children: [
        ToggleRow(
          title: l10n.dailyReminder,
          detail: l10n.dailyReminderAt(
            l10n.reminderTime(prefs.dailyReminderMinutes, locale),
          ),
          value: prefs.dailyReminderOn,
          onChanged: (on) => save((p) => p.copyWith(dailyReminderOn: on)),
        ),
        ToggleRow(
          title: l10n.budgetAlerts,
          detail: l10n.budgetAlertsDetail,
          value: prefs.budgetAlertsOn,
          onChanged: (on) => save((p) => p.copyWith(budgetAlertsOn: on)),
        ),
        ToggleRow(
          title: l10n.weeklySummary,
          detail: l10n.weeklySummaryDetail,
          value: prefs.weeklySummaryOn,
          onChanged: (on) => save((p) => p.copyWith(weeklySummaryOn: on)),
        ),
      ],
    );
  }
}

/// A [ListGroup] row of title, detail and a toggle (S07, S48). Tapping
/// anywhere on the row flips it.
class ToggleRow extends StatelessWidget {
  const new({
    required this.title,
    required this.detail,
    required this.value,
    required this.onChanged,
    super.key,
  });

  final String title;
  final String detail;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    // Read as one toggle.
    return MergeSemantics(
      child: InkWell(
        onTap: () => onChanged(!value),
        highlightColor: colors.raised,
        splashFactory: NoSplash.splashFactory,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 14, 12),
          child: Row(
            children: [
              Expanded(
                // The toggle carries the label, so it's read once.
                child: ExcludeSemantics(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: text.rowTitle.copyWith(color: colors.ink),
                      ),
                      Text(
                        detail,
                        style: text.body.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 12),
              AppToggle(
                value: value,
                onChanged: onChanged,
                semanticLabel: '$title, $detail',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
