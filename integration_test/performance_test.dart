import 'package:ctrl_spend/core/db/app_database.dart';
import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/features/dashboard/presentation/dashboard_screen.dart';
import 'package:ctrl_spend/features/dev/domain/sample_data.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction_repository.dart';
import 'package:ctrl_spend/main.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import '../test/helpers/fake_notification_scheduler.dart';

/// PRD §10 on a real device: with 5,000 transactions, the dashboard is
/// interactive within 2 s and lists scroll at 60 fps. Run in profile mode
/// on a mid-range Android phone:
///
///   flutter drive --profile --driver=test_driver/integration_test.dart \
///     --target=integration_test/performance_test.dart
///
/// Frame summaries land in build/integration_response_data.json. Cold
/// start from launch is measured separately (docs/quality-audit.md).
void main() {
  final binding = IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// 60 fps leaves 16.7 ms per frame for build and for raster.
  const frameBudgetMs = 16.7;

  void expectSmooth(String key) {
    final summary = binding.reportData![key] as Map<String, dynamic>;
    expect(
      summary['90th_percentile_frame_build_time_millis'] as num,
      lessThan(frameBudgetMs),
      reason: '$key build',
    );
    expect(
      summary['90th_percentile_frame_rasterizer_time_millis'] as num,
      lessThan(frameBudgetMs),
      reason: '$key raster',
    );
  }

  testWidgets('5,000 transactions: start, Activity and Insights', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        ...appOverrides(),
        appDatabaseProvider.overrideWithValue(
          AppDatabase(NativeDatabase.memory()),
        ),
        // No OS notifications from a test run.
        notificationSchedulerProvider.overrideWithValue(
          FakeNotificationScheduler(),
        ),
      ],
    );
    addTearDown(container.dispose);
    await container
        .read(preferencesRepositoryProvider)
        .update(
          (p) => p.copyWith(
            userName: 'Alex',
            onboardingComplete: true,
            monthlyBudgetMinor: 200000,
          ),
        );
    await container
        .read(transactionRepositoryProvider)
        .importAll(sampleTransactions(today: DateTime.now()));

    final start = Stopwatch()..start();
    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const MainApp()),
    );
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);
    binding.reportData = {
      ...?binding.reportData,
      'dashboard_ready_ms': start.elapsedMilliseconds,
    };
    expect(start.elapsedMilliseconds, lessThan(2000));

    final router = container.read(appRouterProvider);
    Future<void> fling(Finder list, {int times = 6}) async {
      for (var i = 0; i < times; i++) {
        await tester.fling(list, const Offset(0, -1500), 4000);
        await tester.pumpAndSettle();
      }
    }

    router.go(Routes.activity);
    await tester.pumpAndSettle();
    await binding.watchPerformance(
      () => fling(find.byType(CustomScrollView)),
      reportKey: 'activity_scroll',
    );
    expectSmooth('activity_scroll');

    router.go(Routes.insights);
    await tester.pumpAndSettle();
    await binding.watchPerformance(() async {
      for (final view in ['Week', '6 months', 'Month']) {
        await tester.tap(find.text(view));
        await tester.pumpAndSettle();
      }
    }, reportKey: 'insights_switch');
    expectSmooth('insights_switch');

    router.go(Routes.settings);
    await tester.pumpAndSettle();
    await binding.watchPerformance(() async {
      await tester.tap(find.text('Categories'));
      await tester.pumpAndSettle();
    }, reportKey: 'open_categories');
    expectSmooth('open_categories');
  });
}
