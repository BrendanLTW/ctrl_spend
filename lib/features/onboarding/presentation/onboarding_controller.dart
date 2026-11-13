import 'package:ctrl_spend/features/settings/domain/preferences_repository.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'onboarding_controller.g.dart';

/// Whether the user has finished onboarding (stored setting). Null until
/// the settings have loaded; the splash screen waits for it.
@Riverpod(keepAlive: true)
bool? onboardingComplete(Ref ref) =>
    ref.watch(preferencesProvider).value?.onboardingComplete;
