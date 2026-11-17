import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/widgets/action_sheet.dart';
import 'package:ctrl_spend/core/widgets/app_dialog.dart';
import 'package:ctrl_spend/core/widgets/app_icon.dart';
import 'package:ctrl_spend/core/widgets/app_spinner.dart';
import 'package:ctrl_spend/core/widgets/app_text_input.dart';
import 'package:ctrl_spend/core/widgets/message_box.dart';
import 'package:ctrl_spend/core/widgets/pay_pill.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/state_view.dart';
import 'package:ctrl_spend/core/widgets/status_pill.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/find_app_icon.dart';
import '../../helpers/themed.dart';

/// The 15 Nov 2026 shared components (task 6.11, DESIGN §3.3, §6, §7).
void main() {
  BoxDecoration decorationOf(WidgetTester tester, Finder finder) =>
      tester
              .widget<Container>(
                find
                    .ancestor(of: finder, matching: find.byType(Container))
                    .first,
              )
              .decoration!
          as BoxDecoration;

  for (final t in themes) {
    group('in ${t.name}', () {
      testWidgets("MessageBox takes each kind's colours and icon", (
        tester,
      ) async {
        for (final (kind, background, foreground, icon) in [
          (
            MessageKind.error,
            t.colors.errorBox,
            t.colors.onErrorBox,
            AppIcon.circleAlert,
          ),
          (
            MessageKind.warning,
            t.colors.warningBox,
            t.colors.onWarningBox,
            AppIcon.warning,
          ),
          (
            MessageKind.success,
            t.colors.successBox,
            t.colors.onSuccessBox,
            AppIcon.checkCircle,
          ),
          (
            MessageKind.info,
            t.colors.infoBox,
            t.colors.onInfoBox,
            AppIcon.info,
          ),
        ]) {
          await pumpThemed(tester, t.theme, MessageBox('Hello', kind: kind));
          final box = decorationOf(tester, find.byType(Row));
          expect(box.color, background, reason: '$kind');
          expect(box.borderRadius, BorderRadius.circular(AppRadius.r18));
          expect(
            tester.widget<AppIconView>(findAppIcon(icon)).color,
            foreground,
          );
          expect(
            tester.widget<Text>(find.text('Hello')).style!.color,
            foreground,
          );
        }
      });

      testWidgets('StatusPill uses the box pairs', (tester) async {
        await pumpThemed(
          tester,
          t.theme,
          const StatusPill('Overdue', tone: StatusTone.red),
        );
        final pill =
            tester
                    .widget<DecoratedBox>(
                      find.descendant(
                        of: find.byType(StatusPill),
                        matching: find.byType(DecoratedBox),
                      ),
                    )
                    .decoration
                as BoxDecoration;
        expect(pill.color, t.colors.errorBox);
        expect(
          tester.widget<Text>(find.text('Overdue')).style!.color,
          t.colors.onErrorBox,
        );
      });

      testWidgets('PrimaryButton disabled and in a sheet', (tester) async {
        await pumpThemed(
          tester,
          t.theme,
          const PrimaryButton(
            label: 'Save',
            onPressed: null,
            size: PrimaryButtonSize.sheet,
          ),
        );
        final material = tester.widget<Material>(
          find.descendant(
            of: find.byType(PrimaryButton),
            matching: find.byType(Material),
          ),
        );
        expect(material.color, t.colors.buttonDisabled);
        expect(material.borderRadius, BorderRadius.circular(20));
        expect(
          tester.widget<Text>(find.text('Save')).style!.color,
          t.colors.onButtonDisabled,
        );
        expect(tester.getSize(find.byType(PrimaryButton)).height, 56);
      });

      testWidgets('StateView: circle, title, body and action', (tester) async {
        var taps = 0;
        await pumpThemed(
          tester,
          t.theme,
          StateView(
            icon: AppIcon.receipt,
            tone: StateTone.success,
            title: 'Imported 202 transactions',
            body: '12 duplicates were skipped.',
            actionLabel: 'Add a bill',
            onAction: () => taps++,
          ),
        );
        final circle = tester.getSize(
          find
              .ancestor(
                of: findAppIcon(AppIcon.receipt),
                matching: find.byType(Container),
              )
              .first,
        );
        expect(circle, const Size(96, 96));
        expect(
          tester.widget<AppIconView>(findAppIcon(AppIcon.receipt)).color,
          t.colors.positive,
        );
        await tester.tap(find.text('Add a bill'));
        expect(taps, 1);
      });

      testWidgets('AppSpinner is a 64 px ring', (tester) async {
        await pumpThemed(tester, t.theme, const AppSpinner());
        expect(
          tester.getSize(find.byType(CircularProgressIndicator)),
          const Size(64, 64),
        );
      });
    });
  }

  testWidgets('AppTextInput counts and outlines focus and errors', (
    tester,
  ) async {
    final controller = TextEditingController(text: 'Alex');
    addTearDown(controller.dispose);
    Future<void> pump({bool error = false}) => pumpThemed(
      tester,
      themes.first.theme,
      AppTextInput(
        controller: controller,
        label: 'First name',
        maxLength: 30,
        error: error,
      ),
    );
    Color outline() =>
        (tester
                    .widget<Container>(
                      find
                          .ancestor(
                            of: find.byType(TextField),
                            matching: find.byType(Container),
                          )
                          .first,
                    )
                    .decoration!
                as BoxDecoration)
            .border!
            .top
            .color;

    await pump();
    expect(find.text('4/30'), findsOneWidget);
    expect(outline(), Colors.transparent);
    await tester.tap(find.byType(TextField));
    await tester.pump();
    expect(outline(), AppColors.light.ink);
    await tester.enterText(find.byType(TextField), 'Alexandra');
    await tester.pump();
    expect(find.text('9/30'), findsOneWidget);
    await pump(error: true);
    expect(outline(), AppColors.light.negative);
  });

  testWidgets('PayPill is a 34 high pill with a 48 px target', (tester) async {
    var taps = 0;
    await pumpThemed(
      tester,
      themes.first.theme,
      PayPill(
        label: 'Pay',
        semanticLabel: 'Pay Netflix',
        onPressed: () => taps++,
      ),
    );
    expect(
      tester.getSize(find.byType(PayPill)).height,
      greaterThanOrEqualTo(48),
    );
    expect(
      tester
          .getSize(
            find.descendant(
              of: find.byType(PayPill),
              matching: find.byType(DecoratedBox),
            ),
          )
          .height,
      34,
    );
    await tester.tap(find.byType(PayPill));
    expect(taps, 1);
    expect(find.bySemanticsLabel('Pay Netflix'), findsOneWidget);
  });

  testWidgets('an action sheet returns the chosen value, or null', (
    tester,
  ) async {
    String? chosen = 'unset';
    await pumpThemed(
      tester,
      themes.first.theme,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => chosen = await showActionSheet<String>(
            context,
            title: 'Bali trip',
            items: const [
              (
                value: 'edit',
                tile: SizedBox(width: 48, height: 48),
                title: 'Edit goal',
                subtitle: 'Name, target, date and icon',
                destructive: false,
              ),
              (
                value: 'delete',
                tile: SizedBox(width: 48, height: 48),
                title: 'Delete goal',
                subtitle: 'Removes the goal and its 3 contributions.',
                destructive: true,
              ),
            ],
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    expect(find.text('Bali trip'), findsOneWidget);
    expect(
      tester.widget<Text>(find.text('Delete goal')).style!.color,
      AppColors.light.negative,
    );
    await tester.tap(find.text('Delete goal'));
    await tester.pumpAndSettle();
    expect(chosen, 'delete');
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(chosen, isNull);
  });

  testWidgets('the state dialog: r30, a 96 px icon, red confirm', (
    tester,
  ) async {
    bool? result;
    await pumpThemed(
      tester,
      themes.first.theme,
      Builder(
        builder: (context) => TextButton(
          onPressed: () async => result = await showAppDialog(
            context,
            icon: AppIcon.trash,
            title: 'Erase all data?',
            body: "It can't be undone.",
            confirmLabel: 'Erase everything',
            destructive: true,
            layout: AppDialogLayout.state,
          ),
          child: const Text('open'),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    final card =
        tester
                .widget<Container>(
                  find
                      .descendant(
                        of: find.byType(Dialog),
                        matching: find.byType(Container),
                      )
                      .first,
                )
                .decoration!
            as BoxDecoration;
    expect(card.borderRadius, BorderRadius.circular(30));
    expect(
      tester
          .getSize(
            find
                .ancestor(
                  of: findAppIcon(AppIcon.trash),
                  matching: find.byType(Container),
                )
                .first,
          )
          .width,
      96,
    );
    final confirm = tester.widget<Material>(
      find.descendant(
        of: find.byType(PrimaryButton),
        matching: find.byType(Material),
      ),
    );
    expect(confirm.color, AppColors.light.destructive);
    await tester.tap(find.text('Erase everything'));
    await tester.pumpAndSettle();
    expect(result, isTrue);
  });
}
