import 'package:ctrl_spend/features/onboarding/presentation/onboarding_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// shortcut: placeholder for the onboarding flow (S01–S08); built in its own
// task.
class OnboardingScreen extends ConsumerWidget {
  const new({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () =>
              ref.read(onboardingCompleteProvider.notifier).complete(),
          child: const Text('Finish onboarding'),
        ),
      ),
    );
  }
}
