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

  // Tactile double-pulse vibration: 0ms wait, 500ms vibrate, 250ms pause, 500ms vibrate
  static final Int64List _vibrationPattern =
      Int64List.fromList([0, 500, 250, 500]);

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

    // 3. Create high-importance Android notification channels explicitly
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      // Standard channel (sound + tactile vibration)
      final standardChannel = AndroidNotificationChannel(
        AppConstants.notificationChannelId,
        AppConstants.notificationChannelName,
        description: AppConstants.notificationChannelDescription,
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
      );

      // Silent channel for workplace/jam kerja (hanya getar tanpa suara)
      final silentChannel = AndroidNotificationChannel(
        AppConstants.notificationChannelSilentId,
        AppConstants.notificationChannelSilentName,
        description: AppConstants.notificationChannelSilentDescription,
        importance: Importance.high,
        playSound: false,
        enableVibration: true,
        vibrationPattern: _vibrationPattern,
      );

      await androidPlugin.createNotificationChannel(standardChannel);
      await androidPlugin.createNotificationChannel(silentChannel);
    }

    _isInitialized = true;
  }

  AndroidNotificationDetails _buildAndroidDetails({
    required bool sound,
    required bool vibration,
  }) {
    final channelId = sound
        ? AppConstants.notificationChannelId
        : AppConstants.notificationChannelSilentId;
    final channelName = sound
        ? AppConstants.notificationChannelName
        : AppConstants.notificationChannelSilentName;
    final channelDesc = sound
        ? AppConstants.notificationChannelDescription
        : AppConstants.notificationChannelSilentDescription;

    return AndroidNotificationDetails(
      channelId,
      channelName,
      channelDescription: channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      playSound: sound,
      enableVibration: vibration,
      vibrationPattern: vibration ? _vibrationPattern : null,
      category: AndroidNotificationCategory.reminder,
      visibility: NotificationVisibility.public,
      ticker: 'Pengingat RAMA',
    );
  }

  Future<void> showInstantNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool sound = true,
    bool vibration = true,
  }) async {
    final androidDetails = _buildAndroidDetails(sound: sound, vibration: vibration);

    final details = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentSound: sound,
        presentAlert: true,
        presentBadge: true,
      ),
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

    final totalMinutes = schedule.hour * 60 + schedule.minute;
    // 4 Tahap Pengingat (Dimulai 1 jam sebelum pulang s/d jam pulang):
    // 0: 1 jam sebelum pulang (-60m)
    // 1: Pengingat ke-2 (-40m)
    // 2: Pengingat ke-3 (-20m)
    // 3: Tepat saat jam pulang (0m)
    final intervalOffsets = [-60, -40, -20, 0];

    for (final day in schedule.activeDays) {
      for (int step = 0; step < intervalOffsets.length; step++) {
        var stepMin = totalMinutes + intervalOffsets[step];
        if (stepMin < 0) stepMin += 24 * 60;
        final targetHour = (stepMin ~/ 60) % 24;
        final targetMinute = stepMin % 60;

        final notificationId = baseId + (day * 10) + step;
        final scheduledDate = _nextInstanceOfDayAndTime(day, targetHour, targetMinute);

        String stepTitle;
        String stepBody;

        if (schedule.type == AppConstants.reminderAttendance ||
            schedule.type == AppConstants.reminderCheckOut) {
          switch (step) {
            case 0:
              stepTitle = '⏰ 1 Jam Menuju Jam Pulang (${schedule.time})';
              stepBody = 'Waktunya persiapan absensi magang sebelum pulang hari ini.';
              break;
            case 1:
              stepTitle = '⏰ Pengingat ke-2: Absensi Magang';
              stepBody =
                  'Masih ada 40 menit sebelum pulang. Jangan lupa konfirmasi presensi kehadiran magang.';
              break;
            case 2:
              stepTitle = '⏰ Pengingat ke-3: Absensi Magang';
              stepBody =
                  '20 menit lagi menuju jam pulang! Pastikan presensi kehadiran magang Anda sudah tercatat.';
              break;
            default:
              stepTitle = '⏰ Waktunya Jam Pulang Magang (${schedule.time})!';
              stepBody =
                  'Jam kerja telah usai! Konfirmasi absensi sebelum meninggalkan lokasi magang.';
          }
        } else {
          switch (step) {
            case 0:
              stepTitle = '📝 1 Jam Menuju Jam Pulang (${schedule.time})';
              stepBody =
                  'Yuk mulai rangkum dan dokumentasikan aktivitas logbook magang Anda hari ini.';
              break;
            case 1:
              stepTitle = '📝 Pengingat ke-2: Pengisian Logbook';
              stepBody =
                  'Masih ada 40 menit sebelum pulang. Cicil penulisan pembelajaran dan aktivitas di logbook.';
              break;
            case 2:
              stepTitle = '📝 Pengingat ke-3: Siapkan Logbook Magang';
              stepBody =
                  '20 menit lagi menuju jam pulang. Pastikan uraian logbook sudah siap disalin/dikirim.';
              break;
            default:
              stepTitle = '📝 Jam Pulang Magang (${schedule.time})!';
              stepBody =
                  'Waktunya pulang! Jangan lupa simpan atau kirimkan laporan logbook harian Anda.';
          }
        }

        final androidDetails = _buildAndroidDetails(sound: sound, vibration: vibration);
        final details = NotificationDetails(
          android: androidDetails,
          iOS: DarwinNotificationDetails(
            presentSound: sound,
            presentAlert: true,
            presentBadge: true,
          ),
        );

        try {
          await _notificationsPlugin.zonedSchedule(
            id: notificationId,
            title: stepTitle,
            body: stepBody,
            scheduledDate: scheduledDate,
            notificationDetails: details,
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            payload: payload,
          );
        } catch (e) {
          debugPrint('Exact alarm failed, falling back to inexact: $e');
          try {
            await _notificationsPlugin.zonedSchedule(
              id: notificationId,
              title: stepTitle,
              body: stepBody,
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

      final androidDetails = _buildAndroidDetails(sound: sound, vibration: vibration);

      final details = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(
          presentSound: sound,
          presentAlert: true,
          presentBadge: true,
        ),
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
      for (int step = 0; step < 4; step++) {
        await _notificationsPlugin.cancel(id: baseId + (day * 10) + step);
      }
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
