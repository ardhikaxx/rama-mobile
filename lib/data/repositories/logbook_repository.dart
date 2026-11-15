import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/logbook_entry.dart';

class LogbookRepository {
  final DatabaseHelper _dbHelper;

  LogbookRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<LogbookEntry?> getLogbookByDate(String date) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableLogbookEntries,
        where: 'date = ?',
        whereArgs: [date],
        limit: 1,
      );

      if (results.isNotEmpty) {
        return LogbookEntry.fromMap(results.first);
      }
      return null;
    } catch (e) {
      throw AppDatabaseException('Gagal memuat logbook tanggal $date: $e');
    }
  }

  Future<LogbookEntry> saveLogbook(LogbookEntry entry) async {
    try {
      final db = await _dbHelper.database;
      final existing = await getLogbookByDate(entry.date);
      final now = DateTime.now();

      if (existing != null) {
        // Update existing entry
        final updated = entry.copyWith(
          id: existing.id,
          updatedAt: now,
        );

        await db.update(
          AppConstants.tableLogbookEntries,
          updated.toMap(),
          where: 'id = ?',
          whereArgs: [existing.id],
        );

        await db.insert(AppConstants.tableActivityHistory, {
          'timestamp': now.toIso8601String(),
          'action_type': 'logbook_update',
          'title': 'Pembaruan Logbook Harian',
          'description': 'Laporan aktivitas untuk tanggal ${entry.date} diperbarui.',
          'metadata': 'entry_id:${existing.id}',
        });

        return updated;
      } else {
        // Insert new entry
        final map = entry.toMap();
        map['created_at'] = now.toIso8601String();
        map['updated_at'] = now.toIso8601String();

        final id = await db.insert(
          AppConstants.tableLogbookEntries,
          map,
          conflictAlgorithm: ConflictAlgorithm.replace,
        );

        await db.insert(AppConstants.tableActivityHistory, {
          'timestamp': now.toIso8601String(),
          'action_type': 'logbook_created',
          'title': 'Logbook Harian Dibuat',
          'description': 'Laporan aktivitas magang untuk tanggal ${entry.date} berhasil disimpan.',
          'metadata': 'entry_id:$id',
        });

        return entry.copyWith(id: id);
      }
    } catch (e) {
      throw AppDatabaseException('Gagal menyimpan logbook: $e');
    }
  }

  Future<void> updateStatus(String date, String newStatus) async {
    try {
      final db = await _dbHelper.database;
      final now = DateTime.now();

      await db.update(
        AppConstants.tableLogbookEntries,
        {
          'status': newStatus,
          'updated_at': now.toIso8601String(),
        },
        where: 'date = ?',
        whereArgs: [date],
      );

      String actionTitle = 'Status Logbook Diperbarui';
      if (newStatus == AppConstants.logbookCopied) {
        actionTitle = 'Laporan Disalin ke Clipboard';
      } else if (newStatus == AppConstants.logbookSubmitted) {
        actionTitle = 'Laporan Ditandai Terkirim';
      }

      await db.insert(AppConstants.tableActivityHistory, {
        'timestamp': now.toIso8601String(),
        'action_type': 'logbook_$newStatus',
        'title': actionTitle,
        'description': 'Logbook tanggal $date ditandai sebagai $newStatus.',
        'metadata': 'date:$date',
      });
    } catch (e) {
      throw AppDatabaseException('Gagal memperbarui status logbook: $e');
    }
  }

  Future<void> deleteLogbook(int id) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableLogbookEntries,
        where: 'id = ?',
        whereArgs: [id],
      );

      if (results.isNotEmpty) {
        final entry = LogbookEntry.fromMap(results.first);
        await db.delete(
          AppConstants.tableLogbookEntries,
          where: 'id = ?',
          whereArgs: [id],
        );

        await db.insert(AppConstants.tableActivityHistory, {
          'timestamp': DateTime.now().toIso8601String(),
          'action_type': 'logbook_delete',
          'title': 'Hapus Logbook',
          'description': 'Logbook tanggal ${entry.date} telah dihapus.',
          'metadata': 'entry_id:$id',
        });
      }
    } catch (e) {
      throw AppDatabaseException('Gagal menghapus logbook: $e');
    }
  }

  Future<List<LogbookEntry>> getLogbookHistory({
    DateTime? startDate,
    DateTime? endDate,
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
      if (status != null && status.isNotEmpty && status != 'all') {
        whereClauses.add('status = ?');
        whereArgs.add(status);
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add(
          '(activities LIKE ? OR learnings LIKE ? OR obstacles LIKE ? OR date LIKE ?)',
        );
        final q = '%${searchQuery.trim()}%';
        whereArgs.addAll([q, q, q, q]);
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final results = await db.query(
        AppConstants.tableLogbookEntries,
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'date DESC',
      );

      return results.map((m) => LogbookEntry.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat riwayat logbook: $e');
    }
  }

  Future<List<LogbookEntry>> getAllLogbooks() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableLogbookEntries,
        orderBy: 'date DESC',
      );
      return results.map((m) => LogbookEntry.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat semua logbook: $e');
    }
  }
}
