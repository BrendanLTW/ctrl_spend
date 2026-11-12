import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';

/// What the fake scheduler was asked to show: daily and weekly repeat at
/// `minutes`; once fires at `at`.
typedef Scheduled = ({
  String kind,
  String title,
  String body,
  int? weekday,
  int? minutes,
  DateTime? at,
});

/// Records schedules instead of talking to the phone.
class FakeNotificationScheduler implements NotificationScheduler {
  new({this.grant = true});

  final bool grant;
  int permissionRequests = 0;
  final Map<int, Scheduled> pending = {};

  @override
  Future<bool> requestPermission() async {
    permissionRequests++;
    return grant;
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required int minutes,
    required String title,
    required String body,
  }) async => pending[id] = (
    kind: 'daily',
    title: title,
    body: body,
    weekday: null,
    minutes: minutes,
    at: null,
  );

  @override
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int minutes,
    required String title,
    required String body,
  }) async => pending[id] = (
    kind: 'weekly',
    title: title,
    body: body,
    weekday: weekday,
    minutes: minutes,
    at: null,
  );

  @override
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async => pending[id] = (
    kind: 'once',
    title: title,
    body: body,
    weekday: null,
    minutes: null,
    at: at,
  );

  @override
  Future<void> cancel(int id) async => pending.remove(id);
}
