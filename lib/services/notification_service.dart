import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tzdata;

import '../models/alarm.dart';

/// Uyg'otqichlarni tizim bildirishnomasi orqali chalish uchun xizmat.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    tzdata.initializeTimeZones();
    try {
      final String localTz = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(localTz));
    } catch (_) {
      tz.setLocalLocation(tz.getLocation('Asia/Tashkent'));
    }

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );
    await _plugin.initialize(initSettings);

    final androidImpl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidImpl?.requestNotificationsPermission();
    await androidImpl?.requestExactAlarmsPermission();

    _initialized = true;
  }

  Future<void> scheduleAlarm(AlarmModel alarm) async {
    await cancelAlarm(alarm.id);
    if (!alarm.enabled) return;

    const androidDetails = AndroidNotificationDetails(
      'alarm_channel',
      "Uyg'otqich",
      channelDescription: "Uyg'otqich signal kanali",
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      fullScreenIntent: true,
      category: AndroidNotificationCategory.alarm,
    );
    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentSound: true,
    );
    const details =
        NotificationDetails(android: androidDetails, iOS: iosDetails);

    if (!alarm.hasRepeat) {
      final scheduled = _nextInstance(alarm.hour, alarm.minute);
      await _plugin.zonedSchedule(
        alarm.id,
        alarm.label.isEmpty ? "Uyg'otqich" : alarm.label,
        scheduled.toString().substring(11, 16),
        scheduled,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
      );
    } else {
      // Har bir tanlangan hafta kuni uchun alohida (id + kun) notification
      for (int i = 0; i < 7; i++) {
        if (!alarm.repeatDays[i]) continue;
        final weekday = i + 1; // DateTime.monday == 1
        final scheduled =
            _nextInstanceOfWeekday(alarm.hour, alarm.minute, weekday);
        await _plugin.zonedSchedule(
          alarm.id * 10 + weekday,
          alarm.label.isEmpty ? "Uyg'otqich" : alarm.label,
          scheduled.toString().substring(11, 16),
          scheduled,
          details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
        );
      }
    }
  }

  Future<void> cancelAlarm(int id) async {
    await _plugin.cancel(id);
    for (int weekday = 1; weekday <= 7; weekday++) {
      await _plugin.cancel(id * 10 + weekday);
    }
  }

  tz.TZDateTime _nextInstance(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  tz.TZDateTime _nextInstanceOfWeekday(int hour, int minute, int weekday) {
    var scheduled = _nextInstance(hour, minute);
    while (scheduled.weekday != weekday) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}
