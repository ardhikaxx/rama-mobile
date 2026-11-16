import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../../core/constants/app_constants.dart';
import '../data/models/reminder_schedule.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._init();
  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Stream for handling payload clicks
  final StreamController<String?> _payloadStreamController =
      StreamController<String?>.broadcast();

  Stream<String?> get payloadStream => _payloadStreamController.stream;

  bool _isInitialized = false;

  NotificationService._init();

  Future<void> initialize() async {
    if (_isInitialized) return;

    // 1. Timezone setup
    try {
      tz.initializeTimeZones();
      String timeZoneName = 'Asia/Jakarta';
      try {
        final tzInfo = await FlutterTimezone.getLocalTimezone();
        timeZoneName = tzInfo.identifier;
      } catch (e) {
        debugPrint('Could not get local timezone, defaulting to Asia/Jakarta: $e');
      }
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      debugPrint('Error configuring timezone: $e');
    }

    // 2. Local Notifications initialization
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
      macOS: darwinSettings,
    );

    await _notificationsPlugin.initialize(
      settings: initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        if (response.payload != null) {
          _payloadStreamController.add(response.payload);
        }
      },
    );

    // 3. Create high-importance Android notification channel explicitly
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      const channel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      );
      await androidPlugin.createNotificationChannel(channel);
    }

    _isInitialized = true;
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool sound = true,
    bool vibration = true,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      AppConstants.notificationChannelId,
      AppConstants.notificationChannelName,
      channelDescription: AppConstants.notificationChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(presentSound: sound),
    );

    await _notificationsPlugin.show(
      id: id,
      title: title,
      body: body,
      notificationDetails: details,
      payload: payload,
    );
  }

  Future<void> scheduleWeeklyReminders({
    required ReminderSchedule schedule,
    bool sound = true,
    bool vibration = true,
  }) async {
    if (!schedule.isEnabled) {
      await cancelRemindersForType(schedule.type);
      return;
    }

    // Cancel existing weekly alarms for this type first
    await cancelRemindersForType(schedule.type);

    final baseId = _getBaseIdForType(schedule.type);
    final payload = _getPayloadForType(schedule.type);

    for (final day in schedule.activeDays) {
      final notificationId = baseId + day;
      final scheduledDate = _nextInstanceOfDayAndTime(day, schedule.hour, schedule.minute);

      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: sound,
        enableVibration: vibration,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentSound: sound),
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: schedule.title,
          body: schedule.message,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
          payload: payload,
        );
      } catch (e) {
        // Fallback to inexact if exact alarm permission is missing on Android 12+
        debugPrint('Exact alarm failed, falling back to inexact: $e');
        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: schedule.title,
            body: schedule.message,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: payload,
          );
        } catch (err) {
          debugPrint('Failed to schedule notification: $err');
        }
      }
    }
  }

  Future<void> scheduleSnoozeReminders({
    required String type,
    required String title,
    required String message,
    required int intervalMinutes,
    int maxCount = 5,
    bool sound = true,
    bool vibration = true,
  }) async {
    await cancelSnoozeForType(type);

    final snoozeBaseId = _getSnoozeBaseId(type);
    final payload = _getPayloadForType(type);
    final now = tz.TZDateTime.now(tz.local);

    for (int i = 1; i <= maxCount; i++) {
      final notificationId = snoozeBaseId + i;
      final scheduledDate = now.add(Duration(minutes: intervalMinutes * i));

      final androidDetails = AndroidNotificationDetails(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        channelDescription: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        priority: Priority.high,
        playSound: sound,
        enableVibration: vibration,
      );

      final details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(presentSound: sound),
      );

      try {
        await _notificationsPlugin.zonedSchedule(
          id: notificationId,
          title: '$title (Pengingat Ke-$i)',
          body: message,
          scheduledDate: scheduledDate,
          notificationDetails: details,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          payload: payload,
        );
      } catch (e) {
        debugPrint('Error scheduling snooze: $e');
      }
    }
  }

  Future<void> cancelRemindersForType(String type) async {
    final baseId = _getBaseIdForType(type);
    for (int day = 1; day <= 7; day++) {
      await _notificationsPlugin.cancel(id: baseId + day);
    }
    await cancelSnoozeForType(type);
  }

  Future<void> cancelSnoozeForType(String type) async {
    final snoozeBaseId = _getSnoozeBaseId(type);
    for (int i = 1; i <= AppConstants.maxSnoozeCount; i++) {
      await _notificationsPlugin.cancel(id: snoozeBaseId + i);
    }
  }

  Future<void> cancelAll() async {
    await _notificationsPlugin.cancelAll();
  }

  int _getBaseIdForType(String type) {
    switch (type) {
      case AppConstants.reminderCheckIn:
        return 100;
      case AppConstants.reminderCheckOut:
        return 200;
      case AppConstants.reminderLogbook:
        return 300;
      default:
        return 400;
    }
  }

  int _getSnoozeBaseId(String type) {
    switch (type) {
      case AppConstants.reminderCheckIn:
        return 110;
      case AppConstants.reminderCheckOut:
        return 210;
      case AppConstants.reminderLogbook:
        return 310;
      default:
        return 410;
    }
  }

  String _getPayloadForType(String type) {
    switch (type) {
      case AppConstants.reminderCheckIn:
        return AppConstants.payloadCheckIn;
      case AppConstants.reminderCheckOut:
        return AppConstants.payloadCheckOut;
      case AppConstants.reminderLogbook:
        return AppConstants.payloadLogbook;
      default:
        return '';
    }
  }

  tz.TZDateTime _nextInstanceOfDayAndTime(int dayOfWeek, int hour, int minute) {
    tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate =
        tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (scheduledDate.weekday != dayOfWeek || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
