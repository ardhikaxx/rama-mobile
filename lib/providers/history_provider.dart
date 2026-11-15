import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/activity_history.dart';
import '../data/models/attendance_record.dart';
import '../data/models/logbook_entry.dart';
import 'app_providers.dart';

class HistoryFilter {
  final int selectedTabIndex; // 0 = Absensi, 1 = Logbook, 2 = Semua Aktivitas
  final String searchQuery;
  final DateTime? startDate;
  final DateTime? endDate;
  final String selectedType; // 'all', 'check_in', 'check_out'
  final String selectedStatus; // 'all', 'hadir', 'izin', etc.

  const HistoryFilter({
    this.selectedTabIndex = 0,
    this.searchQuery = '',
    this.startDate,
    this.endDate,
    this.selectedType = 'all',
    this.selectedStatus = 'all',
  });

  HistoryFilter copyWith({
    int? selectedTabIndex,
    String? searchQuery,
    DateTime? startDate,
    DateTime? endDate,
    String? selectedType,
    String? selectedStatus,
    bool clearDates = false,
  }) {
    return HistoryFilter(
      selectedTabIndex: selectedTabIndex ?? this.selectedTabIndex,
      searchQuery: searchQuery ?? this.searchQuery,
      startDate: clearDates ? null : (startDate ?? this.startDate),
      endDate: clearDates ? null : (endDate ?? this.endDate),
      selectedType: selectedType ?? this.selectedType,
      selectedStatus: selectedStatus ?? this.selectedStatus,
    );
  }
}

class HistoryNotifier extends StateNotifier<HistoryFilter> {
  HistoryNotifier() : super(const HistoryFilter());

  void setTab(int index) {
    state = state.copyWith(selectedTabIndex: index);
  }

  void setSearchQuery(String query) {
    state = state.copyWith(searchQuery: query);
  }

  void setDateRange(DateTime? start, DateTime? end) {
    state = state.copyWith(startDate: start, endDate: end);
  }

  void setTypeFilter(String type) {
    state = state.copyWith(selectedType: type);
  }

  void setStatusFilter(String status) {
    state = state.copyWith(selectedStatus: status);
  }

  void resetFilters() {
    state = HistoryFilter(selectedTabIndex: state.selectedTabIndex);
  }
}

final historyFilterProvider =
    StateNotifierProvider<HistoryNotifier, HistoryFilter>((ref) {
  return HistoryNotifier();
});

// History Data Providers
final attendanceHistoryListProvider =
    FutureProvider.autoDispose<List<AttendanceRecord>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final repo = ref.read(attendanceRepositoryProvider);

  return await repo.getAttendanceHistory(
    startDate: filter.startDate,
    endDate: filter.endDate,
    type: filter.selectedType,
    status: filter.selectedStatus,
    searchQuery: filter.searchQuery,
  );
});

final logbookHistoryListProvider =
    FutureProvider.autoDispose<List<LogbookEntry>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final repo = ref.read(logbookRepositoryProvider);

  return await repo.getLogbookHistory(
    startDate: filter.startDate,
    endDate: filter.endDate,
    status: filter.selectedStatus,
    searchQuery: filter.searchQuery,
  );
});

final allActivityHistoryListProvider =
    FutureProvider.autoDispose<List<ActivityHistory>>((ref) async {
  final filter = ref.watch(historyFilterProvider);
  final repo = ref.read(activityHistoryRepositoryProvider);

  return await repo.getActivityHistory(
    startDate: filter.startDate,
    endDate: filter.endDate,
    searchQuery: filter.searchQuery,
  );
});
