import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/attendance_record.dart';

class AttendanceRepository {
  final DatabaseHelper _dbHelper;

  AttendanceRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<AttendanceRecord>> getRecordsByDate(String date) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableAttendanceRecords,
        where: 'date = ?',
        whereArgs: [date],
        orderBy: 'type ASC',
      );
      return results.map((m) => AttendanceRecord.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat absensi tanggal $date: $e');
    }
  }

  Future<AttendanceRecord?> getRecordByDateAndType(String date, String type) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableAttendanceRecords,
        where: 'date = ? AND type = ?',
        whereArgs: [date, type],
        limit: 1,
      );
      if (results.isNotEmpty) {
        return AttendanceRecord.fromMap(results.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException('Gagal memuat absensi: $e');
    }
  }

  Future<AttendanceRecord> recordAttendance({
    required String date,
    required String type,
    required DateTime timestamp,
    String status = AppConstants.statusHadir,
    String? notes,
  }) async {
    try {
      final db = await _dbHelper.database;

      // Check duplicate
      final existing = await getRecordByDateAndType(date, type);
      if (existing != null) {
        throw DuplicateRecordException(
          'Absensi ${type == AppConstants.checkIn ? "Datang" : "Pulang"} untuk tanggal ini sudah pernah dicatat pada pukul ${DateFormatter.formatTime(existing.timestamp)}. Silakan gunakan fitur koreksi jika ingin mengubahnya.',
        );
      }

      final now = DateTime.now();
      final record = AttendanceRecord(
        date: date,
        type: type,
        timestamp: timestamp,
        status: status,
        notes: notes,
        createdAt: now,
        updatedAt: now,
      );

      final id = await db.insert(
        AppConstants.tableAttendanceRecords,
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );

      // Log to activity history
      final typeLabel = type == AppConstants.checkIn ? 'Datang' : 'Pulang';
      final statusLabel = record.statusDisplayName;
      final timeStr = DateFormatter.formatTime(timestamp);

      await db.insert(AppConstants.tableActivityHistory, {
        'timestamp': now.toIso8601String(),
        'action_type': 'attendance_$type',
        'title': 'Absensi $typeLabel Dicatat ($statusLabel)',
        'description': 'Tercatat pada $timeStr untuk tanggal $date${notes != null && notes.isNotEmpty ? " (Catatan: $notes)" : ""}.',
        'metadata': 'record_id:$id',
      });

      return record.copyWith(id: id);
    } on AppException {
      rethrow;
    } catch (e) {
      throw AppDatabaseException('Gagal mencatat absensi: $e');
    }
  }

  Future<void> updateAttendance(AttendanceRecord record) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();
      final map = record.toMap();
      map['updated_at'] = now.toIso8601String();

      await db.update(
        AppConstants.tableAttendanceRecords,
        map,
        where: 'id = ?',
        whereArgs: [record.id],
      );

      // Log correction to history
      final typeLabel = record.isCheckIn ? 'Datang' : 'Pulang';
      await db.insert(AppConstants.tableActivityHistory, {
        'timestamp': now.toIso8601String(),
        'action_type': 'attendance_update',
        'title': 'Koreksi Absensi $typeLabel',
        'description': 'Absensi tanggal ${record.date} berhasil diperbarui.',
        'metadata': 'record_id:${record.id}',
      });
    } catch (e) {
      throw AppDatabaseException('Gagal memperbarui data absensi: $e');
    }
  }

  Future<void> deleteAttendance(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableAttendanceRecords,
        where: 'id = ?',
        whereArgs: [id],
      );
      if (results.isNotEmpty) {
        final rec = AttendanceRecord.fromMap(results.first);
        await db.delete(
          AppConstants.tableAttendanceRecords,
          where: 'id = ?',
          whereArgs: [id],
        );

        await db.insert(AppConstants.tableActivityHistory, {
          'timestamp': DateTime.now().toIso8601String(),
          'action_type': 'attendance_delete',
          'title': 'Hapus Absensi ${rec.typeDisplayName}',
          'description': 'Absensi tanggal ${rec.date} telah dihapus.',
          'metadata': 'record_id:$id',
        });
      }
    } catch (e) {
      throw AppDatabaseException('Gagal menghapus data absensi: $e');
    }
  }

  Future<List<AttendanceRecord>> getAttendanceHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? type,
    String? status,
    String? searchQuery,
  }) async {
    try {
      final db = await _dbHelper.database;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (startDate != null) {
        whereClauses.add('date >= ?');
        whereArgs.add(DateFormatter.toDateKey(startDate));
      }
      if (endDate != null) {
        whereClauses.add('date <= ?');
        whereArgs.add(DateFormatter.toDateKey(endDate));
      }
      if (type != null && type.isNotEmpty && type != 'all') {
        whereClauses.add('type = ?');
        whereArgs.add(type);
      }
      if (status != null && status.isNotEmpty && status != 'all') {
        whereClauses.add('status = ?');
        whereArgs.add(status);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add('(notes LIKE ? OR date LIKE ?)');
        final q = '%${searchQuery.trim()}%';
        whereArgs.addAll([q, q]);
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final results = await db.query(
        AppConstants.tableAttendanceRecords,
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC, timestamp DESC',
      );

      return results.map((m) => AttendanceRecord.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat riwayat absensi: $e');
    }
  }

  Future<List<AttendanceRecord>> getAllRecords() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableAttendanceRecords,
        orderBy: 'date DESC, timestamp DESC',
      );
      return results.map((m) => AttendanceRecord.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat semua rekaman absensi: $e');
    }
  }
}
