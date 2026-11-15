import 'package:flutter_test/flutter_test.dart';
import 'package:rama_app/core/utils/date_formatter.dart';
import 'package:rama_app/data/models/app_settings.dart';
import 'package:rama_app/data/models/attendance_record.dart';
import 'package:rama_app/data/models/logbook_entry.dart';
import 'package:rama_app/data/models/reminder_schedule.dart';

void main() {
  group('DateFormatter Tests', () {
    test('formatIndonesianDate produces proper Indonesian string', () {
      final date = DateTime(2026, 11, 16);
      final formatted = DateFormatter.formatIndonesianDate(date);
      expect(formatted, contains('Senin'));
      expect(formatted, contains('16'));
      expect(formatted, contains('November'));
      expect(formatted, contains('2026'));
    });

    test('toDateKey formats yyyy-MM-dd correctly', () {
      final date = DateTime(2026, 11, 16);
      expect(DateFormatter.toDateKey(date), equals('2026-11-16'));
    });

    test('getGreeting returns correct greeting for time of day', () {
      final morning = DateTime(2026, 11, 16, 8, 30);
      expect(DateFormatter.getGreeting(morning), equals('Selamat Pagi'));

      final afternoon = DateTime(2026, 11, 16, 13, 0);
      expect(DateFormatter.getGreeting(afternoon), equals('Selamat Siang'));

      final evening = DateTime(2026, 11, 16, 16, 30);
      expect(DateFormatter.getGreeting(evening), equals('Selamat Sore'));

      final night = DateTime(2026, 11, 16, 21, 0);
      expect(DateFormatter.getGreeting(night), equals('Selamat Malam'));
    });
  });

  group('LogbookEntry Generator Tests', () {
    test('generateTemplateText formats template according to specification', () {
      final date = DateTime(2026, 11, 16);
      const activities = 'Melakukan perbaikan UI dashboard dan integrasi database.';
      const learnings = 'Memahami implementasi SQLite dan Riverpod.';
      const obstacles = 'Tidak ada kendala berarti.';

      final template = LogbookEntry.generateTemplateText(
        date: date,
        activities: activities,
        learnings: learnings,
        obstacles: obstacles,
      );

      expect(template, contains('LAPORAN AKTIVITAS MAGANG'));
      expect(template, contains('Tanggal: Senin, 16 November 2026'));
      expect(template, contains('1. Uraian Aktivitas'));
      expect(template, contains(activities));
      expect(template, contains('2. Pembelajaran yang Diperoleh'));
      expect(template, contains(learnings));
      expect(template, contains('3. Kendala yang Dihadapi'));
      expect(template, contains(obstacles));
    });
  });

  group('Model Serialization Tests', () {
    test('AppSettings serialization roundtrip', () {
      const original = AppSettings(
        workingStartTime: '08:30',
        workingEndTime: '17:30',
        activeDays: [1, 2, 3, 4],
        snoozeIntervalMinutes: 30,
        soundEnabled: false,
        vibrationEnabled: true,
        themeMode: 'dark',
        userName: 'Budi Santoso',
        organizationName: 'PT Teknologi Mandiri',
      );

      final map = original.toMap();
      final reconstructed = AppSettings.fromMap(map);

      expect(reconstructed.workingStartTime, equals('08:30'));
      expect(reconstructed.workingEndTime, equals('17:30'));
      expect(reconstructed.activeDays, equals([1, 2, 3, 4]));
      expect(reconstructed.snoozeIntervalMinutes, equals(30));
      expect(reconstructed.soundEnabled, isFalse);
      expect(reconstructed.vibrationEnabled, isTrue);
      expect(reconstructed.themeMode, equals('dark'));
      expect(reconstructed.userName, equals('Budi Santoso'));
      expect(reconstructed.organizationName, equals('PT Teknologi Mandiri'));
    });

    test('AttendanceRecord serialization roundtrip', () {
      final now = DateTime.now();
      final record = AttendanceRecord(
        id: 1,
        date: '2026-11-16',
        type: 'check_in',
        timestamp: now,
        status: 'hadir',
        notes: 'Tepat waktu',
        createdAt: now,
        updatedAt: now,
      );

      final map = record.toMap();
      final reconstructed = AttendanceRecord.fromMap(map);

      expect(reconstructed.id, equals(1));
      expect(reconstructed.date, equals('2026-11-16'));
      expect(reconstructed.type, equals('check_in'));
      expect(reconstructed.status, equals('hadir'));
      expect(reconstructed.notes, equals('Tepat waktu'));
    });

    test('ReminderSchedule default schedules have 3 items', () {
      final defaults = ReminderSchedule.defaultSchedules();
      expect(defaults.length, equals(3));
      expect(defaults[0].type, equals('check_in'));
      expect(defaults[1].type, equals('check_out'));
      expect(defaults[2].type, equals('logbook'));
    });
  });
}
