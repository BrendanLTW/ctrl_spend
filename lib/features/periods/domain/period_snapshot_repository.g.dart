// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'period_snapshot_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

@ProviderFor(periodSnapshotRepository)
final periodSnapshotRepositoryProvider = PeriodSnapshotRepositoryProvider._();

/// Overridden in `main.dart` with the Drift implementation, so screens
/// never import `data/`.

final class PeriodSnapshotRepositoryProvider
    extends
        $FunctionalProvider<
          PeriodSnapshotRepository,
          PeriodSnapshotRepository,
          PeriodSnapshotRepository
        >
    with $Provider<PeriodSnapshotRepository> {
  /// Overridden in `main.dart` with the Drift implementation, so screens
  /// never import `data/`.
  PeriodSnapshotRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periodSnapshotRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periodSnapshotRepositoryHash();

  @$internal
  @override
  $ProviderElement<PeriodSnapshotRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PeriodSnapshotRepository create(Ref ref) {
    return periodSnapshotRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PeriodSnapshotRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PeriodSnapshotRepository>(value),
    );
  }
}

String _$periodSnapshotRepositoryHash() =>
    r'b19fb3a69dd5a0990673dfd0f6c4349949c2bf24';

/// Every snapshot, live, newest first.

@ProviderFor(periodSnapshots)
final periodSnapshotsProvider = PeriodSnapshotsProvider._();

/// Every snapshot, live, newest first.

final class PeriodSnapshotsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PeriodSnapshot>>,
          List<PeriodSnapshot>,
          Stream<List<PeriodSnapshot>>
        >
    with
        $FutureModifier<List<PeriodSnapshot>>,
        $StreamProvider<List<PeriodSnapshot>> {
  /// Every snapshot, live, newest first.
  PeriodSnapshotsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'periodSnapshotsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$periodSnapshotsHash();

  @$internal
  @override
  $StreamProviderElement<List<PeriodSnapshot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<PeriodSnapshot>> create(Ref ref) {
    return periodSnapshots(ref);
  }
}

String _$periodSnapshotsHash() => r'56ed064ea9272c2cd728db0254ea778270cabbb8';
