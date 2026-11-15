import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../database/database_helper.dart';
import '../models/reminder_schedule.dart';

class ReminderRepository {
  final DatabaseHelper _dbHelper;

  ReminderRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<ReminderSchedule>> getAllSchedules() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableReminderSchedules,
        orderBy: 'id ASC',
      );

      if (results.isEmpty) {
        // Re-seed defaults if table is unexpectedly empty
        final defaults = ReminderSchedule.defaultSchedules();
        for (final schedule in defaults) {
          await db.insert(AppConstants.tableReminderSchedules, schedule.toMap());
        }
        return defaults;
      }

      return results.map((m) => ReminderSchedule.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat jadwal pengingat: $e');
    }
  }

  Future<ReminderSchedule?> getScheduleByType(String type) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableReminderSchedules,
        where: 'type = ?',
        whereArgs: [type],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return ReminderSchedule.fromMap(results.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException('Gagal memuat jadwal $type: $e');
    }
  }

  Future<void> updateSchedule(ReminderSchedule schedule) async {
    try {
      final db = await _dbHelper.database;
      final map = schedule.toMap();
      map['updated_at'] = DateTime.now().toIso8601String();

      await db.update(
        AppConstants.tableReminderSchedules,
        map,
        where: 'type = ?',
        whereArgs: [schedule.type],
      );
    } catch (e) {
      throw AppDatabaseException('Gagal memperbarui jadwal pengingat: $e');
    }
  }

  Future<void> toggleSchedule(String type, bool isEnabled) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        AppConstants.tableReminderSchedules,
        {
          'is_enabled': isEnabled ? 1 : 0,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'type = ?',
        whereArgs: [type],
      );
    } catch (e) {
      throw AppDatabaseException('Gagal mengubah status pengingat: $e');
    }
  }

  Future<void> updateTime(String type, String time) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        AppConstants.tableReminderSchedules,
        {
          'time': time,
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'type = ?',
        whereArgs: [type],
      );
    } catch (e) {
      throw AppDatabaseException('Gagal memperbarui waktu pengingat: $e');
    }
  }

  Future<void> updateActiveDays(String type, List<int> days) async {
    try {
      final db = await _dbHelper.database;
      await db.update(
        AppConstants.tableReminderSchedules,
        {
          'active_days': days.join(','),
          'updated_at': DateTime.now().toIso8601String(),
        },
        where: 'type = ?',
        whereArgs: [type],
      );
    } catch (e) {
      throw AppDatabaseException('Gagal memperbarui hari aktif pengingat: $e');
    }
  }
}
