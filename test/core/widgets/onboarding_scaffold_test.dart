import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/step_indicator.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../helpers/themed.dart';

Future<void> pumpScreen(WidgetTester tester, ThemeData theme, Widget screen) =>
    tester.pumpWidget(
      MaterialApp(
        theme: theme,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: screen,
      ),
    );

void main() {
  group('PrimaryButton', () {
    for (final t in themes) {
      testWidgets('ink when enabled, raised when disabled in ${t.name}', (
        tester,
      ) async {
        var taps = 0;
        await pumpThemed(
          tester,
          t.theme,
          PrimaryButton(label: 'Continue', onPressed: () => taps++),
        );
        Material fill() => tester.widget<Material>(
          find
              .descendant(
                of: find.byType(PrimaryButton),
                matching: find.byType(Material),
              )
              .first,
        );
        expect(fill().color, t.colors.ink);
        expect(tester.getSize(find.byType(PrimaryButton)).height, 58);
        await tester.tap(find.text('Continue'));
        expect(taps, 1);

        await pumpThemed(
          tester,
          t.theme,
          const PrimaryButton(label: 'Continue', onPressed: null),
        );
        expect(fill().color, t.colors.raised);
        expect(
          tester.widget<Text>(find.text('Continue')).style!.color,
          t.colors.disabled,
        );
      });
    }

    testWidgets('reads as a disabled button when off', (tester) async {
      final handle = tester.ensureSemantics();
      await pumpThemed(
        tester,
        themes.first.theme,
        const PrimaryButton(label: 'Continue', onPressed: null),
      );
      expect(
        tester.getSemantics(find.byType(PrimaryButton)),
        isSemantics(
          label: 'Continue',
          isButton: true,
          hasEnabledState: true,
          isEnabled: false,
        ),
      );
      handle.dispose();
    });
  });

  testWidgets('TextLink has a 52 px touch area and can be muted', (
    tester,
  ) async {
    final t = themes.first;
    await pumpThemed(
      tester,
      t.theme,
      Column(
        children: [
          TextLink(label: 'Skip the tour', onPressed: () {}),
          TextLink(label: 'Skip', onPressed: () {}, muted: true),
        ],
      ),
    );
    expect(
      tester.getSize(find.byType(TextLink).first).height,
      greaterThanOrEqualTo(52),
    );
    expect(
      tester.widget<Text>(find.text('Skip the tour')).style!.color,
      t.colors.ink,
    );
    expect(tester.widget<Text>(find.text('Skip')).style!.color, t.colors.muted);
  });

  group('OnboardingScaffold', () {
    for (final t in themes) {
      testWidgets('title, step, skip and pinned button in ${t.name}', (
        tester,
      ) async {
        var continued = 0;
        var skipped = 0;
        await pumpScreen(
          tester,
          t.theme,
          OnboardingScaffold(
            title: 'Set up your month',
            subtitle: 'Line your budget period up with payday.',
            step: 2,
            onSkip: () => skipped++,
            primaryLabel: 'Continue',
            onPrimary: () => continued++,
            body: const SizedBox(height: 100),
          ),
        );
        expect(
          tester.widget<Scaffold>(find.byType(Scaffold)).backgroundColor,
          t.colors.ground,
        );
        expect(
          tester.widget<Text>(find.text('Set up your month')).style!.color,
          t.colors.ink,
        );
        expect(
          tester
              .widget<Text>(
                find.text('Line your budget period up with payday.'),
              )
              .style!
              .color,
          t.colors.muted,
        );
        final indicator = tester.widget<StepIndicator>(
          find.byType(StepIndicator),
        );
        expect((indicator.current, indicator.total), (2, 5));

        final screenHeight =
            tester.view.physicalSize.height / tester.view.devicePixelRatio;
        expect(
          tester.getBottomLeft(find.byType(PrimaryButton)).dy,
          screenHeight - 34,
        );

        await tester.tap(find.text('Continue'));
        await tester.tap(find.text('Skip'));
        expect((continued, skipped), (1, 1));
      });
    }

    testWidgets('no step or skip unless given; a secondary link below', (
      tester,
    ) async {
      var later = 0;
      await pumpScreen(
        tester,
        themes.first.theme,
        OnboardingScaffold(
          title: 'Stay on track',
          primaryLabel: 'Turn on notifications',
          onPrimary: () {},
          secondaryLabel: 'Not now',
          onSecondary: () => later++,
          body: const SizedBox(),
        ),
      );
      expect(find.byType(StepIndicator), findsNothing);
      expect(find.text('Skip'), findsNothing);
      await tester.tap(find.text('Not now'));
      expect(later, 1);
      expect(
        tester.getTopLeft(find.text('Not now')).dy,
        greaterThan(tester.getBottomLeft(find.byType(PrimaryButton)).dy),
      );
    });

    testWidgets('the footer stays pinned above the button', (tester) async {
      await pumpScreen(
        tester,
        themes.first.theme,
        OnboardingScaffold(
          title: 'Set your monthly budget',
          primaryLabel: 'Continue',
          onPrimary: () {},
          // Taller than the screen, so the content has to scroll.
          body: const SizedBox(height: 2000),
          footer: const SizedBox(key: Key('keypad'), height: 100),
        ),
      );
      final footer = tester.getRect(find.byKey(const Key('keypad')));
      final button = tester.getRect(find.byType(PrimaryButton));
      expect(footer.bottom, button.top - 16);
      expect(
        footer.top,
        lessThan(
          tester.view.physicalSize.height / tester.view.devicePixelRatio,
        ),
      );
    });

    testWidgets('back pops the route', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: themes.first.theme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => OnboardingScaffold(
                    title: 'Step',
                    primaryLabel: 'Continue',
                    onPrimary: () {},
                    body: const SizedBox(),
                  ),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      );
      await tester.tap(find.text('open'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.byType(OnboardingScaffold), findsNothing);
    });
  });
}
