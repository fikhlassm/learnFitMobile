import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class ReminderNotificationService {
  ReminderNotificationService._();

  static final ReminderNotificationService instance = ReminderNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    final localTimezone = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(localTimezone.identifier));

    const android = AndroidInitializationSettings('@mipmap/launcher_icon');
    const darwin = DarwinInitializationSettings();
    const linux = LinuxInitializationSettings(defaultActionName: 'Open LearnFit');
    const windows = WindowsInitializationSettings(
      appName: 'LearnFit',
      appUserModelId: 'com.example.learnfitmob',
      guid: 'c5cc9ce3-1665-4f05-8d3f-a2a8bc2837d0',
    );

    await _plugin.initialize(
      settings: const InitializationSettings(
        android: android,
        iOS: darwin,
        macOS: darwin,
        linux: linux,
        windows: windows,
      ),
    );
    _initialized = true;
  }

  Future<bool> requestPermission() async {
    if (kIsWeb) {
      final web = _plugin.resolvePlatformSpecificImplementation<WebFlutterLocalNotificationsPlugin>();
      return await web?.requestNotificationsPermission() ?? true;
    }

    final android = _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final androidGranted = await android?.requestNotificationsPermission();

    final darwin = _plugin.resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>();
    final iosGranted = await darwin?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin.resolvePlatformSpecificImplementation<MacOSFlutterLocalNotificationsPlugin>();
    final macosGranted = await macos?.requestPermissions(alert: true, badge: true, sound: true);

    return androidGranted ?? iosGranted ?? macosGranted ?? true;
  }

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<void> scheduleDailyTarget({
    required int hour,
    required int minute,
    required bool weekdaysOnly,
    required bool includeStreakCopy,
  }) async {
    await _ensureReady();
    await _scheduleRepeating(
      baseId: 100,
      hour: hour,
      minute: minute,
      weekdaysOnly: weekdaysOnly,
      title: 'Waktunya belajar',
      body: includeStreakCopy
          ? 'Jaga streak kamu dan capai target belajar hari ini.'
          : 'Ayo capai target belajar harianmu di LearnFit.',
    );
  }

  Future<void> scheduleStreakOnly({
    required int hour,
    required int minute,
    required bool weekdaysOnly,
  }) async {
    await _ensureReady();
    await _scheduleRepeating(
      baseId: 200,
      hour: hour,
      minute: minute,
      weekdaysOnly: weekdaysOnly,
      title: 'Jangan putus streak',
      body: 'Selesaikan satu sesi belajar untuk menjaga streak kamu.',
    );
  }

  Future<void> _ensureReady() async {
    if (!_initialized) await init();
  }

  Future<void> _scheduleRepeating({
    required int baseId,
    required int hour,
    required int minute,
    required bool weekdaysOnly,
    required String title,
    required String body,
  }) async {
    final weekdays = weekdaysOnly ? [1, 2, 3, 4, 5] : [1, 2, 3, 4, 5, 6, 7];

    for (final weekday in weekdays) {
      await _plugin.zonedSchedule(
        id: baseId + weekday,
        title: title,
        body: body,
        scheduledDate: _nextInstanceOfWeekday(weekday, hour, minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'study_reminders',
            'Study Reminders',
            channelDescription: 'Daily LearnFit study reminder notifications',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
          macOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    while (scheduled.weekday != weekday || scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
