import 'package:ctrl_spend/core/widgets/month_calendar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

final today = DateTime(2026, 11, 4, 15, 30);

Widget calendar({
  DateTime? month,
  DateTime? selected,
  DateTime? firstDate,
  DateTime? lastDate,
  ValueChanged<DateTime>? onSelected,
  ValueChanged<DateTime>? onMonthChanged,
}) => SizedBox(
  width: 360,
  child: MonthCalendar(
    month: month ?? DateTime(2026, 11),
    today: today,
    selected: selected,
    firstDate: firstDate,
    lastDate: lastDate,
    onSelected: onSelected ?? (_) {},
    onMonthChanged: onMonthChanged ?? (_) {},
  ),
);

BoxDecoration? dayDecoration(WidgetTester tester, String day) =>
    tester
            .widget<Container>(
              find
                  .ancestor(
                    of: find.text(day),
                    matching: find.byType(Container),
                  )
                  .first,
            )
            .decoration
        as BoxDecoration?;

void main() {
  testWidgets('shows the month name and Monday-first weekdays', (tester) async {
    await pumpThemed(tester, themes.first.theme, calendar());
    expect(find.text('November 2026'), findsOneWidget);
    final initials = tester
        .widgetList<Text>(find.byType(Text))
        .map((t) => t.data)
        .where((d) => d != null && d.length == 1 && !RegExp(r'\d').hasMatch(d))
        .toList();
    expect(initials, ['M', 'T', 'W', 'T', 'F', 'S', 'S']);
  });

  testWidgets('1 Nov 2026 is a Sunday, so it sits in the last column', (
    tester,
  ) async {
    await pumpThemed(tester, themes.first.theme, calendar());
    final sundayColumn = tester.getCenter(find.text('S').last).dx;
    expect(tester.getCenter(find.text('1')).dx, closeTo(sundayColumn, 1));
    final mondayColumn = tester.getCenter(find.text('M')).dx;
    expect(tester.getCenter(find.text('2')).dx, closeTo(mondayColumn, 1));
    expect(find.text('30'), findsOneWidget);
    expect(find.text('31'), findsNothing);
  });

  for (final t in themes) {
    testWidgets('today has a ring, the selected day is ink in ${t.name}', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        t.theme,
        calendar(selected: DateTime(2026, 11, 8)),
      );
      final todayRing = dayDecoration(tester, '4')!.border! as Border;
      expect(todayRing.top.color, t.colors.control);
      expect(todayRing.top.width, 2);
      expect(dayDecoration(tester, '8')!.color, t.colors.ink);
      expect(tester.widget<Text>(find.text('8')).style!.color, t.colors.onInk);
      expect(tester.widget<Text>(find.text('9')).style!.color, t.colors.ink);
    });

    testWidgets('days outside the range are disabled in ${t.name}', (
      tester,
    ) async {
      DateTime? picked;
      await pumpThemed(
        tester,
        t.theme,
        calendar(firstDate: today, onSelected: (d) => picked = d),
      );
      expect(
        tester.widget<Text>(find.text('3')).style!.color,
        t.colors.disabled,
      );
      await tester.tap(find.text('3'));
      expect(picked, isNull);
      await tester.tap(find.text('4'));
      expect(picked, DateTime(2026, 11, 4));
    });
  }

  testWidgets('a future cap disables later days (transaction dates)', (
    tester,
  ) async {
    DateTime? picked;
    await pumpThemed(
      tester,
      themes.first.theme,
      calendar(lastDate: today, onSelected: (d) => picked = d),
    );
    await tester.tap(find.text('5'));
    expect(picked, isNull);
    await tester.tap(find.text('1'));
    expect(picked, DateTime(2026, 11));
  });

  testWidgets('month buttons move across the year end and respect limits', (
    tester,
  ) async {
    final changes = <DateTime>[];
    await pumpThemed(
      tester,
      themes.first.theme,
      calendar(month: DateTime(2026, 12), onMonthChanged: changes.add),
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.tap(find.byTooltip('Previous month'));
    expect(changes, [DateTime(2027), DateTime(2026, 11)]);

    changes.clear();
    await pumpThemed(
      tester,
      themes.first.theme,
      calendar(
        firstDate: DateTime(2026, 11, 10),
        lastDate: DateTime(2026, 11, 20),
        onMonthChanged: changes.add,
      ),
    );
    await tester.tap(find.byTooltip('Next month'));
    await tester.tap(find.byTooltip('Previous month'));
    expect(changes, isEmpty, reason: 'both limits are in this month');
  });

  testWidgets('days read their full date', (tester) async {
    final handle = tester.ensureSemantics();
    await pumpThemed(
      tester,
      themes.first.theme,
      calendar(selected: DateTime(2026, 11, 8)),
    );
    expect(
      tester.getSemantics(find.text('8')),
      isSemantics(
        label: 'Sunday, November 8, 2026',
        isSelected: true,
        isButton: true,
      ),
    );
    handle.dispose();
  });
}
