import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_constants.dart';
import '../../core/utils/date_formatter.dart';
import '../data/models/attendance_record.dart';
import 'app_providers.dart';

class AttendanceTodayState {
  final AttendanceRecord? checkIn;
  final AttendanceRecord? checkOut;
  final bool isLoading;
  final String? errorMessage;

  const AttendanceTodayState({
    this.checkIn,
    this.checkOut,
    this.isLoading = false,
    this.errorMessage,
  });

  bool get hasCheckIn => checkIn != null;
  bool get hasCheckOut => checkOut != null;
  bool get isComplete => hasCheckIn && hasCheckOut;

  AttendanceTodayState copyWith({
    AttendanceRecord? checkIn,
    AttendanceRecord? checkOut,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
  }) {
    return AttendanceTodayState(
      checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
      checkOut: clearCheckOut ? null : (checkOut ?? this.checkOut),
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

      AttendanceRecord? inRec;
      AttendanceRecord? outRec;

      for (final r in records) {
        if (r.isCheckIn) inRec = r;
        if (r.isCheckOut) outRec = r;
      }

      state = AttendanceTodayState(
        checkIn: inRec,
        checkOut: outRec,
        isLoading: false,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  Future<void> recordAttendance({
    required String type,
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

      // Cancel snooze notification for this type today
      final notif = _ref.read(notificationServiceProvider);
      await notif.cancelSnoozeForType(type);

      if (type == AppConstants.checkIn) {
        state = state.copyWith(checkIn: record, isLoading: false);
      } else {
        state = state.copyWith(checkOut: record, isLoading: false);
      }
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
