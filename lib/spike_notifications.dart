// SPIKE 0.9: throwaway, never merged. Run: flutter run -t lib/spike_notifications.dart
// ignore_for_file: avoid_print
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final plugin = FlutterLocalNotificationsPlugin();

const details = NotificationDetails(
  android: AndroidNotificationDetails(
    'reminders',
    'Reminders',
    channelDescription: 'Daily reminder and budget alerts',
  ),
);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  tz.initializeTimeZones();
  final zone = await FlutterTimezone.getLocalTimezone();
  tz.setLocalLocation(tz.getLocation(zone.identifier));
  await plugin.initialize(
    settings: const InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      // Don't prompt at launch; S07 asks on a button tap.
      iOS: DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      ),
    ),
    onDidReceiveNotificationResponse: (r) => print('tapped: ${r.payload}'),
  );
  final launch = await plugin.getNotificationAppLaunchDetails();
  print('launched by notification: ${launch?.didNotificationLaunchApp}');
  runApp(MaterialApp(home: SpikeScreen(zone: zone.identifier)));
}

class SpikeScreen extends StatefulWidget {
  const new({required this.zone, super.key});

  final String zone;

  @override
  State<SpikeScreen> createState() => _SpikeScreenState();
}

class _SpikeScreenState extends State<SpikeScreen> {
  final log = <String>[];

  void note(String s) {
    print(s);
    setState(() => log.insert(0, '${TimeOfDay.now().format(context)}  $s'));
  }

  AndroidFlutterLocalNotificationsPlugin? get android =>
      plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  IOSFlutterLocalNotificationsPlugin? get ios =>
      plugin.resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin
      >();

  Future<void> requestPermission() async {
    final granted =
        await android?.requestNotificationsPermission() ??
        await ios?.requestPermissions(alert: true, badge: true, sound: true);
    note('permission granted: $granted');
  }

  Future<void> checkPermission() async {
    if (android != null) {
      note('android enabled: ${await android!.areNotificationsEnabled()}');
      note('android exact: ${await android!.canScheduleExactNotifications()}');
    } else {
      final p = await ios?.checkPermissions();
      note('ios enabled: ${p?.isEnabled} alert: ${p?.isAlertEnabled}');
    }
  }

  Future<void> showNow() async {
    await plugin.show(
      id: 1,
      title: 'ctrlSpend',
      body: 'Shown immediately',
      notificationDetails: details,
      payload: 'now',
    );
    note('show() called');
  }

  Future<void> schedule(AndroidScheduleMode mode, {int minutes = 1}) async {
    final at = tz.TZDateTime.now(tz.local).add(Duration(minutes: minutes));
    try {
      await plugin.zonedSchedule(
        id: 2,
        title: 'Did you spend anything today?',
        body: 'Scheduled for ${at.hour}:${at.minute} (${mode.name})',
        scheduledDate: at,
        notificationDetails: details,
        androidScheduleMode: mode,
        // Repeats daily at this time, like the 9:00 PM reminder.
        matchDateTimeComponents: DateTimeComponents.time,
        payload: 'daily',
      );
      note('scheduled ${mode.name} for $at');
    } on Object catch (e) {
      note('schedule failed: $e');
    }
  }

  Future<void> pending() async {
    final p = await plugin.pendingNotificationRequests();
    note('pending: ${p.map((r) => '${r.id}:${r.title}').join(', ')}');
  }

  @override
  Widget build(BuildContext context) {
    final buttons = <String, VoidCallback>{
      'Request permission': requestPermission,
      'Check permission': checkPermission,
      'Show now': showNow,
      'Schedule +1 min (inexact)': () =>
          schedule(AndroidScheduleMode.inexactAllowWhileIdle),
      'Schedule +1 min (exact)': () =>
          schedule(AndroidScheduleMode.exactAllowWhileIdle),
      if (android != null)
        'Request exact alarms': () async =>
            note('exact: ${await android!.requestExactAlarmsPermission()}'),
      'Pending': pending,
      'Cancel all': () async {
        await plugin.cancelAll();
        note('cancelled all');
      },
    };
    return Scaffold(
      appBar: AppBar(title: Text('Notification spike · ${widget.zone}')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final MapEntry(:key, :value) in buttons.entries)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: FilledButton(onPressed: value, child: Text(key)),
            ),
          const Divider(),
          for (final line in log) Text(line),
        ],
      ),
    );
  }
}
