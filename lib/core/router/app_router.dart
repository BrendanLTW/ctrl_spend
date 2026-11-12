import 'package:ctrl_spend/core/widgets/app_shell.dart';
import 'package:ctrl_spend/features/activity/presentation/activity_screen.dart';
import 'package:ctrl_spend/features/budgets/presentation/budgets_screen.dart';
import 'package:ctrl_spend/features/categories/presentation/category_detail_screen.dart';
import 'package:ctrl_spend/features/categories/presentation/category_manager_screen.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/data_transfer/presentation/export_screen.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_screen.dart';
import 'package:ctrl_spend/features/notifications/presentation/notifications_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/all_set_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/budget_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/category_limits_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/how_it_works_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/month_setup_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/name_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrl_spend/features/onboarding/presentation/reminders_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/splash_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_screen.dart';
import 'package:ctrl_spend/features/periods/presentation/past_periods_screen.dart';
import 'package:ctrl_spend/features/periods/presentation/period_detail_screen.dart';
import 'package:ctrl_spend/features/settings/presentation/currency_screen.dart';
import 'package:ctrl_spend/features/settings/presentation/month_start_screen.dart';
import 'package:ctrl_spend/features/settings/presentation/settings_screen.dart';
import 'package:ctrl_spend/features/settings/presentation/theme_screen.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:ctrl_spend/features/transactions/presentation/add_transaction_screen.dart';
import 'package:ctrl_spend/features/transactions/presentation/transaction_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home = '/home';
  static const activity = '/activity';
  static const budgets = '/budgets';
  static const insights = '/insights';

  /// S12; add `?type=income` for New income.
  static const add = '/add';

  /// S41 Transaction.
  static String transaction(int id) => '/transactions/$id';

  /// S13 Edit transaction.
  static String editTransaction(int id) => '/transactions/$id/edit';
  static const settings = '/settings';

  /// S32; under onboarding it's [onboardingMonthStart] (S04's Other).
  static const monthStart = '/settings/month-start';

  /// S33 Theme.
  static const theme = '/settings/theme';

  /// S34; under onboarding it's [onboardingCurrency] (S04's currency row).
  static const currency = '/settings/currency';

  /// S35 Export data.
  static const export = '/settings/export';

  /// S22 Category manager.
  static const categories = '/settings/categories';

  /// S23 Category detail.
  static String category(int id) => '/settings/categories/$id';

  /// S14 Notifications.
  static const notifications = '/notifications';

  /// S25 Past periods.
  static const pastPeriods = '/periods';

  /// S26 for the period starting on [start].
  static String period(DateTime start) =>
      '/periods/${start.year}-${_two(start.month)}-${_two(start.day)}';
  static String _two(int n) => n.toString().padLeft(2, '0');
  static const splash = '/splash';

  /// S02 Welcome; the other steps sit under it.
  static const onboarding = '/onboarding';
  static const onboardingHow = '/onboarding/how';
  static const onboardingName = '/onboarding/name';
  static const onboardingMonth = '/onboarding/month';
  static const onboardingMonthStart = '/onboarding/month-start';
  static const onboardingCurrency = '/onboarding/currency';
  static const onboardingBudget = '/onboarding/budget';
  static const onboardingCategories = '/onboarding/categories';
  static const onboardingReminders = '/onboarding/reminders';
  static const onboardingDone = '/onboarding/done';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Feeds the redirect without rebuilding the router, so the nav stack
  // survives when onboarding completes. Null until settings load.
  final onboarded = ValueNotifier<bool?>(ref.read(onboardingCompleteProvider));
  ref
    ..listen(onboardingCompleteProvider, (_, next) => onboarded.value = next)
    ..onDispose(onboarded.dispose);

  final router = GoRouter(
    initialLocation: Routes.splash,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final location = state.matchedLocation;
      // The splash screen moves on by itself once settings have loaded.
      if (location == Routes.splash) return null;
      final done = onboarded.value;
      if (done == null) return Routes.splash;
      final inOnboarding = location.startsWith(Routes.onboarding);
      if (!done) return inOnboarding ? null : Routes.onboarding;
      return inOnboarding ? Routes.home : null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(
          currentIndex: shell.currentIndex,
          // Tapping the active tab pops it back to its root.
          onTabSelected: (i) =>
              shell.goBranch(i, initialLocation: i == shell.currentIndex),
          onAdd: () => context.push(Routes.add),
          child: shell,
        ),
        branches: [
          _branch(Routes.home, const DashboardScreen()),
          _branch(Routes.activity, const ActivityScreen()),
          _branch(Routes.budgets, const BudgetsScreen()),
          _branch(Routes.insights, const InsightsScreen()),
        ],
      ),
      GoRoute(
        path: Routes.add,
        builder: (context, state) => AddTransactionScreen(
          initialType: state.uri.queryParameters['type'] == 'income'
              ? TransactionType.income
              : TransactionType.expense,
        ),
      ),
      GoRoute(
        path: '/transactions/:id',
        builder: (context, state) => TransactionDetailScreen(
          transactionId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: '/transactions/:id/edit',
        builder: (context, state) => AddTransactionScreen(
          transactionId: int.tryParse(state.pathParameters['id'] ?? ''),
        ),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.export,
        builder: (context, state) => const ExportScreen(),
      ),
      GoRoute(
        path: Routes.theme,
        builder: (context, state) => const ThemeScreen(),
      ),
      GoRoute(
        path: Routes.currency,
        builder: (context, state) => const CurrencyScreen(),
      ),
      GoRoute(
        path: Routes.categories,
        builder: (context, state) => const CategoryManagerScreen(),
      ),
      GoRoute(
        path: '/settings/categories/:id',
        builder: (context, state) => CategoryDetailScreen(
          categoryId: int.tryParse(state.pathParameters['id'] ?? '') ?? 0,
        ),
      ),
      GoRoute(
        path: Routes.notifications,
        builder: (context, state) => const NotificationsScreen(),
      ),
      GoRoute(
        path: Routes.pastPeriods,
        builder: (context, state) => const PastPeriodsScreen(),
      ),
      GoRoute(
        path: '/periods/:start',
        builder: (context, state) => PeriodDetailScreen(
          // A local date; a bad one falls back to today's period.
          date:
              DateTime.tryParse(state.pathParameters['start'] ?? '') ??
              DateTime.now(),
        ),
      ),
      GoRoute(
        path: Routes.monthStart,
        builder: (context, state) => const MonthStartScreen(),
      ),
      GoRoute(
        path: Routes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const WelcomeScreen(),
        routes: [
          GoRoute(
            path: 'how',
            builder: (context, state) => const HowItWorksScreen(),
          ),
          GoRoute(
            path: 'name',
            builder: (context, state) => const NameScreen(),
          ),
          GoRoute(
            path: 'month',
            builder: (context, state) => const MonthSetupScreen(),
          ),
          GoRoute(
            path: 'month-start',
            builder: (context, state) => const MonthStartScreen(),
          ),
          GoRoute(
            path: 'currency',
            builder: (context, state) => const CurrencyScreen(),
          ),
          GoRoute(
            path: 'budget',
            builder: (context, state) => const BudgetScreen(),
          ),
          GoRoute(
            path: 'categories',
            builder: (context, state) => const CategoryLimitsScreen(),
          ),
          GoRoute(
            path: 'reminders',
            builder: (context, state) => const RemindersScreen(),
          ),
          GoRoute(
            path: 'done',
            builder: (context, state) => const AllSetScreen(),
          ),
        ],
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);
