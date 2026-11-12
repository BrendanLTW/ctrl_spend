import 'dart:async';

import 'package:ctrl_spend/features/notifications/domain/app_notification.dart';
import 'package:ctrl_spend/features/notifications/domain/notification_repository.dart';

/// In-memory inbox for widget tests.
class FakeNotificationRepository implements NotificationRepository {
  final List<AppNotification> all = [];
  final _changes = StreamController<void>.broadcast();

  List<AppNotification> get _sorted =>
      [...all]..sort((a, b) => b.createdAt.compareTo(a.createdAt));

  @override
  Stream<List<AppNotification>> watch() {
    StreamSubscription<void>? changes;
    late final StreamController<List<AppNotification>> out;
    out = StreamController<List<AppNotification>>(
      onListen: () {
        out.add(_sorted);
        changes = _changes.stream.listen((_) => out.add(_sorted));
      },
      onCancel: () => changes?.cancel(),
    );
    return out.stream;
  }

  @override
  Future<void> add({
    required NotificationKind kind,
    required String title,
    required String body,
    required DateTime createdAt,
    int? categoryId,
  }) async {
    all.add(
      AppNotification(
        id: all.length + 1,
        kind: kind,
        title: title,
        body: body,
        createdAt: createdAt,
        categoryId: categoryId,
      ),
    );
    _changes.add(null);
  }

  @override
  Future<void> markAllRead(DateTime at) async {
    for (final (i, n) in all.indexed) {
      if (n.readAt == null) all[i] = n.copyWith(readAt: at);
    }
    _changes.add(null);
  }
}
