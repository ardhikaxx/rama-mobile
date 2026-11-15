import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/database_helper.dart';
import '../data/repositories/activity_history_repository.dart';
import '../data/repositories/attendance_repository.dart';
import '../data/repositories/backup_repository.dart';
import '../data/repositories/logbook_repository.dart';
import '../data/repositories/reminder_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../services/export_service.dart';
import '../services/notification_service.dart';

// Database & Service Singletons
final databaseHelperProvider = Provider<DatabaseHelper>((ref) {
  return DatabaseHelper.instance;
});

final settingsRepositoryProvider = Provider<SettingsRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return SettingsRepository(dbHelper: db);
});

final reminderRepositoryProvider = Provider<ReminderRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return ReminderRepository(dbHelper: db);
});

final attendanceRepositoryProvider = Provider<AttendanceRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return AttendanceRepository(dbHelper: db);
});

final logbookRepositoryProvider = Provider<LogbookRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return LogbookRepository(dbHelper: db);
});

final activityHistoryRepositoryProvider = Provider<ActivityHistoryRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return ActivityHistoryRepository(dbHelper: db);
});

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  final db = ref.watch(databaseHelperProvider);
  return BackupRepository(dbHelper: db);
});

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService.instance;
});

final exportServiceProvider = Provider<ExportService>((ref) {
  final backupRepo = ref.watch(backupRepositoryProvider);
  return ExportService(backupRepository: backupRepo);
});
