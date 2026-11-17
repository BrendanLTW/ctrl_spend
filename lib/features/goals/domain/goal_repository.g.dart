// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'goal_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

@ProviderFor(goalRepository)
final goalRepositoryProvider = GoalRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

final class GoalRepositoryProvider
    extends $FunctionalProvider<GoalRepository, GoalRepository, GoalRepository>
    with $Provider<GoalRepository> {
  /// Overridden in `main.dart` with the Drift implementation, so screens
  /// never import `data/`.
  GoalRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalRepositoryHash();

  @$internal
  @override
  $ProviderElement<GoalRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoalRepository create(Ref ref) {
    return goalRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoalRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoalRepository>(value),
    );
  }
}

String _$goalRepositoryHash() => r'855fea2dcae8f078537c621636598cfb0d974749';

/// Every goal, live, soonest target first.

@ProviderFor(goals)
final goalsProvider = GoalsProvider._();

/// Every goal, live, soonest target first.

final class GoalsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Goal>>,
          List<Goal>,
          Stream<List<Goal>>
        >
    with $FutureModifier<List<Goal>>, $StreamProvider<List<Goal>> {
  /// Every goal, live, soonest target first.
  GoalsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalsHash();

  @$internal
  @override
  $StreamProviderElement<List<Goal>> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<List<Goal>> create(Ref ref) {
    return goals(ref);
  }
}

String _$goalsHash() => r'8e51c1e8ca7e0c991c93221398e8f2a32396eea1';

/// Every contribution, live, newest first.

@ProviderFor(goalContributions)
final goalContributionsProvider = GoalContributionsProvider._();

/// Every contribution, live, newest first.

final class GoalContributionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<GoalContribution>>,
          List<GoalContribution>,
          Stream<List<GoalContribution>>
        >
    with
        $FutureModifier<List<GoalContribution>>,
        $StreamProvider<List<GoalContribution>> {
  /// Every contribution, live, newest first.
  GoalContributionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goalContributionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goalContributionsHash();

  @$internal
  @override
  $StreamProviderElement<List<GoalContribution>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<GoalContribution>> create(Ref ref) {
    return goalContributions(ref);
  }
}

String _$goalContributionsHash() => r'93d398d701cf971792442a1f9b4563471e517bdd';
