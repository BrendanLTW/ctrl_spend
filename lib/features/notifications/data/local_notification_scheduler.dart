import 'package:ctrl_spend/features/notifications/domain/notification_scheduler.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// [NotificationScheduler] on flutter_local_notifications (spike 0.9).
/// Initialises lazily without asking for permission; S07 asks. Schedules
/// are inexact, so Android needs no exact-alarm permission.
// shortcut: delivery is unverified on real devices (docs/spikes.md); the
// zone is read once, so travel needs an app restart to follow.
class LocalNotificationScheduler implements NotificationScheduler {
  final _plugin = FlutterLocalNotificationsPlugin();
  Future<void>? _ready;

  static const _details = NotificationDetails(
    android: AndroidNotificationDetails(
      'reminders',
      'Reminders',
      channelDescription: 'Daily reminder, weekly summary and new period',
    ),
    iOS: DarwinNotificationDetails(),
  );

  Future<void> _init() => _ready ??= () async {
    tz.initializeTimeZones();
    final zone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(zone.identifier));
    await _plugin.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('ic_notification'),
        iOS: DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        ),
      ),
    );
  }();

  @override
  Future<bool> requestPermission() async {
    await _init();
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    return await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  @override
  Future<void> scheduleDaily({
    required int id,
    required int minutes,
    required String title,
    required String body,
  }) async {
    await _init();
    await _schedule(
      id: id,
      at: _next(minutes),
      title: title,
      body: body,
      repeat: DateTimeComponents.time,
    );
  }

  @override
  Future<void> scheduleWeekly({
    required int id,
    required int weekday,
    required int minutes,
    required String title,
    required String body,
  }) async {
    await _init();
    var at = _next(minutes);
    while (at.weekday != weekday) {
      at = at.add(const Duration(days: 1));
    }
    await _schedule(
      id: id,
      at: at,
      title: title,
      body: body,
      repeat: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  @override
  Future<void> scheduleOnce({
    required int id,
    required DateTime at,
    required String title,
    required String body,
  }) async {
    await _init();
    await _schedule(
      id: id,
      at: tz.TZDateTime.from(at, tz.local),
      title: title,
      body: body,
    );
  }

  @override
  Future<void> cancel(int id) async {
    await _init();
    await _plugin.cancel(id: id);
  }

  /// The next local [minutes] after midnight, today or tomorrow.
  tz.TZDateTime _next(int minutes) {
    final now = tz.TZDateTime.now(tz.local);
    var at = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      minutes ~/ 60,
      minutes % 60,
    );
    if (!at.isAfter(now)) at = at.add(const Duration(days: 1));
    return at;
  }

  Future<void> _schedule({
    required int id,
    required tz.TZDateTime at,
    required String title,
    required String body,
    DateTimeComponents? repeat,
  }) async {
    await _init();
    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: at,
      notificationDetails: _details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      matchDateTimeComponents: repeat,
    );
  }
}
