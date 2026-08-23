import 'package:adhan_dart/adhan_dart.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

/// Service for handling local prayer notifications and adhkar reminders safely.
class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static bool _isInitialized = false;

  /// Initializes the local notification plugin and timezone database safely.
  static Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      tz.initializeTimeZones();
    } catch (_) {}

    try {
      const androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');
      const darwinSettings = DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      );

      const initSettings = InitializationSettings(
        android: androidSettings,
        iOS: darwinSettings,
      );

      await _notifications.initialize(initSettings);

      const androidChannel = AndroidNotificationChannel(
        'prayer_channel_id',
        'تنبيهات مواقيت الصلاة والأذكار',
        description: 'إشعارات حلول مواقيت الصلاة وأذكار اليوم والليلة',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        await androidImplementation.createNotificationChannel(androidChannel);
        await androidImplementation.requestNotificationsPermission();
      }

      _isInitialized = true;
    } catch (_) {
      // Graceful fallback
    }
  }

  /// Explicitly requests notification permissions on Android 13+ / iOS
  static Future<bool?> requestPermissions() async {
    try {
      final androidImplementation =
          _notifications.resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>();

      if (androidImplementation != null) {
        return await androidImplementation.requestNotificationsPermission();
      }
    } catch (_) {}
    return true;
  }

  /// Shows an instant notification.
  static Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const androidDetails = AndroidNotificationDetails(
        'prayer_channel_id',
        'تنبيهات مواقيت الصلاة والأذكار',
        channelDescription: 'إشعارات حلول مواقيت الصلاة وأذكار اليوم والليلة',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.show(
        id,
        title,
        body,
        details,
        payload: payload,
      );
    } catch (_) {}
  }

  /// Schedules daily recurring notifications for all 5 daily prayers
  static Future<void> scheduleAllDailyPrayers(PrayerTimes prayerTimes) async {
    final prayers = [
      (1, 'صلاة الفجر', prayerTimes.fajr.toLocal()),
      (2, 'صلاة الظهر', prayerTimes.dhuhr.toLocal()),
      (3, 'صلاة العصر', prayerTimes.asr.toLocal()),
      (4, 'صلاة المغرب', prayerTimes.maghrib.toLocal()),
      (5, 'صلاة العشاء', prayerTimes.isha.toLocal()),
    ];

    for (final p in prayers) {
      await scheduleDailyPrayerNotification(
        id: p.$1,
        prayerName: p.$2,
        prayerTime: p.$3,
      );
    }
  }

  /// Schedules a daily recurring prayer notification.
  static Future<void> scheduleDailyPrayerNotification({
    required int id,
    required String prayerName,
    required DateTime prayerTime,
  }) async {
    try {
      final now = DateTime.now();
      var scheduled = DateTime(
        now.year,
        now.month,
        now.day,
        prayerTime.hour,
        prayerTime.minute,
      );

      if (scheduled.isBefore(now)) {
        scheduled = scheduled.add(const Duration(days: 1));
      }

      final tzLocation = tz.local;
      final scheduledTz = tz.TZDateTime.from(scheduled, tzLocation);

      const androidDetails = AndroidNotificationDetails(
        'prayer_channel_id',
        'تنبيهات مواقيت الصلاة والأذكار',
        channelDescription: 'إشعارات حلول مواقيت الصلاة وأذكار اليوم والليلة',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
      );

      const details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      );

      await _notifications.zonedSchedule(
        id,
        'حان الآن وقت $prayerName 🕌',
        'حي على الصلاة، حي على الفلاح',
        scheduledTz,
        details,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    } catch (_) {
      // Fallback
    }
  }

  static Future<void> cancelAll() async {
    try {
      await _notifications.cancelAll();
    } catch (_) {}
  }

  static Future<void> cancel(int id) async {
    try {
      await _notifications.cancel(id);
    } catch (_) {}
  }
}
