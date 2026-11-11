import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/period/period.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_progress_bar.dart';
import 'package:ctrl_spend/core/widgets/budget_hero.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

final Period period = (
  start: DateTime(2026, 10, 15),
  end: DateTime(2026, 11, 14),
);

Widget hero({
  required int spent,
  int? budget = 200000,
  VoidCallback? onTap,
  VoidCallback? onSetBudget,
}) => SizedBox(
  width: 358,
  child: BudgetHero(
    spentMinor: spent,
    budgetMinor: budget,
    period: period,
    currency: Currency.myr,
    onTap: onTap ?? () {},
    onSetBudget: onSetBudget ?? () {},
  ),
);

/// The colour of the big amount's first span ("RM 1,240").
Color? amountColor(WidgetTester tester, String amount) {
  final text = tester.widget<Text>(
    find.byWidgetPredicate(
      (w) => w is Text && w.textSpan?.toPlainText() == amount,
    ),
  );
  return (text.textSpan! as TextSpan).style!.color;
}

void main() {
  for (final t in themes) {
    group('in ${t.name}', () {
      testWidgets('under 80%: left to spend in white', (tester) async {
        await pumpThemed(tester, t.theme, hero(spent: 76000));
        expect(find.text('LEFT TO SPEND'), findsOneWidget);
        expect(amountColor(tester, 'RM 1,240.00'), AppColors.dark.ink);
        expect(find.text('RM 760 spent'), findsOneWidget);
        expect(find.text('of RM 2,000'), findsOneWidget);
        final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
        expect(bar.value, 0.38);
        expect(bar.color, isNull, reason: 'white on the hero');
        expect(bar.onHero, isTrue);
        final card = tester.widget<Material>(
          find
              .descendant(
                of: find.byType(BudgetHero),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(card.color, t.colors.hero);
      });

      testWidgets('80–99%: amber, the same in both themes', (tester) async {
        await pumpThemed(tester, t.theme, hero(spent: 184000));
        expect(find.text('LEFT TO SPEND'), findsOneWidget);
        expect(amountColor(tester, 'RM 160.00'), AppColors.dark.warning);
        expect(
          tester.widget<AppProgressBar>(find.byType(AppProgressBar)).color,
          AppColors.dark.warning,
        );
      });

      testWidgets('over budget: coral, the excess', (tester) async {
        await pumpThemed(tester, t.theme, hero(spent: 201000));
        expect(find.text('OVER BUDGET BY'), findsOneWidget);
        expect(amountColor(tester, 'RM 10.00'), AppColors.dark.negative);
        expect(find.text('RM 2,010 spent'), findsOneWidget);
        final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
        expect(bar.color, AppColors.dark.negative);
      });

      testWidgets('no budget: spent this period and a link', (tester) async {
        var set = 0;
        await pumpThemed(
          tester,
          t.theme,
          hero(spent: 76000, budget: null, onSetBudget: () => set++),
        );
        expect(find.text('SPENT THIS PERIOD'), findsOneWidget);
        expect(amountColor(tester, 'RM 760.00'), AppColors.dark.ink);
        expect(find.byType(AppProgressBar), findsNothing);
        expect(find.text('15 Oct – 14 Nov'), findsOneWidget);
        await tester.tap(find.text('Set a monthly budget'));
        expect(set, 1);
      });
    });
  }

  testWidgets('the thresholds are exact', (tester) async {
    for (final (spent, label, colour) in [
      (159999, 'LEFT TO SPEND', AppColors.dark.ink),
      (160000, 'LEFT TO SPEND', AppColors.dark.warning),
      (199999, 'LEFT TO SPEND', AppColors.dark.warning),
      (200000, 'OVER BUDGET BY', AppColors.dark.negative),
    ]) {
      await pumpThemed(tester, themes.first.theme, hero(spent: spent));
      expect(find.text(label), findsOneWidget, reason: '$spent');
      final first = tester
          .widgetList<Text>(find.byType(Text))
          .firstWhere(
            (w) => w.textSpan?.toPlainText().startsWith('RM ') ?? false,
          );
      expect(
        (first.textSpan! as TextSpan).style!.color,
        colour,
        reason: '$spent',
      );
    }
  });

  testWidgets('reads the summary and the bar percentage', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpThemed(
      tester,
      themes.first.theme,
      hero(spent: 76000, onTap: () => taps++),
    );
    expect(
      find.bySemanticsLabel(
        'Left to spend RM 1,240.00, RM 760 spent, of RM 2,000',
      ),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel('38% of monthly budget spent'),
      findsOneWidget,
    );
    await tester.tap(find.text('LEFT TO SPEND'));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('fits a narrow phone without overflowing', (tester) async {
    for (final budget in [200000, null]) {
      await pumpThemed(
        tester,
        themes.first.theme,
        SizedBox(
          width: 288,
          child: BudgetHero(
            spentMinor: 123456789,
            budgetMinor: budget,
            period: period,
            currency: Currency.myr,
            onTap: () {},
            onSetBudget: () {},
          ),
        ),
      );
      expect(tester.takeException(), isNull, reason: '$budget');
    }
  });
}
