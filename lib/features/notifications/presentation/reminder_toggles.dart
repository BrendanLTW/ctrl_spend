import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Daily reminder, Budget alerts and Weekly summary as toggles that save
/// straight away (S07, notification settings). Scheduling follows the
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
    return _ToggleGroup(
      rows: [
        (
          title: l10n.dailyReminder,
          detail: l10n.dailyReminderAt(
            l10n.reminderTime(prefs.dailyReminderMinutes, locale),
          ),
          value: prefs.dailyReminderOn,
          onChanged: (on) => save((p) => p.copyWith(dailyReminderOn: on)),
        ),
        (
          title: l10n.budgetAlerts,
          detail: l10n.budgetAlertsDetail,
          value: prefs.budgetAlertsOn,
          onChanged: (on) => save((p) => p.copyWith(budgetAlertsOn: on)),
        ),
        (
          title: l10n.weeklySummary,
          detail: l10n.weeklySummaryDetail,
          value: prefs.weeklySummaryOn,
          onChanged: (on) => save((p) => p.copyWith(weeklySummaryOn: on)),
        ),
      ],
    );
  }
}

typedef _ToggleRow = ({
  String title,
  String detail,
  bool value,
  ValueChanged<bool> onChanged,
});

/// Rows of title, detail and a toggle, in a list-group card.
class _ToggleGroup extends StatelessWidget {
  const new({required this.rows});

  final List<_ToggleRow> rows;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    return Material(
      color: colors.surface,
      borderRadius: BorderRadius.circular(AppRadius.r28),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (final (i, row) in rows.indexed) ...[
            if (i > 0) Divider(height: 1, thickness: 1, color: colors.divider),
            // Tapping anywhere on the row flips it; read as one toggle.
            MergeSemantics(
              child: InkWell(
                onTap: () => row.onChanged(!row.value),
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
                                row.title,
                                style: text.rowTitle.copyWith(
                                  color: colors.ink,
                                ),
                              ),
                              Text(
                                row.detail,
                                style: text.body.copyWith(color: colors.muted),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      AppToggle(
                        value: row.value,
                        onChanged: row.onChanged,
                        semanticLabel: '${row.title}, ${row.detail}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
