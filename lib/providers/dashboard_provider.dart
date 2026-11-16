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

  // Next upcoming reminder calculation
  ReminderSchedule? nextReminder;
  String? nextReminderCountdown;

  if (isTodayWorkday) {
    final candidateSchedules = <ReminderSchedule>[];

    if (attendanceActive && attendanceRecord == null && attendanceSchedule != null) {
      candidateSchedules.add(attendanceSchedule);
    }
    if (logbookActive && todayLogbook == null && logbookSchedule != null) {
      candidateSchedules.add(logbookSchedule);
    }

    final nowMinutes = now.hour * 60 + now.minute;
    candidateSchedules.sort((a, b) {
      final aMin = a.hour * 60 + a.minute;
      final bMin = b.hour * 60 + b.minute;
      return aMin.compareTo(bMin);
    });

    for (final s in candidateSchedules) {
      final sMin = s.hour * 60 + s.minute;
      if (sMin >= nowMinutes) {
        nextReminder = s;
        nextReminderCountdown = DateFormatter.getCountdownText(s.timeOfDay);
        break;
      }
    }

    if (nextReminder == null && candidateSchedules.isNotEmpty) {
      nextReminder = candidateSchedules.first;
      nextReminderCountdown = 'Lewat jadwal (${nextReminder.time})';
    }
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
  );
});
