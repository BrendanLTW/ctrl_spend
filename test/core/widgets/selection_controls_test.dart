import 'package:ctrl_spend/core/widgets/app_radio.dart';
import 'package:ctrl_spend/core/widgets/app_toggle.dart';
import 'package:ctrl_spend/core/widgets/day_selector.dart';
import 'package:ctrl_spend/core/widgets/segmented_control.dart';
import 'package:ctrl_spend/core/widgets/step_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

BoxDecoration decorationOf(WidgetTester tester, Finder finder) =>
    tester.widget<AnimatedContainer>(finder).decoration! as BoxDecoration;

void main() {
  group('SegmentedControl', () {
    Widget control({String selected = 'month', bool inSheet = false}) =>
        SegmentedControl<String>(
          segments: const [
            (value: 'week', label: 'Week'),
            (value: 'month', label: 'Month'),
            (value: 'six', label: '6 months'),
          ],
          selected: selected,
          onChanged: (_) {},
          inSheet: inSheet,
        );

    Finder segment(String label) => find.ancestor(
      of: find.text(label),
      matching: find.byType(AnimatedContainer),
    );

    for (final t in themes) {
      testWidgets('the selected segment is ink in ${t.name}', (tester) async {
        await pumpThemed(tester, t.theme, control());
        expect(decorationOf(tester, segment('Month')).color, t.colors.ink);
        expect(
          tester.widget<Text>(find.text('Month')).style!.color,
          t.colors.onInk,
        );
        expect(
          tester.widget<Text>(find.text('Week')).style!.color,
          t.colors.muted,
        );
        final track =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(SegmentedControl<String>),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(track.color, t.colors.surface);
      });

      testWidgets('the sheet variant in ${t.name}', (tester) async {
        await pumpThemed(tester, t.theme, control(inSheet: true));
        expect(tester.getSize(segment('Week')).height, 42);
        final track =
            tester
                    .widget<DecoratedBox>(
                      find
                          .descendant(
                            of: find.byType(SegmentedControl<String>),
                            matching: find.byType(DecoratedBox),
                          )
                          .first,
                    )
                    .decoration
                as BoxDecoration;
        expect(track.color, t.colors.fillSoft);
      });
    }

    testWidgets('reports the tapped value and reads as selected', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      String? tapped;
      await pumpThemed(
        tester,
        themes.first.theme,
        SegmentedControl<String>(
          segments: const [
            (value: 'expense', label: 'Expense'),
            (value: 'income', label: 'Income'),
          ],
          selected: 'expense',
          onChanged: (v) => tapped = v,
        ),
      );
      expect(tester.getSize(segment('Expense')).height, 46);
      await tester.tap(find.text('Income'));
      expect(tapped, 'income');
      expect(
        tester.getSemantics(find.text('Expense')),
        isSemantics(label: 'Expense', isSelected: true, isButton: true),
      );
      handle.dispose();
    });
  });

  group('AppToggle', () {
    for (final t in themes) {
      testWidgets('ink when on, control when off in ${t.name}', (tester) async {
        for (final (value, colour) in [
          (true, t.colors.ink),
          (false, t.colors.control),
        ]) {
          await pumpThemed(
            tester,
            t.theme,
            AppToggle(value: value, onChanged: (_) {}, semanticLabel: 'Daily'),
          );
          await tester.pumpAndSettle();
          final track = tester.widget<AnimatedContainer>(
            find.byType(AnimatedContainer),
          );
          expect((track.decoration! as ShapeDecoration).color, colour);
          final thumb = tester.widget<Container>(
            find
                .descendant(
                  of: find.byType(AnimatedContainer),
                  matching: find.byType(Container),
                )
                .last,
          );
          expect(
            (thumb.decoration! as BoxDecoration).color,
            value ? t.colors.onInk : Colors.white,
          );
        }
      });
    }

    testWidgets('is 52 × 32 with a 44 high touch area', (tester) async {
      await pumpThemed(
        tester,
        themes.first.theme,
        AppToggle(value: true, onChanged: (_) {}, semanticLabel: 'Daily'),
      );
      expect(tester.getSize(find.byType(AppToggle)), const Size(52, 44));
      expect(
        tester.getSize(find.byType(AnimatedContainer)),
        const Size(52, 32),
      );
    });

    testWidgets('flips its value and reads as a toggle', (tester) async {
      final handle = tester.ensureSemantics();
      bool? next;
      await pumpThemed(
        tester,
        themes.first.theme,
        AppToggle(
          value: false,
          onChanged: (v) => next = v,
          semanticLabel: 'Daily reminder',
        ),
      );
      await tester.tap(find.byType(AppToggle));
      expect(next, isTrue);
      expect(
        tester.getSemantics(find.byType(AppToggle)),
        isSemantics(
          label: 'Daily reminder',
          hasToggledState: true,
          isToggled: false,
          hasTapAction: true,
        ),
      );
      handle.dispose();
    });
  });

  group('AppRadio', () {
    for (final t in themes) {
      testWidgets('a thick ink ring when selected in ${t.name}', (
        tester,
      ) async {
        await pumpThemed(tester, t.theme, const AppRadio(selected: true));
        await tester.pumpAndSettle();
        var border =
            (decorationOf(tester, find.byType(AnimatedContainer)).border!
                    as Border)
                .top;
        expect(border.color, t.colors.ink);
        expect(border.width, 7);

        await pumpThemed(tester, t.theme, const AppRadio(selected: false));
        await tester.pumpAndSettle();
        border =
            (decorationOf(tester, find.byType(AnimatedContainer)).border!
                    as Border)
                .top;
        expect(border.color, t.colors.control);
        expect(border.width, 2);
      });
    }

    testWidgets('tappable radios have a 44 px target and read as checked', (
      tester,
    ) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpThemed(
        tester,
        themes.first.theme,
        AppRadio(selected: true, onTap: () => taps++, semanticLabel: 'System'),
      );
      expect(tester.getSize(find.byType(AppRadio)), const Size(44, 44));
      await tester.tap(find.byType(AppRadio));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(AppRadio)),
        isSemantics(
          label: 'System',
          hasCheckedState: true,
          isChecked: true,
          isInMutuallyExclusiveGroup: true,
        ),
      );
      handle.dispose();
    });
  });

  group('DaySelector', () {
    for (final t in themes) {
      testWidgets('ink when selected, surface otherwise in ${t.name}', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          t.theme,
          Row(
            children: [
              Expanded(
                child: DaySelector(label: '1st', selected: false, onTap: () {}),
              ),
              Expanded(
                child: DaySelector(label: '15th', selected: true, onTap: () {}),
              ),
            ],
          ),
        );
        Material fill(String label) => tester.widget<Material>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Material))
              .first,
        );
        expect(fill('15th').color, t.colors.ink);
        expect(fill('1st').color, t.colors.surface);
        expect(
          tester.widget<Text>(find.text('15th')).style!.color,
          t.colors.onInk,
        );
        expect(tester.getSize(find.byType(DaySelector).first).height, 56);
      });
    }

    testWidgets('reports taps and reads its label as selected', (tester) async {
      final handle = tester.ensureSemantics();
      var taps = 0;
      await pumpThemed(
        tester,
        themes.first.theme,
        DaySelector(
          label: '15',
          semanticLabel: '15th',
          selected: true,
          onTap: () => taps++,
        ),
      );
      await tester.tap(find.byType(DaySelector));
      expect(taps, 1);
      expect(
        tester.getSemantics(find.byType(DaySelector)),
        isSemantics(label: '15th', isSelected: true, isButton: true),
      );
      handle.dispose();
    });
  });

  group('StepIndicator', () {
    for (final t in themes) {
      testWidgets('steps up to the current one are ink in ${t.name}', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          t.theme,
          const StepIndicator(current: 2, total: 5),
        );
        final pills = tester
            .widgetList<Container>(
              find.descendant(
                of: find.byType(StepIndicator),
                matching: find.byType(Container),
              ),
            )
            .map((c) => (c.decoration! as ShapeDecoration).color)
            .toList();
        expect(pills, [
          t.colors.ink,
          t.colors.ink,
          t.colors.stepOff,
          t.colors.stepOff,
          t.colors.stepOff,
        ]);
        expect(
          tester.getSize(find.byType(StepIndicator)),
          const Size(5 * 28 + 4 * 6, 6),
        );
      });
    }

    testWidgets('reads "Step 2 of 5"', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        themes.first.theme,
        const StepIndicator(current: 2, total: 5),
      );
      expect(find.bySemanticsLabel('Step 2 of 5'), findsOneWidget);
      handle.dispose();
    });
  });
}
