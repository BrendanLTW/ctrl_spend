import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_toast.dart';
import 'package:ctrl_spend/core/widgets/empty_state.dart';
import 'package:ctrl_spend/core/widgets/pill_button.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

/// A button that runs [onPressed] with a context under the app's theme.
Widget launcher(void Function(BuildContext) onPressed) => Builder(
  builder: (context) => TextButton(
    onPressed: () => onPressed(context),
    child: const Text('open'),
  ),
);

void main() {
  group('EmptyState', () {
    for (final t in themes) {
      testWidgets('the card variant in ${t.name}', (tester) async {
        var taps = 0;
        await pumpThemed(
          tester,
          t.theme,
          EmptyState(
            icon: Icons.receipt_long_outlined,
            title: 'No transactions yet',
            body: 'Add what you spend and your budget updates as you go.',
            actionLabel: 'Add your first expense',
            onAction: () => taps++,
          ),
        );
        final card = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(EmptyState),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((card.decoration! as BoxDecoration).color, t.colors.surface);
        final tile = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.receipt_long_outlined),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((tile.decoration! as BoxDecoration).color, t.colors.raised);
        expect(
          tester.getSize(
            find
                .ancestor(
                  of: find.byIcon(Icons.receipt_long_outlined),
                  matching: find.byType(Container),
                )
                .first,
          ),
          const Size(64, 64),
        );
        expect(
          tester.widget<Text>(find.textContaining('Add what')).style!.color,
          t.colors.muted,
        );
        await tester.tap(find.text('Add your first expense'));
        expect(taps, 1);
      });
    }

    testWidgets('the plain variant has a large circle and no card', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        themes.first.theme,
        EmptyState(
          icon: Icons.search_off_rounded,
          title: 'No results for "netflix"',
          body: 'Nothing matches in Expense.',
          actionLabel: 'Search all',
          onAction: () {},
          card: false,
        ),
      );
      final circle = find.ancestor(
        of: find.byIcon(Icons.search_off_rounded),
        matching: find.byType(Container),
      );
      expect(tester.getSize(circle.first), const Size(96, 96));
      expect(
        (tester.widget<Container>(circle.first).decoration! as BoxDecoration)
            .shape,
        BoxShape.circle,
      );
      expect(circle, findsOneWidget, reason: 'no surrounding card');
    });

    testWidgets('a custom graphic replaces the icon, no action needed', (
      tester,
    ) async {
      await pumpThemed(
        tester,
        themes.first.theme,
        const EmptyState(
          graphic: SizedBox(key: Key('donut'), width: 180, height: 180),
          title: 'Not enough data yet',
          body: "Charts appear once you've logged a few days of spending.",
          card: false,
        ),
      );
      expect(find.byKey(const Key('donut')), findsOneWidget);
      expect(find.byType(PillButton), findsNothing);
    });
  });

  group('AppToast', () {
    tearDown(hideAppToast);

    for (final t in themes) {
      testWidgets("ink fill and the other theme's warning action in "
          '${t.name}', (tester) async {
        await pumpThemed(
          tester,
          t.theme,
          AppToast(
            message: 'Transaction deleted',
            actionLabel: 'Undo',
            onAction: () {},
          ),
        );
        final box = tester.widget<Container>(
          find
              .descendant(
                of: find.byType(AppToast),
                matching: find.byType(Container),
              )
              .first,
        );
        expect((box.decoration! as BoxDecoration).color, t.colors.ink);
        final expected = t.name == 'light'
            ? AppColors.dark.warning
            : AppColors.light.warning;
        expect(tester.widget<Text>(find.text('Undo')).style!.color, expected);
        expect(
          tester.widget<Text>(find.text('Transaction deleted')).style!.color,
          t.colors.onInk,
        );
      });
    }

    testWidgets('shows for 5 seconds, then hides', (tester) async {
      await pumpThemed(
        tester,
        themes.first.theme,
        launcher((c) => showAppToast(c, message: 'Saved')),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 4900));
      expect(find.text('Saved'), findsOneWidget);
      await tester.pump(const Duration(milliseconds: 200));
      expect(find.text('Saved'), findsNothing);
    });

    testWidgets('the action runs once and hides the toast', (tester) async {
      var undos = 0;
      await pumpThemed(
        tester,
        themes.first.theme,
        launcher(
          (c) => showAppToast(
            c,
            message: 'Transaction deleted',
            actionLabel: 'Undo',
            onAction: () => undos++,
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      await tester.tap(find.text('Undo'));
      await tester.pump();
      expect(undos, 1);
      expect(find.text('Transaction deleted'), findsNothing);
    });

    testWidgets('a new toast replaces the current one', (tester) async {
      var count = 0;
      await pumpThemed(
        tester,
        themes.first.theme,
        launcher((c) => showAppToast(c, message: 'Toast ${++count}')),
      );
      await tester.tap(find.text('open'));
      await tester.pump(const Duration(seconds: 3));
      await tester.tap(find.text('open'));
      await tester.pump();
      expect(find.text('Toast 1'), findsNothing);
      expect(find.text('Toast 2'), findsOneWidget);
      // The first toast's timer must not hide the second early.
      await tester.pump(const Duration(seconds: 3));
      expect(find.text('Toast 2'), findsOneWidget);
      hideAppToast();
    });

    testWidgets('sits 106 px above the bottom', (tester) async {
      await pumpThemed(
        tester,
        themes.first.theme,
        launcher((c) => showAppToast(c, message: 'Saved')),
      );
      await tester.tap(find.text('open'));
      await tester.pump();
      final screen = tester.view.physicalSize / tester.view.devicePixelRatio;
      expect(
        tester.getBottomLeft(find.byType(AppToast)).dy,
        screen.height - 106,
      );
      hideAppToast();
    });
  });

  group('AppSheet', () {
    for (final t in themes) {
      testWidgets('a surface sheet with a title and close in ${t.name}', (
        tester,
      ) async {
        await pumpThemed(
          tester,
          t.theme,
          launcher(
            (c) => showAppSheet<void>(
              c,
              title: 'Next due date',
              builder: (_) => const Text('content'),
            ),
          ),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
        expect(find.text('Next due date'), findsOneWidget);
        expect(find.text('content'), findsOneWidget);
        final sheet = tester.widget<BottomSheet>(find.byType(BottomSheet));
        expect(sheet.backgroundColor, t.colors.surface);
        expect(
          (sheet.shape! as RoundedRectangleBorder).borderRadius,
          const BorderRadius.vertical(top: Radius.circular(32)),
        );

        await tester.tap(find.byTooltip('Close'));
        await tester.pumpAndSettle();
        expect(find.text('content'), findsNothing);
      });
    }

    testWidgets('a custom trailing action replaces close', (tester) async {
      await pumpThemed(
        tester,
        themes.first.theme,
        launcher(
          (c) => showAppSheet<void>(
            c,
            title: 'Food budget',
            trailing: TextButton(onPressed: () {}, child: const Text('Remove')),
            builder: (_) => const SizedBox(height: 100),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      expect(find.text('Remove'), findsOneWidget);
      expect(find.byTooltip('Close'), findsNothing);
    });
  });

  group('AppDialog', () {
    Future<bool?> open(WidgetTester tester, {bool destructive = true}) async {
      bool? result;
      await pumpThemed(
        tester,
        themes.first.theme,
        launcher((c) async {
          result = await showAppDialog(
            c,
            icon: Icons.delete_outline_rounded,
            title: 'Delete this transaction?',
            body: 'Nasi lemak (RM 12.50) will be removed.',
            confirmLabel: 'Delete',
            destructive: destructive,
          );
        }),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      return result;
    }

    for (final t in themes) {
      testWidgets('a destructive dialog in ${t.name}', (tester) async {
        await pumpThemed(
          tester,
          t.theme,
          const AppDialog(
            icon: Icons.delete_outline_rounded,
            title: 'Delete this transaction?',
            body: 'Nasi lemak (RM 12.50) will be removed.',
            confirmLabel: 'Delete',
            destructive: true,
          ),
        );
        Material button(String label) => tester.widget<Material>(
          find
              .ancestor(of: find.text(label), matching: find.byType(Material))
              .first,
        );
        expect(button('Delete').color, AppColors.light.negative);
        expect(
          tester.widget<Text>(find.text('Delete')).style!.color,
          Colors.white,
        );
        expect(button('Cancel').color, t.colors.fillSoft);
        final circle = tester.widget<Container>(
          find
              .ancestor(
                of: find.byIcon(Icons.delete_outline_rounded),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(
          (circle.decoration! as BoxDecoration).color,
          t.categories.of(CategoryColorKey.red).tile,
        );
        expect(
          tester.getTopLeft(find.text('Delete')).dy,
          lessThan(tester.getTopLeft(find.text('Cancel')).dy),
          reason: 'confirm first, Cancel second',
        );
      });
    }

    testWidgets('confirm resolves true', (tester) async {
      await open(tester);
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(find.byType(AppDialog), findsNothing);
    });

    testWidgets('returns true on confirm, false on cancel or dismiss', (
      tester,
    ) async {
      bool? result;
      Future<void> show() async {
        await pumpThemed(
          tester,
          themes.first.theme,
          launcher((c) async {
            result = await showAppDialog(
              c,
              icon: Icons.delete_outline_rounded,
              title: 'Delete?',
              body: 'Body',
              confirmLabel: 'Delete',
            );
          }),
        );
        await tester.tap(find.text('open'));
        await tester.pumpAndSettle();
      }

      await show();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle();
      expect(result, isTrue);

      await show();
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      expect(result, isFalse);

      await show();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(result, isFalse);
    });

    testWidgets('a non-destructive dialog uses the primary button', (
      tester,
    ) async {
      await open(tester, destructive: false);
      final confirm = tester.widget<Material>(
        find
            .ancestor(of: find.text('Delete'), matching: find.byType(Material))
            .first,
      );
      expect(confirm.color, themes.first.colors.ink);
    });
  });
}
