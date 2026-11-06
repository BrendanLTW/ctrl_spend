import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:ctrl_spend/l10n/l10n.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// shortcut: placeholder for the remaining onboarding steps (S05–S08),
// built in tasks 2.5–2.6. Finishing saves `onboardingComplete`.
class OnboardingScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: FilledButton(
          onPressed: () => ref
              .read(preferencesRepositoryProvider)
              .update((p) => p.copyWith(onboardingComplete: true)),
          child: Text(context.l10n.finishOnboarding),
        ),
      ),
    );
  }
}
