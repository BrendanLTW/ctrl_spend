import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/primary_button.dart';
import 'package:ctrl_spend/core/widgets/text_link.dart';
import 'package:ctrl_spend/features/onboarding/presentation/welcome_preview.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// S02 Welcome: a dashboard preview, the pitch, Get started (→ S03) and
/// Skip the tour (past S03).
class WelcomeScreen extends StatelessWidget {
  const new({super.key});

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
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.screenX,
                  24,
                  AppSpacing.screenX,
                  24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const WelcomePreview(),
                    const SizedBox(height: 32),
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
                              l10n.welcomeTitle,
                              style: text.welcomeTitle.copyWith(
                                color: colors.ink,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            l10n.welcomeBody,
                            style: text.body.copyWith(color: colors.muted),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenX,
                0,
                AppSpacing.screenX,
                12,
              ),
              child: Column(
                children: [
                  PrimaryButton(
                    label: l10n.getStarted,
                    onPressed: () => context.push(Routes.onboardingHow),
                  ),
                  const SizedBox(height: 8),
                  TextLink(
                    label: l10n.skipTheTour,
                    onPressed: () => context.push(Routes.onboardingName),
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
