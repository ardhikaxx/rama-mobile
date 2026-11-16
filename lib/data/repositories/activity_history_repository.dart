import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../../core/utils/date_formatter.dart';
import '../database/database_helper.dart';
import '../models/activity_history.dart';

class ActivityHistoryRepository {
  final DatabaseHelper _dbHelper;

  ActivityHistoryRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<ActivityHistory>> getRecentActivities({int limit = 50}) async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableActivityHistory,
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      return results.map((m) => ActivityHistory.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat aktivitas terbaru: $e');
    }
  }

  Future<List<ActivityHistory>> getActivityHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? actionType,
    String? searchQuery,
  }) async {
    try {
      final db = await _dbHelper.database;
      final whereClauses = <String>[];
      final whereArgs = <dynamic>[];

      if (startDate != null) {
        whereClauses.add('timestamp >= ?');
        whereArgs.add(DateFormatter.toDateKey(startDate));
      }
      if (endDate != null) {
        whereClauses.add('timestamp <= ?');
        whereArgs.add('${DateFormatter.toDateKey(endDate)}T23:59:59');
      }
      if (actionType != null && actionType.isNotEmpty && actionType != 'all') {
        whereClauses.add('action_type LIKE ?');
        whereArgs.add('%$actionType%');
      }
      if (searchQuery != null && searchQuery.trim().isNotEmpty) {
        whereClauses.add('(title LIKE ? OR description LIKE ?)');
        final q = '%${searchQuery.trim()}%';
        whereArgs.addAll([q, q]);
      }

      final whereString = whereClauses.isNotEmpty ? whereClauses.join(' AND ') : null;

      final results = await db.query(
        AppConstants.tableActivityHistory,
        where: whereString,
        whereArgs: whereArgs.isNotEmpty ? whereArgs : null,
        orderBy: 'timestamp DESC',
      );

      return results.map((m) => ActivityHistory.fromMap(m)).toList();
    } catch (e) {
      throw AppDatabaseException('Gagal memuat riwayat aktivitas: $e');
    }
  }

  Future<void> insertActivity(ActivityHistory activity) async {
    try {
      final db = await _dbHelper.database;
      await db.insert(AppConstants.tableActivityHistory, activity.toMap());
    } catch (e) {
      throw AppDatabaseException('Gagal menyimpan riwayat aktivitas: $e');
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      final db = await _dbHelper.database;
      await db.delete(
        AppConstants.tableActivityHistory,
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e) {
      throw AppDatabaseException('Gagal menghapus riwayat aktivitas: $e');
    }
  }

  Future<void> clearAllActivities() async {
    try {
      final db = await _dbHelper.database;
      await db.delete(AppConstants.tableActivityHistory);
    } catch (e) {
      throw AppDatabaseException('Gagal membersihkan riwayat aktivitas: $e');
    }
  }
}
