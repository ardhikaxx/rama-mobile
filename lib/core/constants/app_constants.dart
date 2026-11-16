class AppConstants {
  static const String appName = 'RAMA';
  static const String appFullName = 'Rekap Aktivitas Magang & Absensi';
  static const String appTagline = 'Biar Magang Lebih Teratur';
  static const String appVersion = '1.0.0';

  // Database
  static const String databaseName = 'rama_database.db';
  static const int databaseVersion = 1;

  // Tables
  static const String tableSettings = 'settings';
  static const String tableReminderSchedules = 'reminder_schedules';
  static const String tableAttendanceRecords = 'attendance_records';
  static const String tableLogbookEntries = 'logbook_entries';
  static const String tableActivityHistory = 'activity_history';

  // Attendance Types
  static const String checkIn = 'check_in';
  static const String checkOut = 'check_out';
  static const String attendance = 'check_out'; // Single daily attendance before leaving

  // Attendance Statuses
  static const String statusHadir = 'hadir';
  static const String statusIzin = 'izin';
  static const String statusSakit = 'sakit';
  static const String statusLibur = 'libur';

  // Logbook Statuses
  static const String logbookDraft = 'draft';
  static const String logbookCreated = 'created';
  static const String logbookCopied = 'copied';
  static const String logbookSubmitted = 'submitted';

  // Reminder Types
  static const String reminderCheckIn = 'check_in';
  static const String reminderCheckOut = 'check_out';
  static const String reminderAttendance = 'check_out';
  static const String reminderLogbook = 'logbook';

  // Days of Week (ISO: 1 = Senin, 7 = Minggu)
  static const List<int> defaultActiveDays = [1, 2, 3, 4, 5]; // Senin - Jumat
  static const Map<int, String> dayNames = {
    1: 'Senin',
    2: 'Selasa',
    3: 'Rabu',
    4: 'Kamis',
    5: 'Jumat',
    6: 'Sabtu',
    7: 'Minggu',
  };

  static const Map<int, String> shortDayNames = {
    1: 'Sen',
    2: 'Sel',
    3: 'Rab',
    4: 'Kam',
    5: 'Jum',
    6: 'Sab',
    7: 'Min',
  };

  // Snooze options
  static const List<int> snoozeIntervalOptions = [10, 15, 30];
  static const int defaultSnoozeInterval = 15;
  static const int maxSnoozeCount = 5;

  // Notification Channels
  static const String notificationChannelId = 'rama_reminders_channel';
  static const String notificationChannelName = 'Pengingat RAMA';
  static const String notificationChannelDescription =
      'Notifikasi pengingat absensi magang dan pengisian logbook harian';

  // Notification Action Payloads
  static const String payloadCheckIn = 'action:check_in';
  static const String payloadCheckOut = 'action:check_out';
  static const String payloadLogbook = 'action:logbook';
}
