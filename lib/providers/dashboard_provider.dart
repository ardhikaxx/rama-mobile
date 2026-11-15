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
  final bool checkInScheduled;
  final AttendanceRecord? checkInRecord;
  final bool checkOutScheduled;
  final AttendanceRecord? checkOutRecord;
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
    required this.checkInScheduled,
    this.checkInRecord,
    required this.checkOutScheduled,
    this.checkOutRecord,
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

  ReminderSchedule? checkInSchedule;
  ReminderSchedule? checkOutSchedule;
  ReminderSchedule? logbookSchedule;

  for (final s in schedules) {
    if (s.type == AppConstants.reminderCheckIn) checkInSchedule = s;
    if (s.type == AppConstants.reminderCheckOut) checkOutSchedule = s;
    if (s.type == AppConstants.reminderLogbook) logbookSchedule = s;
  }

  final checkInActive = isTodayWorkday && (checkInSchedule?.isEnabled ?? true);
  final checkOutActive = isTodayWorkday && (checkOutSchedule?.isEnabled ?? true);
  final logbookActive = isTodayWorkday && (logbookSchedule?.isEnabled ?? true);

  AttendanceRecord? checkInRecord;
  AttendanceRecord? checkOutRecord;
  for (final r in todayAttendance) {
    if (r.isCheckIn) checkInRecord = r;
    if (r.isCheckOut) checkOutRecord = r;
  }

  // Calculate Progress
  int totalTasks = 0;
  int completedTasks = 0;

  if (checkInActive) {
    totalTasks++;
    if (checkInRecord != null) completedTasks++;
  }
  if (checkOutActive) {
    totalTasks++;
    if (checkOutRecord != null) completedTasks++;
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

  // Complete days = dates with both check_in and check_out
  final attendanceByDate = <String, Set<String>>{};
  for (final r in weekAttendance) {
    attendanceByDate.putIfAbsent(r.date, () => <String>{}).add(r.type);
  }
  int completeDaysCount = 0;
  for (final types in attendanceByDate.values) {
    if (types.contains(AppConstants.checkIn) && types.contains(AppConstants.checkOut)) {
      completeDaysCount++;
    }
  }

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
      final hasIn = weekAttendance.any((a) => a.date == dateKey && a.isCheckIn);
      final hasOut = weekAttendance.any((a) => a.date == dateKey && a.isCheckOut);
      final hasLog = weekLogbooks.any((l) => l.date == dateKey);

      if (!hasIn) pendingWeekTasks++;
      if (!hasOut) pendingWeekTasks++;
      if (!hasLog) pendingWeekTasks++;
    }
  }

  // Next upcoming reminder calculation
  ReminderSchedule? nextReminder;
  String? nextReminderCountdown;

  if (isTodayWorkday) {
    final candidateSchedules = <ReminderSchedule>[];

    if (checkInActive && checkInRecord == null && checkInSchedule != null) {
      candidateSchedules.add(checkInSchedule);
    }
    if (checkOutActive && checkOutRecord == null && checkOutSchedule != null) {
      candidateSchedules.add(checkOutSchedule);
    }
    if (logbookActive && todayLogbook == null && logbookSchedule != null) {
      candidateSchedules.add(logbookSchedule);
    }

    // Filter to find the earliest one today that hasn't passed, or the next one
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

    // If all today have passed but some are still unfinished, show the next earliest
    if (nextReminder == null && candidateSchedules.isNotEmpty) {
      nextReminder = candidateSchedules.first;
      nextReminderCountdown = 'Lewat jadwal (${nextReminder.time})';
    }
  }

  return DashboardData(
    greeting: DateFormatter.getGreeting(now),
    currentDate: now,
    isTodayWorkday: isTodayWorkday,
    checkInScheduled: checkInActive,
    checkInRecord: checkInRecord,
    checkOutScheduled: checkOutActive,
    checkOutRecord: checkOutRecord,
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
