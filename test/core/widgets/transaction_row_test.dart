import 'package:ctrl_spend/core/money/money_formatter.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/transaction_row.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/features/transactions/domain/transaction.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

const String minus = MoneyFormatter.minus;

TransactionRow row({
  TransactionType type = TransactionType.expense,
  int amountMinor = 1250,
  bool compact = false,
  VoidCallback? onTap,
}) => TransactionRow(
  tile: CategoryTile.forKey(
    CategoryIconKey.food,
    color: CategoryColorKey.orange,
    size: compact ? CategoryTileSize.compact : CategoryTileSize.regular,
  ),
  title: 'Nasi lemak',
  caption: 'Today · Food',
  amountMinor: amountMinor,
  type: type,
  currency: Currency.myr,
  compact: compact,
  onTap: onTap,
);

void main() {
  for (final t in themes) {
    testWidgets('an expense is negative with a minus in ${t.name}', (
      tester,
    ) async {
      await pumpThemed(tester, t.theme, row());
      final amount = tester.widget<Text>(find.text('${minus}RM 12.50'));
      expect(amount.style!.color, t.colors.negative);
      expect(find.text('Nasi lemak'), findsOneWidget);
      expect(find.text('Today · Food'), findsOneWidget);
      final card = tester.widget<Material>(
        find.descendant(
          of: find.byType(TransactionRow),
          matching: find.byType(Material),
        ),
      );
      expect(card.color, t.colors.surface);
    });

    testWidgets('income is positive with a plus in ${t.name}', (tester) async {
      await pumpThemed(
        tester,
        t.theme,
        row(type: TransactionType.income, amountMinor: 480000),
      );
      final amount = tester.widget<Text>(find.text('+RM 4,800.00'));
      expect(amount.style!.color, t.colors.positive);
    });
  }

  testWidgets('is 72 high, and denser when compact', (tester) async {
    await pumpThemed(tester, themes.first.theme, row());
    expect(tester.getSize(find.byType(TransactionRow)).height, 72);
    await pumpThemed(tester, themes.first.theme, row(compact: true));
    expect(tester.getSize(find.byType(TransactionRow)).height, lessThan(72));
  });

  testWidgets('reads as one button and reports taps', (tester) async {
    final handle = tester.ensureSemantics();
    var taps = 0;
    await pumpThemed(tester, themes.first.theme, row(onTap: () => taps++));
    expect(
      tester.getSemantics(find.byType(TransactionRow)),
      isSemantics(
        label: 'Nasi lemak, Today · Food, ${minus}RM 12.50',
        isButton: true,
      ),
    );
    await tester.tap(find.byType(TransactionRow));
    expect(taps, 1);
    handle.dispose();
  });

  testWidgets('a long title ellipsizes instead of overflowing', (tester) async {
    await pumpThemed(
      tester,
      themes.first.theme,
      SizedBox(
        width: 280,
        child: TransactionRow(
          tile: CategoryTile.forKey(
            CategoryIconKey.food,
            color: CategoryColorKey.orange,
          ),
          title: 'A very long transaction title that keeps going and going',
          caption: 'Today · Food',
          amountMinor: 1250,
          type: TransactionType.expense,
          currency: Currency.myr,
        ),
      ),
    );
    expect(tester.takeException(), isNull);
  });
}
