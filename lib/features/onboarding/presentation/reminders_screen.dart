import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/brand_colors.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/brand_symbol.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S07 Stay on track (step 5 of 5): a sample notification and the three
/// reminder toggles, saved as they're flipped. Both buttons go on to S08.
class RemindersScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final locale = Localizations.localeOf(context).toLanguageTag();
    void save(Preferences Function(Preferences) change) =>
        ref.read(preferencesRepositoryProvider).update(change);
    void next() => context.push(Routes.onboardingDone);

    return OnboardingScaffold(
      step: 5,
      title: l10n.remindersTitle,
      subtitle: l10n.remindersSubtitle,
      primaryLabel: l10n.turnOnNotifications,
      // Moves on whatever the answer; the toggles stay as set.
      onPrimary: () async {
        await ref.read(notificationServiceProvider).requestPermission();
        if (context.mounted) next();
      },
      secondaryLabel: l10n.notNow,
      onSecondary: next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SampleNotification(),
          const SizedBox(height: 28),
          SectionLabel(l10n.notifyMeAbout),
          _ToggleGroup(
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
          ),
        ],
      ),
    );
  }
}

/// An example of the daily reminder; decorative, so screen readers skip it.
class _SampleNotification extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r24),
          boxShadow: context.shadows.bottomBar,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: BrandColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              alignment: Alignment.center,
              child: const BrandSymbol(size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.appName,
                          style: text.rowTitleSm.copyWith(color: colors.ink),
                        ),
                      ),
                      Text(
                        l10n.notificationNow,
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.sampleNotification,
                    style: text.body.copyWith(color: colors.ink),
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
