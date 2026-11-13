// The screens of v1.0 with sample data, driven into place for the
// accessibility tests (task 4.1).
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/features/settings/domain/preferences.dart';
import 'package:flutter_test/flutter_test.dart';

import '../features/activity/presentation/activity_screen_test.dart' as act;
import '../features/budgets/presentation/budgets_screen_test.dart' as bud;
import '../features/categories/presentation/category_detail_screen_test.dart'
    as cdet;
import '../features/categories/presentation/category_manager_screen_test.dart'
    as cat;
import '../features/dashboard/presentation/dashboard_screen_test.dart' as dash;
import '../features/data_transfer/presentation/export_screen_test.dart' as exp;
import '../features/data_transfer/presentation/import_test.dart' as imp;
import '../features/insights/presentation/insights_screen_test.dart' as ins;
import '../features/insights/presentation/insights_trend_test.dart' as trend;
import '../features/insights/presentation/insights_week_test.dart' as week;
import '../features/notifications/presentation/notification_service_test.dart'
    as nsvc;
import '../features/notifications/presentation/notifications_screen_test.dart'
    as inbox;
import '../features/onboarding/presentation/budget_and_limits_test.dart' as bl;
import '../features/onboarding/presentation/name_and_month_test.dart' as nm;
import '../features/onboarding/presentation/reminders_and_done_test.dart' as rd;
import '../features/periods/presentation/past_periods_test.dart' as per;
import '../features/settings/presentation/settings_screen_test.dart' as stg;
import '../features/transactions/presentation/add_transaction_screen_test.dart'
    as add;
import '../features/transactions/presentation/transaction_detail_screen_test.dart'
    as det;

Preferences p(AppTheme t, {bool onboarded = true}) => Preferences(
  userName: 'Alex',
  theme: t,
  onboardingComplete: onboarded,
  monthStartDay: const DayOfMonth(15),
  monthlyBudgetMinor: 200000,
);

typedef Drive = Future<void> Function(WidgetTester, AppTheme);

/// Every v1.0 screen by ID, pumped in the given theme.
final screens = <String, Drive>{
  'S02 welcome': (t, th) =>
      nm.pumpAt(t, Routes.onboarding, initial: Preferences(theme: th)),
  'S03 how': (t, th) =>
      nm.pumpAt(t, Routes.onboardingHow, initial: Preferences(theme: th)),
  'S03a name': (t, th) =>
      nm.pumpAt(t, Routes.onboardingName, initial: Preferences(theme: th)),
  'S04 month': (t, th) =>
      nm.pumpAt(t, Routes.onboardingMonth, initial: Preferences(theme: th)),
  'S05 budget': (t, th) => bl.pumpAt(
    t,
    Routes.onboardingBudget,
    initial: Preferences(theme: th, monthlyBudgetMinor: 200000),
  ),
  'S06 limits': (t, th) => bl.pumpAt(
    t,
    Routes.onboardingCategories,
    initial: Preferences(theme: th, monthlyBudgetMinor: 200000),
    limits: const {'Food': 40000},
  ),
  'S07 reminders': (t, th) => rd.pumpAt(
    t,
    Routes.onboardingReminders,
    initial: Preferences(theme: th, monthlyBudgetMinor: 200000),
  ),
  'S08 done': (t, th) => rd.pumpAt(
    t,
    Routes.onboardingDone,
    initial: Preferences(theme: th, monthlyBudgetMinor: 200000),
  ),
  'S09 dashboard': (t, th) =>
      dash.pumpHome(t, prefs: p(th), seed: dash.seedDesign),
  'S10 first run': (t, th) => dash.pumpHome(t, prefs: p(th)),
  'S12 add': (t, th) => add.pumpAt(t, Routes.add, theme: th),
  'S12 add (keypad closed)': (t, th) async {
    await add.pumpAt(t, Routes.add, theme: th);
    await add.done(t);
  },
  'S41 detail': (t, th) async {
    await det.pumpApp(
      t,
      prefs: p(th),
      seed: () => det.add(1250, 'Nasi lemak', note: 'with egg'),
    );
    await det.openDetail(t);
  },
  'S16 activity': (t, th) =>
      act.pumpActivity(t, theme: th, seed: act.seedDesign),
  'S17 budgets': (t, th) => bud.pumpBudgets(
    t,
    theme: th,
    seed: () async {
      await bud.setLimit('Food', 40000);
      await bud.spend(32800, 'Food');
    },
  ),
  'S18 insights': (t, th) =>
      ins.pumpInsights(t, theme: th, seed: ins.designMonth),
  'S19 week': (t, th) => week.pumpWeek(t, theme: th),
  'S20 trend': (t, th) => trend.pumpTrend(t, theme: th),
  'S14 inbox': (t, th) => nsvc
      .pumpApp(
        t,
        initial: nsvc.onboarded.copyWith(theme: th),
        seed: inbox.seedWithUnread,
      )
      .then((_) => inbox.openInbox(t)),
  'S15 inbox empty': (t, th) => nsvc
      .pumpApp(t, initial: nsvc.onboarded.copyWith(theme: th))
      .then((_) => inbox.openInbox(t)),
  'S21 settings': (t, th) => stg.pumpAt(t, Routes.settings, initial: p(th)),
  'S32 month start': (t, th) =>
      stg.pumpAt(t, Routes.monthStart, initial: p(th)),
  'S33 theme': (t, th) => stg.pumpAt(t, Routes.theme, initial: p(th)),
  'S34 currency': (t, th) => stg.pumpAt(t, Routes.currency, initial: p(th)),
  'S22 categories': (t, th) => cat.pumpManager(t, theme: th),
  'S24 add category': (t, th) =>
      cat.pumpManager(t, theme: th).then((_) => cat.openAdd(t)),
  'S23 category detail': (t, th) => cdet.pumpDetail(t, theme: th),
  'S25 past periods': (t, th) =>
      per.pumpApp(t, location: Routes.pastPeriods, theme: th),
  'S26 period detail': (t, th) =>
      per.pumpApp(t, location: Routes.period(DateTime(2026, 9, 15)), theme: th),
  'S35 export': (t, th) => exp.pumpExport(t, theme: th),
  'S36 import failed': (t, th) async {
    await imp.pumpSettings(t, theme: th);
    await imp.importFile(t, 'bank-export.csv', imp.bad);
  },
};
