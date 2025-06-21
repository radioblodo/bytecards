import 'dart:io';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:device_info_plus/device_info_plus.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static Future<void> init() async {
    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidInit);

    await _plugin.initialize(initSettings);
  }

  /// Call this once before scheduling the first exact alarm
  static Future<void> checkAndRequestExactAlarmPermission() async {
    // If the device is IOS, skip executing the rest
    if (!Platform.isAndroid) return;

    final prefs = await SharedPreferences.getInstance();
    final alreadyPrompted = prefs.getBool('alarmPermissionPrompted') ?? false;

    final androidInfo = await DeviceInfoPlugin().androidInfo;
    if (androidInfo.version.sdkInt >= 31 && !alreadyPrompted) {
      final intent = AndroidIntent(
        action: 'android.settings.REQUEST_SCHEDULE_EXACT_ALARM',
      );
      await intent.launch();

      // Save to avoid re-opening
      await prefs.setBool('alarmPermissionPrompted', true);
    }
  }

  static Future<void> scheduleReminder(Duration interval) async {
    final scheduled = tz.TZDateTime.now(tz.local).add(interval);

    await _plugin.zonedSchedule(
      0,
      '⏰ Time to Review!',
      'Don’t forget to review your flashcards today.',
      scheduled,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_review_channel',
          'Daily Reviews',
          channelDescription: 'Reminder to review flashcards',
          importance: Importance.max,
          priority: Priority.high,
          ticker: 'ticker',
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: null, // 👈 Do NOT use time/date matching
    );
  }

  static Future<void> cancelAllReminders() async {
    await _plugin.cancelAll();
  }

  static Future<void> requestNotificationPermissions() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;

      if (androidInfo.version.sdkInt >= 33) {
        final status = await Permission.notification.request();
        if (!status.isGranted) {
          return;
        } else {}
      }

      if (androidInfo.version.sdkInt >= 31) {
        final status = await Permission.scheduleExactAlarm.status;
        if (!status.isGranted) {
        } else {}
      }
    }
  }
}
