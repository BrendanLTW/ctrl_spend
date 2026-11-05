import 'package:ctrl_spend/features/activity/presentation/activity_screen.dart';
import 'package:ctrl_spend/features/budgets/presentation/budgets_screen.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/insights/presentation/insights_screen.dart';
import 'package:ctrl_spend/features/onboarding/presentation/onboarding_controller.dart';
import 'package:ctrl_spend/features/onboarding/presentation/onboarding_screen.dart';
import 'package:ctrl_spend/features/settings/presentation/settings_screen.dart';
import 'package:ctrl_spend/features/transactions/presentation/add_transaction_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'app_router.g.dart';

abstract final class Routes {
  static const home = '/home';
  static const activity = '/activity';
  static const budgets = '/budgets';
  static const insights = '/insights';
  static const add = '/add';
  static const settings = '/settings';
  static const onboarding = '/onboarding';
}

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  // Feeds the redirect without rebuilding the router, so the nav stack
  // survives when onboarding completes.
  final onboarded = ValueNotifier(ref.read(onboardingCompleteProvider));
  ref
    ..listen(onboardingCompleteProvider, (_, next) => onboarded.value = next)
    ..onDispose(onboarded.dispose);

  final router = GoRouter(
    initialLocation: Routes.home,
    refreshListenable: onboarded,
    redirect: (context, state) {
      final atOnboarding = state.matchedLocation == Routes.onboarding;
      if (!onboarded.value) return atOnboarding ? null : Routes.onboarding;
      return atOnboarding ? Routes.home : null;
    },
    routes: [
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => _TempShell(shell: shell),
        branches: [
          _branch(Routes.home, const DashboardScreen()),
          _branch(Routes.activity, const ActivityScreen()),
          _branch(Routes.budgets, const BudgetsScreen()),
          _branch(Routes.insights, const InsightsScreen()),
        ],
      ),
      GoRoute(
        path: Routes.add,
        builder: (context, state) => const AddTransactionScreen(),
      ),
      GoRoute(
        path: Routes.settings,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: Routes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
    ],
  );
  ref.onDispose(router.dispose);
  return router;
}

StatefulShellBranch _branch(String path, Widget screen) => StatefulShellBranch(
  routes: [GoRoute(path: path, builder: (context, state) => screen)],
);

// shortcut: stand-in bottom bar with hard-coded labels; task 0.6 replaces it
// with AppShell and 0.5 moves the strings to ARB.
class _TempShell extends StatelessWidget {
  const new({required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: shell,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add transaction',
        onPressed: () => context.push(Routes.add),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        onDestinationSelected: (i) =>
            shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.list), label: 'Activity'),
          NavigationDestination(
            icon: Icon(Icons.pie_chart_outline),
            label: 'Budgets',
          ),
          NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Insights'),
        ],
      ),
    );
  }
}
