import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/step_indicator.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';

/// The onboarding step layout (DESIGN §6, S03–S07): back, an optional step
/// indicator and Skip, a title and supporting line, the step's content,
/// and the primary button pinned 34 px from the bottom.
class OnboardingScaffold extends StatelessWidget {
  const new({
    required this.title,
    required this.body,
    required this.primaryLabel,
    required this.onPrimary,
    this.subtitle,
    this.step,
    this.totalSteps = 5,
    this.onSkip,
    this.secondaryLabel,
    this.onSecondary,
    this.footer,
    super.key,
  }) : assert(
         (secondaryLabel == null) == (onSecondary == null),
         'label + action',
       );

  final String title;
  final String? subtitle;
  final Widget body;
  final String primaryLabel;

  /// Null disables the button, e.g. until a name is typed.
  final VoidCallback? onPrimary;

  /// 1-based; null hides the indicator (S03).
  final int? step;
  final int totalSteps;
  final VoidCallback? onSkip;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  /// Pinned above the primary button, outside the scrolling content, so
  /// it always stays on screen (S05's keypad).
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final text = context.text;
    final l10n = context.l10n;
    return Scaffold(
      backgroundColor: colors.ground,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 56,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 8),
                      child: IconButton(
                        onPressed: () => Navigator.of(context).maybePop(),
                        tooltip: l10n.back,
                        color: colors.ink,
                        icon: const Icon(Icons.chevron_left_rounded, size: 30),
                      ),
                    ),
                  ),
                  if (step case final step?)
                    StepIndicator(current: step, total: totalSteps),
                  if (onSkip case final onSkip?)
                    Align(
                      alignment: Alignment.centerRight,
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: TextLink(
                          label: l10n.skip,
                          onPressed: onSkip,
                          muted: true,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  16,
                  AppSpacing.screenX,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.textX - AppSpacing.screenX,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Semantics(
                            header: true,
                            child: Text(
                              title,
                              style: text.pageTitle.copyWith(color: colors.ink),
                            ),
                          ),
                          if (subtitle case final subtitle?) ...[
                            const SizedBox(height: 10),
                            Text(
                              subtitle,
                              style: text.body.copyWith(color: colors.muted),
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sectionTop),
                    body,
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                secondaryLabel == null ? 34 : 12,
              ),
              child: Column(
                children: [
                  if (footer case final footer?) ...[
                    footer,
                    const SizedBox(height: 16),
                  ],
                  PrimaryButton(label: primaryLabel, onPressed: onPrimary),
                  if ((secondaryLabel, onSecondary) case (
                    final label?,
                    final onTap?,
                  )) ...[
                    const SizedBox(height: 8),
                    TextLink(label: label, onPressed: onTap),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
