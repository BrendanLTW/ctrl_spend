import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_radius.dart';
import 'package:ctrl_spend/core/theme/app_shadows.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/theme/brand_colors.dart';
import 'package:ctrl_spend/core/widgets/brand_symbol.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/core/widgets/section_label.dart';
import 'package:ctrl_spend/features/notifications/presentation/notification_service.dart';
import 'package:ctrl_spend/features/notifications/presentation/reminder_toggles.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// S07 Stay on track (step 5 of 5): a sample notification and the three
/// reminder toggles, saved as they're flipped. Both buttons go on to S08.
class RemindersScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    void next() => context.push(Routes.onboardingDone);

    return OnboardingScaffold(
      step: 5,
      title: l10n.remindersTitle,
      subtitle: l10n.remindersSubtitle,
      primaryLabel: l10n.turnOnNotifications,
      // Moves on whatever the answer; the toggles stay as set.
      onPrimary: () async {
        await ref.read(notificationServiceProvider).requestPermission();
        if (context.mounted) next();
      },
      secondaryLabel: l10n.notNow,
      onSecondary: next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _SampleNotification(),
          const SizedBox(height: 28),
          SectionLabel(l10n.notifyMeAbout),
          const ReminderToggles(),
        ],
      ),
    );
  }
}

/// An example of the daily reminder; decorative, so screen readers skip it.
class _SampleNotification extends StatelessWidget {
  const new();

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return ExcludeSemantics(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: colors.surface,
          borderRadius: BorderRadius.circular(AppRadius.r24),
          boxShadow: context.shadows.bottomBar,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: BrandColors.navy,
                borderRadius: BorderRadius.circular(AppRadius.r12),
              ),
              alignment: Alignment.center,
              child: const BrandSymbol(size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l10n.appName,
                          style: text.rowTitleSm.copyWith(color: colors.ink),
                        ),
                      ),
                      Text(
                        l10n.notificationNow,
                        style: text.caption.copyWith(color: colors.muted),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    l10n.sampleNotification,
                    style: text.body.copyWith(color: colors.ink),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
