import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import '../../core/constants/app_constants.dart';
import '../models/app_settings.dart';
import '../models/reminder_schedule.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppConstants.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppConstants.databaseVersion,
      onConfigure: _onConfigure,
      onCreate: _createDB,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }

  Future<void> _createDB(Database db, int version) async {
    // 1. Settings Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableSettings} (
        id INTEGER PRIMARY KEY CHECK (id = 1),
        working_start_time TEXT NOT NULL DEFAULT '08:00',
        working_end_time TEXT NOT NULL DEFAULT '16:30',
        active_days TEXT NOT NULL DEFAULT '1,2,3,4,5',
        snooze_interval_minutes INTEGER NOT NULL DEFAULT 15,
        max_snooze_count INTEGER NOT NULL DEFAULT 5,
        sound_enabled INTEGER NOT NULL DEFAULT 1,
        vibration_enabled INTEGER NOT NULL DEFAULT 1,
        snooze_enabled INTEGER NOT NULL DEFAULT 1,
        theme_mode TEXT NOT NULL DEFAULT 'system',
        user_name TEXT NOT NULL DEFAULT 'Siswa / Mahasiswa Magang',
        organization_name TEXT NOT NULL DEFAULT ''
      )
    ''');

    // 2. Reminder Schedules Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableReminderSchedules} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        type TEXT NOT NULL UNIQUE,
        time TEXT NOT NULL,
        is_enabled INTEGER NOT NULL DEFAULT 1,
        active_days TEXT NOT NULL DEFAULT '1,2,3,4,5',
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 3. Attendance Records Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableAttendanceRecords} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'hadir',
        notes TEXT,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        UNIQUE(date, type)
      )
    ''');

    // 4. Logbook Entries Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableLogbookEntries} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL UNIQUE,
        activities TEXT NOT NULL,
        learnings TEXT NOT NULL,
        obstacles TEXT NOT NULL,
        generated_template TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'created',
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    // 5. Activity History Table
    await db.execute('''
      CREATE TABLE ${AppConstants.tableActivityHistory} (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        action_type TEXT NOT NULL,
        title TEXT NOT NULL,
        description TEXT NOT NULL,
        metadata TEXT
      )
    ''');

    // Indexes
    await db.execute(
      'CREATE INDEX idx_attendance_date ON ${AppConstants.tableAttendanceRecords}(date);',
    );
    await db.execute(
      'CREATE INDEX idx_attendance_type ON ${AppConstants.tableAttendanceRecords}(type);',
    );
    await db.execute(
      'CREATE INDEX idx_logbook_date ON ${AppConstants.tableLogbookEntries}(date);',
    );
    await db.execute(
      'CREATE INDEX idx_history_timestamp ON ${AppConstants.tableActivityHistory}(timestamp);',
    );

    // Initial Seed Data
    final initialSettings = const AppSettings().toMap();
    initialSettings['id'] = 1;
    await db.insert(AppConstants.tableSettings, initialSettings);

    for (final schedule in ReminderSchedule.defaultSchedules()) {
      await db.insert(AppConstants.tableReminderSchedules, schedule.toMap());
    }

    await db.insert(AppConstants.tableActivityHistory, {
      'timestamp': DateTime.now().toIso8601String(),
      'action_type': 'system_init',
      'title': 'Aplikasi Diinisialisasi',
      'description': 'Database lokal RAMA berhasil disiapkan dan siap digunakan offline.',
    });
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handled incrementally if database version increments
  }

  Future<T> transaction<T>(Future<T> Function(Transaction txn) action) async {
    final db = await database;
    return await db.transaction(action);
  }

  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }

  Future<void> resetDatabase() async {
    await close();
    final dbPath = await getDatabasesPath();
    final path = p.join(dbPath, AppConstants.databaseName);
    await deleteDatabase(path);
    _database = await _initDB(AppConstants.databaseName);
  }
}
