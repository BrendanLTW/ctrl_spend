import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/clock.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/category_palette.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/categories/domain/category.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/categories/domain/category_repository.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:ctrl_spend/l10n/setting_labels.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

/// S08 You're all set: a summary of the setup. Either button finishes
/// onboarding; Add your first expense opens S12 over Home.
class AllSetScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toLanguageTag();
    final prefs = ref.watch(preferencesProvider).value ?? const Preferences();
    final expense =
        ref
            .watch(
              categoriesProvider(
                type: TransactionType.expense,
                archived: false,
              ),
            )
            .value ??
        const <Category>[];
    final currency = Currency.fromCode(prefs.currencyCode);
    final period = periodFor(ref.watch(clockProvider)(), prefs.monthStartDay);
    final tick = context.categoryColors.of(CategoryColorKey.green);

    Future<void> finish({required bool addExpense}) async {
      // Saving makes the router redirect to Home and drop this screen, so
      // keep the router rather than this context.
      final router = GoRouter.of(context);
      await ref
          .read(preferencesRepositoryProvider)
          .update((p) => p.copyWith(onboardingComplete: true));
      router.go(Routes.home);
      if (addExpense) await router.push(Routes.add);
    }

    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  64,
                  AppSpacing.screenX,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: ExcludeSemantics(
                        child: Container(
                          width: 96,
                          height: 96,
                          decoration: BoxDecoration(
                            color: tick.tile,
                            shape: BoxShape.circle,
                          ),
                          child: AppIconView(
                            AppIcon.check,
                            size: 44,
                            color: tick.icon,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Semantics(
                      header: true,
                      child: Text(
                        l10n.allSetTitle,
                        textAlign: TextAlign.center,
                        style: text.pageTitle.copyWith(color: colors.ink),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: Text(
                        l10n.allSetBody(
                          DateFormat('d MMM', locale).format(period.start),
                        ),
                        textAlign: TextAlign.center,
                        style: text.body.copyWith(color: colors.muted),
                      ),
                    ),
                    const SizedBox(height: 32),
                    SectionLabel(l10n.yourSetup),
                    ListGroup(
                      children: [
                        KeyValueRow(
                          label: l10n.monthlyBudget,
                          value: switch (prefs.monthlyBudgetMinor) {
                            final budget? => MoneyFormatter(
                              currency,
                            ).formatCompact(budget),
                            null => l10n.notSet,
                          },
                        ),
                        KeyValueRow(
                          label: l10n.monthStartsOn,
                          value: l10n.startDayLabel(prefs.monthStartDay),
                        ),
                        KeyValueRow(
                          label: l10n.categoryLimits,
                          value: l10n.limitsCount(
                            expense.where((c) => c.limitMinor != null).length,
                            expense.length,
                          ),
                        ),
                        KeyValueRow(
                          label: l10n.reminders,
                          value: _remindersSummary(l10n, prefs, locale),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                12,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: l10n.addFirstExpense,
                    onPressed: () => finish(addExpense: true),
                  ),
                  const SizedBox(height: 8),
                  TextLink(
                    label: l10n.goToDashboard,
                    onPressed: () => finish(addExpense: false),
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

/// The most noticeable reminder that's on: daily, then weekly, then
/// budget alerts.
String _remindersSummary(
  AppLocalizations l10n,
  Preferences prefs,
  String locale,
) {
  if (prefs.dailyReminderOn) {
    return l10n.remindersDaily(
      l10n.reminderTime(prefs.dailyReminderMinutes, locale),
    );
  }
  if (prefs.weeklySummaryOn) return l10n.remindersWeekly;
  if (prefs.budgetAlertsOn) return l10n.remindersAlertsOnly;
  return l10n.remindersOff;
}
