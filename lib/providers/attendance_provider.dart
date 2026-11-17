import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rama_app/core/constants/app_constants.dart';
import 'package:rama_app/core/utils/date_formatter.dart';
import 'package:rama_app/data/models/attendance_record.dart';
import 'app_providers.dart';

class AttendanceTodayState {
  final AttendanceRecord? record;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceTodayState({
    this.record,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get isRecorded => record != null;
  bool get hasRecord => record != null;
  AttendanceRecord? get checkOut => record;
  AttendanceRecord? get checkIn => record;
  bool get hasCheckIn => isRecorded;
  bool get hasCheckOut => isRecorded;
  bool get isComplete => isRecorded;

  AttendanceTodayState copyWith({
    AttendanceRecord? record,
    AttendanceRecord? checkIn,
    AttendanceRecord? checkOut,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearRecord = false,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
  }) {
    return AttendanceTodayState(
      record: (clearRecord || clearCheckIn || clearCheckOut)
          ? null
          : (record ?? checkOut ?? checkIn ?? this.record),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class AttendanceNotifier extends StateNotifier<AttendanceTodayState> {
  final Ref _ref;

  AttendanceNotifier(this._ref) : super(const AttendanceTodayState(isLoading: true)) {
    loadTodayAttendance();
  }

  Future<void> loadTodayAttendance() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(attendanceRepositoryProvider);
      final todayKey = DateFormatter.toDateKey(DateTime.now());
      final records = await repo.getRecordsByDate(todayKey);

      AttendanceRecord? rec;
      for (final r in records) {
        if (r.type == AppConstants.checkOut || r.type == AppConstants.attendance) {
          rec = r;
          break;
        }
      }
      rec ??= records.isNotEmpty ? records.first : null;

      state = AttendanceTodayState(
        record: rec,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> recordAttendance({
    String type = AppConstants.checkOut,
    String status = AppConstants.statusHadir,
    String? notes,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(attendanceRepositoryProvider);
      final todayKey = DateFormatter.toDateKey(DateTime.now());
      final now = DateTime.now();

      final record = await repo.recordAttendance(
        date: todayKey,
        type: type,
        timestamp: now,
        status: status,
        notes: notes,
      );

      // Cancel snooze notification for attendance today
      final notif = _ref.read(notificationServiceProvider);
      await notif.cancelSnoozeForType(AppConstants.reminderAttendance);
      await notif.cancelSnoozeForType(AppConstants.reminderCheckOut);

      state = state.copyWith(record: record, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> updateRecord(AttendanceRecord record) async {
    try {
      final repo = _ref.read(attendanceRepositoryProvider);
      await repo.updateAttendance(record);
      await loadTodayAttendance();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteRecord(int id) async {
    try {
      final repo = _ref.read(attendanceRepositoryProvider);
      await repo.deleteAttendance(id);
      await loadTodayAttendance();
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}

final attendanceProvider =
    StateNotifierProvider<AttendanceNotifier, AttendanceTodayState>((ref) {
  return AttendanceNotifier(ref);
});
