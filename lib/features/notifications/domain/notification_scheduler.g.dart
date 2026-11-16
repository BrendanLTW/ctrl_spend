// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notification_scheduler.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Whether notifications are allowed; S48 refreshes it on resume.

@ProviderFor(notificationsPermitted)
final notificationsPermittedProvider = NotificationsPermittedProvider._();

/// Whether notifications are allowed; S48 refreshes it on resume.

final class NotificationsPermittedProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Whether notifications are allowed; S48 refreshes it on resume.
  NotificationsPermittedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsPermittedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsPermittedHash();

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    return notificationsPermitted(ref);
  }
}

String _$notificationsPermittedHash() =>
    r'e5dd374ea36f5e6978b8c6958fc2b43da8a00a52';

/// Overridden in `main.dart` with the flutter_local_notifications one.

@ProviderFor(notificationScheduler)
final notificationSchedulerProvider = NotificationSchedulerProvider._();

/// Overridden in `main.dart` with the flutter_local_notifications one.

final class NotificationSchedulerProvider
    extends
        $FunctionalProvider<
          NotificationScheduler,
          NotificationScheduler,
          NotificationScheduler
        >
    with $Provider<NotificationScheduler> {
  /// Overridden in `main.dart` with the flutter_local_notifications one.
  NotificationSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationSchedulerHash();

  @$internal
  @override
  $ProviderElement<NotificationScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationScheduler create(Ref ref) {
    return notificationScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationScheduler>(value),
    );
  }
}

String _$notificationSchedulerHash() =>
    r'4cbd7f3e3a1c39e79ef5c804d1d99849d5675360';
