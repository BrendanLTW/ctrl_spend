import 'package:ctrl_spend/core/router/app_router.dart';
import 'package:ctrl_spend/core/theme/app_colors.dart';
import 'package:ctrl_spend/core/theme/app_spacing.dart';
import 'package:ctrl_spend/core/theme/app_typography.dart';
import 'package:ctrl_spend/core/widgets/category_tile.dart';
import 'package:ctrl_spend/core/widgets/list_group.dart';
import 'package:ctrl_spend/core/widgets/onboarding_scaffold.dart';
import 'package:ctrl_spend/features/categories/domain/category_keys.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// S03 How it works: three basics and the privacy promise. Continue and
/// Skip both go on to the setup steps.
class HowItWorksScreen extends StatelessWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    void next() => context.push(Routes.onboardingSetup);
    return OnboardingScaffold(
      title: l10n.howTitle,
      subtitle: l10n.howSubtitle,
      primaryLabel: l10n.continueAction,
      onPrimary: next,
      onSkip: next,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _SectionLabel(l10n.howBasics),
          ListGroup(
            children: [
              ListGroupRow(
                leading: const CategoryTile(
                  icon: Icons.account_balance_wallet_outlined,
                  color: CategoryColorKey.orange,
                ),
                title: l10n.howBudgetTitle,
                subtitle: l10n.howBudgetBody,
              ),
              ListGroupRow(
                leading: const CategoryTile(
                  icon: Icons.add_rounded,
                  color: CategoryColorKey.purple,
                ),
                title: l10n.howLogTitle,
                subtitle: l10n.howLogBody,
              ),
              ListGroupRow(
                leading: const CategoryTile(
                  icon: Icons.insert_chart_outlined_rounded,
                  color: CategoryColorKey.blue,
                ),
                title: l10n.howSeeTitle,
                subtitle: l10n.howSeeBody,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sectionTop),
          _SectionLabel(l10n.howPrivacy),
          ListGroup(
            children: [
              ListGroupRow(
                leading: const CategoryTile(
                  icon: Icons.verified_user_outlined,
                  color: CategoryColorKey.green,
                ),
                title: l10n.howPrivacyTitle,
                subtitle: l10n.howPrivacyBody,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const new(this.label);

  final String label;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(
      AppSpacing.textX - AppSpacing.screenX,
      0,
      0,
      12,
    ),
    child: Semantics(
      header: true,
      child: Text(
        label.toUpperCase(),
        style: context.text.label.copyWith(color: context.colors.muted),
      ),
    ),
  );
}
