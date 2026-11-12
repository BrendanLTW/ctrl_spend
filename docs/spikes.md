# Spikes

## 0.9 Local notifications (flutter_local_notifications)

**Status:** builds on both platforms. On-device delivery was **not verified**: the Android emulator couldn't boot (not enough disk space) and the iPhone run was skipped. Throwaway code is on the unmerged branch `spike/notifications` (`flutter run -t lib/spike_notifications.dart`).

### Versions

| Package | Version | Why |
| --- | --- | --- |
| flutter_local_notifications | 22.3.3 | Already in pubspec |
| timezone | 0.11.2 | `zonedSchedule` needs a `TZDateTime` |
| flutter_timezone | 5.1.1 | Reads the device's IANA zone so 9:00 PM means local 9:00 PM |

`timezone` and `flutter_timezone` were approved and added in task 3.8.

### What was verified

- The iOS simulator build launches, reads the zone (`Asia/Kuching`) and initialises the plugin without asking for permission.
- The Android debug APK builds with the manifest changes below.
- The API signatures below were checked against the 22.3.3 source. The README snippets still use the old positional arguments.

### Not verified (re-check in P1 on real devices)

- The permission prompts on Android 13+ and iOS.
- Whether a scheduled notification fires, including with the app killed and after a reboot (Android).
- Exact versus inexact timing on Android.
- Whether the notification icon survives R8 in a release build.

### Setup

**Android** (`android/app/src/main/AndroidManifest.xml`)

- Core library desugaring is required. It is already on in `android/app/build.gradle.kts`.
- compileSdk must be 35 or higher. Flutter's default already meets this.
- The plugin declares `POST_NOTIFICATIONS` and `VIBRATE` itself.
- The app must add the boot permission and two receivers so scheduled alarms survive a reboot or an app update:

```xml
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>

<!-- inside <application> -->
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
        <action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
        <action android:name="android.intent.action.QUICKBOOT_POWERON" />
        <action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
    </intent-filter>
</receiver>
```

- The notification icon needs a monochrome drawable, for example `res/drawable/ic_notification.png`. Add `res/raw/keep.xml` so R8 doesn't strip it in release builds. Don't use `@mipmap/ic_launcher`, which shows as a white square. ProGuard rules have been automatic since v19.

**iOS** (`ios/Runner/AppDelegate.swift`)

- Add `UNUserNotificationCenter.current().delegate = self` in `didFinishLaunchingWithOptions` so notifications show while the app is in the foreground.
- No Info.plist changes are needed.

### API (22.3.3, named parameters only)

```dart
tz.initializeTimeZones();
final zone = await FlutterTimezone.getLocalTimezone();
tz.setLocalLocation(tz.getLocation(zone.identifier));

await plugin.initialize(
  settings: const InitializationSettings(
    android: AndroidInitializationSettings('ic_notification'),
    // false = don't prompt at launch; S07 prompts on a button tap.
    iOS: DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    ),
  ),
  onDidReceiveNotificationResponse: onTap,
);

// Permission (S07 "Turn on notifications")
await plugin
    .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>()
    ?.requestNotificationsPermission();
await plugin
    .resolvePlatformSpecificImplementation<
        IOSFlutterLocalNotificationsPlugin>()
    ?.requestPermissions(alert: true, badge: true, sound: true);

// Daily reminder at 21:00
await plugin.zonedSchedule(
  id: 1,
  title: '…',
  body: '…',
  scheduledDate: next2100, // TZDateTime in tz.local
  notificationDetails: details,
  androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
  matchDateTimeComponents: DateTimeComponents.time, // repeat daily
);
```

- Use `DateTimeComponents.dayOfWeekAndTime` for the weekly summary on Sunday evening.
- A tap that launches the app from a killed state does **not** call `onDidReceiveNotificationResponse`. Read `getNotificationAppLaunchDetails()` at startup instead.
- Status checks: `areNotificationsEnabled()` on Android and `checkPermissions()` on iOS.

### Gotchas

- **Exact alarms (Android 12+):** exact timing needs `SCHEDULE_EXACT_ALARM` plus `requestExactAlarmsPermission()`, which sends the user to system settings. The other option, `USE_EXACT_ALARM`, is restricted by Play to alarm and calendar apps.
- **OEM battery killers:** Xiaomi, Huawei and similar phones can drop alarms (see dontkillmyapp.com). Samsung caps an app at 500 alarms.
- **iOS keeps only 64 pending notifications.** We use about 2 repeating ones, so this is fine.
- **iOS 27:** UNErrorDomain errors (no permission, or badge only) are swallowed by the plugin. Check permission before scheduling instead of relying on errors.
- **Time zone changes:** schedules use the zone read at startup. Re-read it on app resume if travel matters.

### Recommendation for P1 (S07 and §5.4)

- **Daily reminder (9:00 PM) and weekly summary:** use `zonedSchedule` with `inexactAllowWhileIdle`. A few minutes' drift is fine for a reminder, and it avoids asking for the exact-alarm permission. Drop `SCHEDULE_EXACT_ALARM` from the manifest. (The spike branch added it only to test exact timing.)
- **Budget alerts at 80% and 100%:** show them with `show()` right after a transaction is saved, using the shared threshold function. No scheduling is needed.
- **S07 flow:** initialise without prompting. "Turn on notifications" calls the platform permission request, and "Not now" continues without it. Settings can re-check status later.
- **Before P1:** approve `timezone` and `flutter_timezone`, add the monochrome icon and `keep.xml`, and test on one real Android 13+ phone and one iPhone.

### Status after task 3.8

Built into the app: `LocalNotificationScheduler`, the manifest receivers and boot permission, the `ic_notification` vector icon with `res/raw/keep.xml`, and the iOS foreground delegate. Schedules are inexact, so `SCHEDULE_EXACT_ALARM` isn't declared.

**Still to verify on a real Android 13+ phone and an iPhone:** the permission prompt from S07, that the 9:00 PM reminder, the Sunday 7:00 PM summary and the period-start notification fire (also with the app killed and after a reboot on Android), and the icon in a release build.
