import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../../core/errors/app_exception.dart';
import '../database/database_helper.dart';
import '../models/app_settings.dart';

class SettingsRepository {
  final DatabaseHelper _dbHelper;

  SettingsRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<AppSettings> getSettings() async {
    try {
      final db = await _dbHelper.database;
      final results = await db.query(
        AppConstants.tableSettings,
        where: 'id = 1',
        limit: 1,
      );

      if (results.isNotEmpty) {
        return AppSettings.fromMap(results.first);
      }

      // If missing for any reason, re-insert default
      final defaultSettings = const AppSettings();
      final map = defaultSettings.toMap()..['id'] = 1;
      await db.insert(
        AppConstants.tableSettings,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return defaultSettings;
    } catch (e) {
      throw AppDatabaseException('Gagal memuat pengaturan aplikasi: $e');
    }
  }

  Future<void> updateSettings(AppSettings settings) async {
    try {
      final db = await _dbHelper.database;
      final map = settings.toMap()..['id'] = 1;
      await db.insert(
        AppConstants.tableSettings,
        map,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e) {
      throw AppDatabaseException('Gagal memperbarui pengaturan: $e');
    }
  }
}
