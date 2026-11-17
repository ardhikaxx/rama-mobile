import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rama_app/core/constants/app_constants.dart';
import 'package:rama_app/core/utils/date_formatter.dart';
import 'app_providers.dart';

enum StatPeriod { thisWeek, thisMonth, allTime, custom }

class StatisticsFilter {
  final StatPeriod period;
  final DateTime? customStart;
  final DateTime? customEnd;

  const StatisticsFilter({
    this.period = StatPeriod.thisMonth,
    this.customStart,
    this.customEnd,
  });

  StatisticsFilter copyWith({
    StatPeriod? period,
    DateTime? customStart,
    DateTime? customEnd,
  }) {
    return StatisticsFilter(
      period: period ?? this.period,
      customStart: customStart ?? this.customStart,
      customEnd: customEnd ?? this.customEnd,
    );
  }
}

class DailyStatPoint {
  final String dateKey;
  final String label;
  final bool hasCheckIn;
  final bool hasCheckOut;
  final bool hasLogbook;

  const DailyStatPoint({
    required this.dateKey,
    required this.label,
    required this.hasCheckIn,
    required this.hasCheckOut,
    required this.hasLogbook,
  });
}

class StatisticsData {
  final int totalScheduledWorkdays;
  final int totalHadir;
  final int totalIzin;
  final int totalSakit;
  final int totalLibur;
  final int totalCheckIn;
  final int totalCheckOut;
  final int totalLogbookCreated;
  final int totalLogbookCopied;
  final int totalLogbookSubmitted;
  final double attendanceRate; // 0 - 100%
  final double logbookRate; // 0 - 100%
  final List<DailyStatPoint> dailyPoints;

  const StatisticsData({
    required this.totalScheduledWorkdays,
    required this.totalHadir,
    required this.totalIzin,
    required this.totalSakit,
    required this.totalLibur,
    required this.totalCheckIn,
    required this.totalCheckOut,
    required this.totalLogbookCreated,
    required this.totalLogbookCopied,
    required this.totalLogbookSubmitted,
    required this.attendanceRate,
    required this.logbookRate,
    required this.dailyPoints,
  });
}

final statisticsFilterProvider = StateProvider<StatisticsFilter>((ref) {
  return const StatisticsFilter(period: StatPeriod.thisMonth);
});

final statisticsDataProvider = FutureProvider.autoDispose<StatisticsData>((ref) async {
  final filter = ref.watch(statisticsFilterProvider);
  final attendanceRepo = ref.read(attendanceRepositoryProvider);
  final logbookRepo = ref.read(logbookRepositoryProvider);
  final settingsRepo = ref.read(settingsRepositoryProvider);

  final settings = await settingsRepo.getSettings();
  final now = DateTime.now();

  DateTime startDate = DateTime(now.year, now.month, 1);
  DateTime endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);

  switch (filter.period) {
    case StatPeriod.thisWeek:
      final monday = now.subtract(Duration(days: now.weekday - 1));
      startDate = DateTime(monday.year, monday.month, monday.day);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case StatPeriod.thisMonth:
      startDate = DateTime(now.year, now.month, 1);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case StatPeriod.allTime:
      startDate = DateTime(now.year - 1, 1, 1);
      endDate = DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
    case StatPeriod.custom:
      startDate = filter.customStart ?? DateTime(now.year, now.month, 1);
      endDate = filter.customEnd ?? DateTime(now.year, now.month, now.day, 23, 59, 59);
      break;
  }

  final attendanceRecords = await attendanceRepo.getAttendanceHistory(
    startDate: startDate,
    endDate: endDate,
  );
  final logbookEntries = await logbookRepo.getLogbookHistory(
    startDate: startDate,
    endDate: endDate,
  );

  // Calculate scheduled workdays in interval
  int scheduledWorkdays = 0;
  var cursor = startDate;
  final todayOnly = DateTime(now.year, now.month, now.day);
  while (!cursor.isAfter(endDate) && !cursor.isAfter(todayOnly)) {
    if (settings.activeDays.contains(cursor.weekday)) {
      scheduledWorkdays++;
    }
    cursor = cursor.add(const Duration(days: 1));
  }

  int totalHadir = 0;
  int totalIzin = 0;
  int totalSakit = 0;
  int totalLibur = 0;
  int totalCheckIn = 0;
  int totalCheckOut = 0;

  for (final a in attendanceRecords) {
    if (a.isCheckIn) totalCheckIn++;
    if (a.isCheckOut) totalCheckOut++;

    switch (a.status) {
      case AppConstants.statusHadir:
        totalHadir++;
        break;
      case AppConstants.statusIzin:
        totalIzin++;
        break;
      case AppConstants.statusSakit:
        totalSakit++;
        break;
      case AppConstants.statusLibur:
        totalLibur++;
        break;
    }
  }

  int totalCreated = logbookEntries.length;
  int totalCopied = 0;
  int totalSubmitted = 0;

  for (final l in logbookEntries) {
    if (l.isCopied) totalCopied++;
    if (l.isSubmitted) totalSubmitted++;
  }

  final double attendanceRate = scheduledWorkdays > 0
      ? ((totalCheckIn / scheduledWorkdays) * 100).clamp(0.0, 100.0)
      : 100.0;

  final double logbookRate = scheduledWorkdays > 0
      ? ((totalCreated / scheduledWorkdays) * 100).clamp(0.0, 100.0)
      : 100.0;

  // Build daily points for chart (last 7 recorded days in range)
  final List<DailyStatPoint> points = [];
  final pointsCount = 7;
  for (int i = pointsCount - 1; i >= 0; i--) {
    final day = now.subtract(Duration(days: i));
    final dateKey = DateFormatter.toDateKey(day);
    final shortLabel = AppConstants.shortDayNames[day.weekday] ?? '';

    final hasIn = attendanceRecords.any((a) => a.date == dateKey && a.isCheckIn);
    final hasOut = attendanceRecords.any((a) => a.date == dateKey && a.isCheckOut);
    final hasLog = logbookEntries.any((l) => l.date == dateKey);

    points.add(DailyStatPoint(
      dateKey: dateKey,
      label: shortLabel,
      hasCheckIn: hasIn,
      hasCheckOut: hasOut,
      hasLogbook: hasLog,
    ));
  }

  return StatisticsData(
    totalScheduledWorkdays: scheduledWorkdays,
    totalHadir: totalHadir,
    totalIzin: totalIzin,
    totalSakit: totalSakit,
    totalLibur: totalLibur,
    totalCheckIn: totalCheckIn,
    totalCheckOut: totalCheckOut,
    totalLogbookCreated: totalCreated,
    totalLogbookCopied: totalCopied,
    totalLogbookSubmitted: totalSubmitted,
    attendanceRate: attendanceRate,
    logbookRate: logbookRate,
    dailyPoints: points,
  );
});
