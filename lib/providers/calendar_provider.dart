import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../data/models/attendance_record.dart';
import '../data/models/logbook_entry.dart';
import 'app_providers.dart';
import 'settings_provider.dart';

enum DayActivityStatus {
  completed, // Green
  partial, // Orange
  notScheduled, // Grey
  unfulfilled, // Red (sakit, izin, or unfulfilled workday)
}

class DayDetail {
  final DateTime date;
  final String dateKey;
  final bool isWorkday;
  final AttendanceRecord? checkIn;
  final AttendanceRecord? checkOut;
  final LogbookEntry? logbook;
  final DayActivityStatus status;

  const DayDetail({
    required this.date,
    required this.dateKey,
    required this.isWorkday,
    this.checkIn,
    this.checkOut,
    this.logbook,
    required this.status,
  });
}

class CalendarState {
  final DateTime focusedDay;
  final DateTime selectedDay;
  final Map<String, DayDetail> monthDetails;
  final DayDetail? selectedDayDetail;
  final bool isLoading;

  const CalendarState({
    required this.focusedDay,
    required this.selectedDay,
    this.monthDetails = const {},
    this.selectedDayDetail,
    this.isLoading = false,
  });

  CalendarState copyWith({
    DateTime? focusedDay,
    DateTime? selectedDay,
    Map<String, DayDetail>? monthDetails,
    DayDetail? selectedDayDetail,
    bool? isLoading,
  }) {
    return CalendarState(
      focusedDay: focusedDay ?? this.focusedDay,
      selectedDay: selectedDay ?? this.selectedDay,
      monthDetails: monthDetails ?? this.monthDetails,
      selectedDayDetail: selectedDayDetail ?? this.selectedDayDetail,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class CalendarNotifier extends StateNotifier<CalendarState> {
  final Ref _ref;

  CalendarNotifier(this._ref)
      : super(CalendarState(
          focusedDay: DateTime.now(),
          selectedDay: DateTime.now(),
          isLoading: true,
        )) {
    loadMonthData(DateTime.now());
  }

  void onDaySelected(DateTime selectedDay, DateTime focusedDay) {
    final dateKey = DateFormatter.toDateKey(selectedDay);
    final detail = state.monthDetails[dateKey];

    state = state.copyWith(
      selectedDay: selectedDay,
      focusedDay: focusedDay,
      selectedDayDetail: detail,
    );
  }

  void onPageChanged(DateTime focusedDay) {
    state = state.copyWith(focusedDay: focusedDay);
    loadMonthData(focusedDay);
  }

  Future<void> loadMonthData(DateTime month) async {
    state = state.copyWith(isLoading: true);
    try {
      final attendanceRepo = _ref.read(attendanceRepositoryProvider);
      final logbookRepo = _ref.read(logbookRepositoryProvider);
      final settings = _ref.read(settingsProvider).valueOrNull;
      final activeDays = settings?.activeDays ?? AppConstants.defaultActiveDays;

      // Start of month to End of month
      final firstDay = DateTime(month.year, month.month - 1, 20); // include buffer
      final lastDay = DateTime(month.year, month.month + 1, 10);

      final attendanceList = await attendanceRepo.getAttendanceHistory(
        startDate: firstDay,
        endDate: lastDay,
      );
      final logbookList = await logbookRepo.getLogbookHistory(
        startDate: firstDay,
        endDate: lastDay,
      );

      final attendanceMap = <String, Map<String, AttendanceRecord>>{};
      for (final a in attendanceList) {
        attendanceMap.putIfAbsent(a.date, () => {})[a.type] = a;
      }

      final logbookMap = <String, LogbookEntry>{};
      for (final l in logbookList) {
        logbookMap[l.date] = l;
      }

      final monthDetails = <String, DayDetail>{};
      var cur = firstDay;
      final now = DateTime.now();

      while (!cur.isAfter(lastDay)) {
        final dateKey = DateFormatter.toDateKey(cur);
        final isWorkday = activeDays.contains(cur.weekday);
        final atts = attendanceMap[dateKey];
        final inRec = atts?[AppConstants.checkIn];
        final outRec = atts?[AppConstants.checkOut];
        final log = logbookMap[dateKey];

        DayActivityStatus status;
        if (!isWorkday) {
          status = DayActivityStatus.notScheduled;
        } else {
          // Check if there's special attendance status like izin or sakit
          final hasIzinOrSakit =
              (inRec != null && (inRec.status == AppConstants.statusIzin || inRec.status == AppConstants.statusSakit)) ||
              (outRec != null && (outRec.status == AppConstants.statusIzin || outRec.status == AppConstants.statusSakit));

          if (hasIzinOrSakit) {
            status = DayActivityStatus.unfulfilled;
          } else if (inRec != null && outRec != null && log != null) {
            status = DayActivityStatus.completed;
          } else if (inRec != null || outRec != null || log != null) {
            status = DayActivityStatus.partial;
          } else {
            // No records yet: if in the past, unfulfilled; if today or future, not scheduled / pending
            if (cur.isBefore(DateTime(now.year, now.month, now.day))) {
              status = DayActivityStatus.unfulfilled;
            } else {
              status = DayActivityStatus.partial;
            }
          }
        }

        final detail = DayDetail(
          date: cur,
          dateKey: dateKey,
          isWorkday: isWorkday,
          checkIn: inRec,
          checkOut: outRec,
          logbook: log,
          status: status,
        );

        monthDetails[dateKey] = detail;
        cur = cur.add(const Duration(days: 1));
      }

      final selKey = DateFormatter.toDateKey(state.selectedDay);
      final selDetail = monthDetails[selKey] ??
          DayDetail(
            date: state.selectedDay,
            dateKey: selKey,
            isWorkday: activeDays.contains(state.selectedDay.weekday),
            status: DayActivityStatus.notScheduled,
          );

      state = state.copyWith(
        monthDetails: monthDetails,
        selectedDayDetail: selDetail,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false);
    }
  }
}

final calendarProvider =
    StateNotifierProvider<CalendarNotifier, CalendarState>((ref) {
  return CalendarNotifier(ref);
});
