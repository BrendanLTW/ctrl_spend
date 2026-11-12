import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/period_format.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_rules.dart';
import 'package:ctrl_spend/l10n/app_localizations.dart';

typedef NotificationText = ({String title, String body});

/// The inbox wording for [event] (PRD §5.4), e.g. "Food is at 82% of its
/// limit" / "RM 72 left with 10 days to go.".
NotificationText notificationText(
  NotificationEvent event,
  AppLocalizations l10n,
  MoneyFormatter formatter,
  String locale,
) {
  String money(int minor) => formatter.formatCompact(minor);
  return switch (event) {
    BudgetWarning(:final category, :final percent) => (
      title: category == null
          ? l10n.notifyBudgetWarningTitle(percent)
          : l10n.notifyCategoryWarningTitle(category, percent),
      body: l10n.notifyWarningBody(money(event.leftMinor), event.daysLeft),
    ),
    OverBudget(:final category, :final spentMinor, :final limitMinor) =>
      category == null
          ? (
              title: l10n.notifyBudgetOverTitle,
              body: l10n.notifyBudgetOverBody(
                money(spentMinor),
                money(limitMinor),
              ),
            )
          : (
              title: l10n.notifyCategoryOverTitle(category),
              body: l10n.notifyCategoryOverBody(
                money(spentMinor),
                money(limitMinor),
              ),
            ),
    IncomeRecorded() => (
      title: l10n.notifyIncomeTitle(event.category),
      body: l10n.notifyIncomeBody(
        formatter.format(event.amountMinor, sign: MoneySign.income),
        event.title,
      ),
    ),
    DailyReminder() => (
      title: l10n.notifyDailyTitle,
      body: l10n.notifyDailyBody,
    ),
    WeeklySummary(:final lastWeekMinor, :final weekBeforeMinor) => (
      title: l10n.notifyWeeklyTitle,
      body: switch (lastWeekMinor - weekBeforeMinor) {
        0 => l10n.notifyWeeklySame(money(lastWeekMinor)),
        final d when d < 0 => l10n.notifyWeeklyLess(
          money(lastWeekMinor),
          money(-d),
        ),
        final d => l10n.notifyWeeklyMore(money(lastWeekMinor), money(d)),
      },
    ),
    PeriodStarted(:final budgetMinor) => (
      title: l10n.notifyPeriodTitle,
      body: budgetMinor == null
          ? l10n.notifyPeriodBody(formatPeriod(event.period, locale))
          : l10n.notifyPeriodBudgetBody(money(budgetMinor)),
    ),
  };
}
