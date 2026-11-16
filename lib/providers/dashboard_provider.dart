import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../data/models/attendance_record.dart';
import '../data/models/logbook_entry.dart';
import '../data/models/reminder_schedule.dart';
import 'app_providers.dart';
import 'attendance_provider.dart';
import 'logbook_provider.dart';
import 'reminder_provider.dart';
import 'settings_provider.dart';

class DashboardData {
  final String greeting;
  final DateTime currentDate;
  final bool isTodayWorkday;
  final bool attendanceScheduled;
  final AttendanceRecord? attendanceRecord;
  final bool logbookScheduled;
  final LogbookEntry? todayLogbook;
  final double dailyProgress; // 0.0 - 1.0
  final int completedTasksCount;
  final int totalTasksCount;
  final int completeDaysThisWeek;
  final int logbooksThisWeek;
  final int pendingTasksThisWeek;
  final int totalWorkdaysRecorded;
  final ReminderSchedule? nextReminder;
  final String? nextReminderCountdown;
  final bool isPastDepartureTime;
  final String reminderTitle;
  final String reminderBadge;
  final String reminderMessage;
  final String reminderStatusType; // 'past_pending', 'all_completed', 'active_countdown', 'upcoming', 'holiday', 'normal'

  const DashboardData({
    required this.greeting,
    required this.currentDate,
    required this.isTodayWorkday,
    required this.attendanceScheduled,
    this.attendanceRecord,
    required this.logbookScheduled,
    this.todayLogbook,
    required this.dailyProgress,
    required this.completedTasksCount,
    required this.totalTasksCount,
    required this.completeDaysThisWeek,
    required this.logbooksThisWeek,
    required this.pendingTasksThisWeek,
    required this.totalWorkdaysRecorded,
    this.nextReminder,
    this.nextReminderCountdown,
    this.isPastDepartureTime = false,
    this.reminderTitle = 'Pengingat Berikutnya',
    this.reminderBadge = '',
    this.reminderMessage = '',
    this.reminderStatusType = 'normal',
  });

  // Backward-compatibility getters
  bool get checkInScheduled => false;
  AttendanceRecord? get checkInRecord => null;
  bool get checkOutScheduled => attendanceScheduled;
  AttendanceRecord? get checkOutRecord => attendanceRecord;
}

