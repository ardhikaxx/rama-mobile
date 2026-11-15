import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  static Future<bool> requestNotificationPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.notification.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.notification.request();
    return result.isGranted;
  }

  static Future<bool> isNotificationGranted() async {
    if (!Platform.isAndroid) return true;
    return await Permission.notification.isGranted;
  }

  static Future<bool> requestExactAlarmPermission() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.scheduleExactAlarm.request();
    return result.isGranted;
  }

  static Future<bool> isExactAlarmGranted() async {
    if (!Platform.isAndroid) return true;
    return await Permission.scheduleExactAlarm.isGranted;
  }

  static Future<bool> requestIgnoreBatteryOptimizations() async {
    if (!Platform.isAndroid) return true;

    final status = await Permission.ignoreBatteryOptimizations.status;
    if (status.isGranted) {
      return true;
    }

    final result = await Permission.ignoreBatteryOptimizations.request();
    return result.isGranted;
  }

  static Future<bool> isBatteryOptimizationIgnored() async {
    if (!Platform.isAndroid) return true;
    return await Permission.ignoreBatteryOptimizations.isGranted;
  }

  static Future<void> openAppSettingsPage() async {
    await openAppSettings();
  }
}
