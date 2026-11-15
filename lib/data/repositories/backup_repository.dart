import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../database/database_helper.dart';

class BackupRepository {
  final DatabaseHelper _dbHelper;

  BackupRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<Map<String, dynamic>> generateBackupMap() async {
    try {
      final db = await _dbHelper.database;

      final settings = await db.query(AppConstants.tableSettings);
      final schedules = await db.query(AppConstants.tableReminderSchedules);
      final attendance = await db.query(AppConstants.tableAttendanceRecords);
      final logbooks = await db.query(AppConstants.tableLogbookEntries);
      final history = await db.query(AppConstants.tableActivityHistory);

      return {
        'app_name': AppConstants.appName,
        'app_version': AppConstants.appVersion,
        'database_version': AppConstants.databaseVersion,
        'exported_at': DateTime.now().toIso8601String(),
        'settings': settings,
        'reminder_schedules': schedules,
        'attendance_records': attendance,
        'logbook_entries': logbooks,
        'activity_history': history,
      };
    } catch (e) {
      throw AppDatabaseException('Gagal membuat data backup: $e');
    }
  }

  Future<bool> restoreFromBackupMap(Map<String, dynamic> data, {bool replaceAll = true}) async {
    try {
      // Validation
      if (data['app_name'] != AppConstants.appName) {
        throw const ValidationException('Format berkas backup tidak valid untuk aplikasi RAMA.');
      }

      final db = await _dbHelper.database;

      await db.transaction((txn) async {
        if (replaceAll) {
          // Clear current tables safely
          await txn.delete(AppConstants.tableAttendanceRecords);
          await txn.delete(AppConstants.tableLogbookEntries);
          await txn.delete(AppConstants.tableReminderSchedules);
          await txn.delete(AppConstants.tableSettings);
        }

        // Restore Settings
        if (data['settings'] is List) {
          for (final row in data['settings'] as List) {
            final map = Map<String, dynamic>.from(row as Map);
            await txn.insert(
              AppConstants.tableSettings,
              map,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore Schedules
        if (data['reminder_schedules'] is List) {
          for (final row in data['reminder_schedules'] as List) {
            final map = Map<String, dynamic>.from(row as Map);
            await txn.insert(
              AppConstants.tableReminderSchedules,
              map,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore Attendance
        if (data['attendance_records'] is List) {
          for (final row in data['attendance_records'] as List) {
            final map = Map<String, dynamic>.from(row as Map);
            await txn.insert(
              AppConstants.tableAttendanceRecords,
              map,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Restore Logbook
        if (data['logbook_entries'] is List) {
          for (final row in data['logbook_entries'] as List) {
            final map = Map<String, dynamic>.from(row as Map);
            await txn.insert(
              AppConstants.tableLogbookEntries,
              map,
              conflictAlgorithm: ConflictAlgorithm.replace,
            );
          }
        }

        // Insert history record of the restore
        await txn.insert(AppConstants.tableActivityHistory, {
          'timestamp': DateTime.now().toIso8601String(),
          'action_type': 'backup_restore',
          'title': 'Pemulihan Data Berhasil',
          'description': 'Data absensi, logbook, dan pengaturan berhasil dipulihkan dari cadangan.',
          'metadata': 'exported_at:${data['exported_at']}',
        });
      });

      return true;
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppDatabaseException('Gagal memulihkan cadangan: $e');
    }
  }

  Future<String> exportAttendanceToCsv() async {
    try {
      final db = await _dbHelper.database;
      final records = await db.query(
        AppConstants.tableAttendanceRecords,
        orderBy: 'date DESC, timestamp DESC',
      );

      final buffer = StringBuffer();
      buffer.writeln('ID,Tanggal,Jenis Absensi,Waktu Konfirmasi,Status Kehadiran,Catatan');

      for (final r in records) {
        final id = r['id'];
        final date = r['date'];
        final type = r['type'] == 'check_in' ? 'Datang' : 'Pulang';
        final timestamp = r['timestamp'];
        final status = r['status'];
        final notes = (r['notes'] ?? '').toString().replaceAll('"', '""');
        buffer.writeln('$id,$date,$type,$timestamp,$status,"$notes"');
      }

      return buffer.toString();
    } catch (e) {
      throw AppDatabaseException('Gagal mengekspor data absensi ke CSV: $e');
    }
  }

  Future<String> exportLogbookToCsv() async {
    try {
      final db = await _dbHelper.database;
      final entries = await db.query(
        AppConstants.tableLogbookEntries,
        orderBy: 'date DESC',
      );

      final buffer = StringBuffer();
      buffer.writeln('ID,Tanggal,Uraian Aktivitas,Pembelajaran,Kendala,Status');

      for (final e in entries) {
        final id = e['id'];
        final date = e['date'];
        final act = (e['activities'] ?? '').toString().replaceAll('"', '""');
        final lrn = (e['learnings'] ?? '').toString().replaceAll('"', '""');
        final obs = (e['obstacles'] ?? '').toString().replaceAll('"', '""');
        final status = e['status'];
        buffer.writeln('$id,$date,"$act","$lrn","$obs",$status');
      }

      return buffer.toString();
    } catch (e) {
      throw AppDatabaseException('Gagal mengekspor data logbook ke CSV: $e');
    }
  }
}