final dashboardDataProvider = FutureProvider.autoDispose<DashboardData>((ref) async {
  // Watch triggers to re-evaluate when records or settings change
  ref.watch(attendanceProvider);
  ref.watch(logbookProvider);
  ref.watch(settingsProvider);
  ref.watch(reminderScheduleProvider);

  final attendanceRepo = ref.read(attendanceRepositoryProvider);
  final logbookRepo = ref.read(logbookRepositoryProvider);
  final settingsRepo = ref.read(settingsRepositoryProvider);
  final reminderRepo = ref.read(reminderRepositoryProvider);

  final now = DateTime.now();
  final todayKey = DateFormatter.toDateKey(now);
  final weekday = now.weekday; // 1 = Monday .. 7 = Sunday

  final settings = await settingsRepo.getSettings();
  final schedules = await reminderRepo.getAllSchedules();
  final todayAttendance = await attendanceRepo.getRecordsByDate(todayKey);
  final todayLogbook = await logbookRepo.getLogbookByDate(todayKey);

  // Check which reminders are scheduled for today
  final isTodayWorkday = settings.activeDays.contains(weekday);

  ReminderSchedule? attendanceSchedule;
  ReminderSchedule? logbookSchedule;

  for (final s in schedules) {
    if (s.type == AppConstants.reminderAttendance || s.type == AppConstants.reminderCheckOut) {
      attendanceSchedule = s;
    }
    if (s.type == AppConstants.reminderLogbook) logbookSchedule = s;
  }

  final attendanceActive = isTodayWorkday && (attendanceSchedule?.isEnabled ?? true);
  final logbookActive = isTodayWorkday && (logbookSchedule?.isEnabled ?? true);

  AttendanceRecord? attendanceRecord;
  for (final r in todayAttendance) {
    if (r.type == AppConstants.checkOut || r.type == AppConstants.attendance) {
      attendanceRecord = r;
      break;
    }
  }
  attendanceRecord ??= todayAttendance.isNotEmpty ? todayAttendance.first : null;

  // Calculate Progress: 2 daily obligations (Absensi Magang + Logbook Harian)
  int totalTasks = 0;
  int completedTasks = 0;

  if (attendanceActive) {
    totalTasks++;
    if (attendanceRecord != null) completedTasks++;
  }
  if (logbookActive) {
    totalTasks++;
    if (todayLogbook != null) completedTasks++;
  }

  final double progress = totalTasks > 0 ? (completedTasks / totalTasks) : 1.0;

  // Calculate Weekly Summary (Monday to Sunday of current week)
  final monday = now.subtract(Duration(days: weekday - 1));
  final sunday = monday.add(const Duration(days: 6));
  final weekStartDate = DateTime(monday.year, monday.month, monday.day);
  final weekEndDate = DateTime(sunday.year, sunday.month, sunday.day, 23, 59, 59);

  final weekAttendance = await attendanceRepo.getAttendanceHistory(
    startDate: weekStartDate,
    endDate: weekEndDate,
  );
  final weekLogbooks = await logbookRepo.getLogbookHistory(
    startDate: weekStartDate,
    endDate: weekEndDate,
  );

  // Complete days = dates with attendance record
  final uniqueAttendanceDates = weekAttendance.map((e) => e.date).toSet();
  final completeDaysCount = uniqueAttendanceDates.length;

  // Workdays recorded = unique dates with any attendance or logbook
  final allRecords = await attendanceRepo.getAllRecords();
  final allLogbooks = await logbookRepo.getAllLogbooks();
  final uniqueRecordedDates = <String>{};
  for (final a in allRecords) {
    uniqueRecordedDates.add(a.date);
  }
  for (final l in allLogbooks) {
    uniqueRecordedDates.add(l.date);
  }

  // Pending activities this week
  // Calculate how many active workdays have passed this week BEFORE today (past days only)
  int pendingWeekTasks = 0;
  for (int d = 1; d < weekday; d++) {
    if (settings.activeDays.contains(d)) {
      final targetDate = monday.add(Duration(days: d - 1));
      final dateKey = DateFormatter.toDateKey(targetDate);
      final hasAtt = weekAttendance.any((a) => a.date == dateKey);
      final hasLog = weekLogbooks.any((l) => l.date == dateKey);

      if (!hasAtt) pendingWeekTasks++;
      if (!hasLog) pendingWeekTasks++;
    }
  }

  // Next upcoming reminder calculation & pre-departure reminder series
  ReminderSchedule? nextReminder;
  String? nextReminderCountdown;
  bool isPastDepartureTime = false;
  String reminderTitle = 'Pengingat Berikutnya';
  String reminderBadge = '';
  String reminderMessage = '';
  String reminderStatusType = 'normal';

  // Parse working end time (jam pulang kerja magang, default 16:30)
  final endParts = settings.workingEndTime.split(':');
  final departureHour = int.tryParse(endParts[0]) ?? 16;
  final departureMinute = int.tryParse(endParts[1]) ?? 30;
  final departureMinutes = departureHour * 60 + departureMinute;
  final nowMinutes = now.hour * 60 + now.minute;

  isPastDepartureTime = nowMinutes > departureMinutes;

  // 4 Tahap Pengingat (1 jam sebelum pulang s/d jam pulang):
  // Step 0: 60m sebelum pulang (15.30)
  // Step 1: 40m sebelum pulang (15.50)
  // Step 2: 20m sebelum pulang (16.10)
  // Step 3: Tepat jam pulang (16.30)
  final step0Minutes = departureMinutes - 60;
  final step1Minutes = departureMinutes - 40;
  final step2Minutes = departureMinutes - 20;
  final step3Minutes = departureMinutes;

  String formatMinToHHmm(int totalMin) {
    var min = totalMin;
    if (min < 0) min += 24 * 60;
    final h = (min ~/ 60) % 24;
    final m = min % 60;
    return '${h.toString().padLeft(2, '0')}.${m.toString().padLeft(2, '0')}';
  }

  final step0Str = formatMinToHHmm(step0Minutes);
  final step1Str = formatMinToHHmm(step1Minutes);
  final step2Str = formatMinToHHmm(step2Minutes);
  final step3Str = formatMinToHHmm(step3Minutes);

  final isAttendanceDone = !attendanceActive || attendanceRecord != null;
  final isLogbookDone = !logbookActive || todayLogbook != null;
  final isAllDone = isAttendanceDone && isLogbookDone;

  if (!isTodayWorkday) {
    reminderStatusType = 'holiday';
    reminderTitle = 'Jadwal Magang';
    reminderBadge = 'Libur';
    reminderMessage = 'Hari ini tidak ada jadwal presensi magang dan pengisian logbook.';
  } else if (isAllDone) {
    reminderStatusType = 'all_completed';
    if (isPastDepartureTime) {
      reminderTitle = 'Aktivitas Hari Ini Tuntas';
      reminderBadge = 'Selesai ($step3Str)';
      reminderMessage =
          'Jam kerja magang telah usai. Semua absensi & logbook hari ini telah tuntas! Selamat beristirahat.';
    } else {
      reminderTitle = 'Tugas Selesai Lebih Awal';
      reminderBadge = 'Siap Pulang';
      reminderMessage =
          'Absensi dan logbook hari ini sudah tuntas sebelum jam pulang ($step3Str). Tetap semangat!';
    }
  } else if (isPastDepartureTime) {
    // Sudah melewati jam pulang kerja dan ada tugas yang belum selesai
    reminderStatusType = 'past_pending';
    reminderTitle = 'Perhatian Jam Pulang';
    reminderBadge = 'Lewat ($step3Str)';

    if (!isAttendanceDone && !isLogbookDone) {
      reminderMessage =
          'Sudah melewati jam pulang ($step3Str). Segera selesaikan absensi dan pengisian logbook hari ini!';
    } else if (!isAttendanceDone) {
      reminderMessage =
          'Sudah melewati jam pulang ($step3Str). Jangan lupa konfirmasi presensi kehadiran magang Anda!';
    } else {
      reminderMessage =
          'Sudah melewati jam pulang ($step3Str). Jangan lupa lengkapi dan simpan laporan logbook Anda!';
    }

    nextReminder = !isAttendanceDone ? attendanceSchedule : logbookSchedule;
    nextReminderCountdown = 'Lewat jadwal ($step3Str)';
  } else if (nowMinutes >= step0Minutes && nowMinutes <= departureMinutes) {
    // Fase 1 jam sebelum pulang s/d jam pulang (15.30 - 16.30)
    reminderStatusType = 'active_countdown';
    reminderTitle = 'Pengingat Kepulangan';
    nextReminder = !isAttendanceDone ? attendanceSchedule : logbookSchedule;

    if (nowMinutes < step1Minutes) {
      final cd = DateFormatter.getCountdownText(
          TimeOfDay(hour: (step1Minutes ~/ 60) % 24, minute: step1Minutes % 60));
      reminderBadge = step1Str;
      reminderMessage = 'Pengingat ke-2 ($step1Str) • $cd';
      nextReminderCountdown = cd;
    } else if (nowMinutes < step2Minutes) {
      final cd = DateFormatter.getCountdownText(
          TimeOfDay(hour: (step2Minutes ~/ 60) % 24, minute: step2Minutes % 60));
      reminderBadge = step2Str;
      reminderMessage = 'Pengingat ke-3 ($step2Str) • $cd';
      nextReminderCountdown = cd;
    } else {
      final cd = DateFormatter.getCountdownText(
          TimeOfDay(hour: (step3Minutes ~/ 60) % 24, minute: step3Minutes % 60));
      reminderBadge = step3Str;
      reminderMessage = 'Pengingat jam pulang ($step3Str) • $cd';
      nextReminderCountdown = cd;
    }
  } else {
    // Pagi atau siang hari sebelum jam 15.30
    reminderStatusType = 'upcoming';
    reminderTitle = 'Pengingat Berikutnya';
    reminderBadge = step0Str;
    final cd = DateFormatter.getCountdownText(
        TimeOfDay(hour: (step0Minutes ~/ 60) % 24, minute: step0Minutes % 60));
    reminderMessage =
        'Pengingat dimulai 1 jam sebelum jam pulang ($step0Str) • $cd';
    nextReminder = !isAttendanceDone ? attendanceSchedule : logbookSchedule;
    nextReminderCountdown = cd;
  }

  return DashboardData(
    greeting: DateFormatter.getGreeting(now),
    currentDate: now,
    isTodayWorkday: isTodayWorkday,
    attendanceScheduled: attendanceActive,
    attendanceRecord: attendanceRecord,
    logbookScheduled: logbookActive,
    todayLogbook: todayLogbook,
    dailyProgress: progress,
    completedTasksCount: completedTasks,
    totalTasksCount: totalTasks,
    completeDaysThisWeek: completeDaysCount,
    logbooksThisWeek: weekLogbooks.length,
    pendingTasksThisWeek: pendingWeekTasks,
    totalWorkdaysRecorded: uniqueRecordedDates.length,
    nextReminder: nextReminder,
    nextReminderCountdown: nextReminderCountdown,
    isPastDepartureTime: isPastDepartureTime,
    reminderTitle: reminderTitle,
    reminderBadge: reminderBadge,
    reminderMessage: reminderMessage,
    reminderStatusType: reminderStatusType,
  );
});
