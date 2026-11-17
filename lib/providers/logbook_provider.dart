import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rama_app/core/constants/app_constants.dart';
import 'package:rama_app/core/utils/date_formatter.dart';
import 'package:rama_app/core/utils/sentence_expander.dart';
import 'package:rama_app/data/models/logbook_entry.dart';
import 'app_providers.dart';

class LogbookState {
  final DateTime selectedDate;
  final LogbookEntry? currentEntry;
  final String activities;
  final String learnings;
  final String obstacles;
  final String generatedPreview;
  final bool isLoading;
  final String? errorMessage;
  final bool isSaved;

  const LogbookState({
    required this.selectedDate,
    this.currentEntry,
    this.activities = '',
    this.learnings = '',
    this.obstacles = '',
    this.generatedPreview = '',
    this.isLoading = false,
    this.errorMessage,
    this.isSaved = false,
  });

  bool get hasContent =>
      activities.trim().isNotEmpty &&
      learnings.trim().isNotEmpty &&
      obstacles.trim().isNotEmpty;

  LogbookState copyWith({
    DateTime? selectedDate,
    LogbookEntry? currentEntry,
    String? activities,
    String? learnings,
    String? obstacles,
    String? generatedPreview,
    bool? isLoading,
    String? errorMessage,
    bool? isSaved,
    bool clearCurrentEntry = false,
    bool clearError = false,
  }) {
    return LogbookState(
      selectedDate: selectedDate ?? this.selectedDate,
      currentEntry: clearCurrentEntry ? null : (currentEntry ?? this.currentEntry),
      activities: activities ?? this.activities,
      learnings: learnings ?? this.learnings,
      obstacles: obstacles ?? this.obstacles,
      generatedPreview: generatedPreview ?? this.generatedPreview,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
      isSaved: isSaved ?? this.isSaved,
    );
  }
}

class LogbookNotifier extends StateNotifier<LogbookState> {
  final Ref _ref;

  LogbookNotifier(this._ref)
      : super(LogbookState(selectedDate: DateTime.now(), isLoading: true)) {
    loadLogbookForDate(DateTime.now());
  }

  Future<void> selectDate(DateTime date) async {
    state = state.copyWith(selectedDate: date);
    await loadLogbookForDate(date);
  }

  Future<void> loadLogbookForDate(DateTime date) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(logbookRepositoryProvider);
      final dateKey = DateFormatter.toDateKey(date);
      final entry = await repo.getLogbookByDate(dateKey);

      if (entry != null) {
        state = state.copyWith(
          currentEntry: entry,
          activities: entry.activities,
          learnings: entry.learnings,
          obstacles: entry.obstacles,
          generatedPreview: entry.generatedTemplate,
          isSaved: true,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          clearCurrentEntry: true,
          activities: '',
          learnings: '',
          obstacles: '',
          generatedPreview: '',
          isSaved: false,
          isLoading: false,
        );
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
    }
  }

  void updateFields({
    String? activities,
    String? learnings,
    String? obstacles,
  }) {
    state = state.copyWith(
      activities: activities ?? state.activities,
      learnings: learnings ?? state.learnings,
      obstacles: obstacles ?? state.obstacles,
      isSaved: false,
    );
  }

  String buildReport({
    String? activities,
    String? learnings,
    String? obstacles,
  }) {
    final rawAct = activities ?? state.activities;
    final rawLearn = learnings ?? state.learnings;
    final rawObs = obstacles ?? state.obstacles;

    final finalActivities = SentenceExpander.expandActivities(rawAct);
    final finalLearnings = SentenceExpander.expandLearnings(rawLearn, rawAct);
    final finalObstacles = SentenceExpander.expandObstacles(rawObs);

    final report = LogbookEntry.generateTemplateText(
      date: state.selectedDate,
      activities: finalActivities,
      learnings: finalLearnings,
      obstacles: finalObstacles,
    );
    state = state.copyWith(
      activities: finalActivities,
      learnings: finalLearnings,
      obstacles: finalObstacles,
      generatedPreview: report,
    );
    return report;
  }

  Future<LogbookEntry> saveLogbook({
    String status = AppConstants.logbookCreated,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final repo = _ref.read(logbookRepositoryProvider);
      final dateKey = DateFormatter.toDateKey(state.selectedDate);
      final report = buildReport();
      final now = DateTime.now();

      final entry = LogbookEntry(
        id: state.currentEntry?.id,
        date: dateKey,
        activities: state.activities,
        learnings: state.learnings,
        obstacles: state.obstacles,
        generatedTemplate: report,
        status: status,
        createdAt: state.currentEntry?.createdAt ?? now,
        updatedAt: now,
      );

      final saved = await repo.saveLogbook(entry);

      // Cancel snooze notification for logbook today
      final notif = _ref.read(notificationServiceProvider);
      await notif.cancelSnoozeForType(AppConstants.reminderLogbook);

      state = state.copyWith(
        currentEntry: saved,
        isSaved: true,
        isLoading: false,
      );
      return saved;
    } catch (e) {
      state = state.copyWith(isLoading: false, errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> copyReportToClipboard() async {
    final text = state.generatedPreview.isNotEmpty
        ? state.generatedPreview
        : buildReport();

    await Clipboard.setData(ClipboardData(text: text));

    // Update status to copied if saved
    if (state.currentEntry != null) {
      try {
        final repo = _ref.read(logbookRepositoryProvider);
        final dateKey = DateFormatter.toDateKey(state.selectedDate);
        await repo.updateStatus(dateKey, AppConstants.logbookCopied);
        final updated = state.currentEntry!.copyWith(status: AppConstants.logbookCopied);
        state = state.copyWith(currentEntry: updated);
      } catch (e) {
        // clipboard still succeeded
      }
    }
  }

  Future<void> markAsSubmitted() async {
    if (state.currentEntry == null) return;
    try {
      final repo = _ref.read(logbookRepositoryProvider);
      final dateKey = DateFormatter.toDateKey(state.selectedDate);
      await repo.updateStatus(dateKey, AppConstants.logbookSubmitted);
      final updated = state.currentEntry!.copyWith(status: AppConstants.logbookSubmitted);
      state = state.copyWith(currentEntry: updated);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }

  Future<void> deleteLogbook() async {
    if (state.currentEntry?.id == null) return;
    try {
      final repo = _ref.read(logbookRepositoryProvider);
      await repo.deleteLogbook(state.currentEntry!.id!);
      await loadLogbookForDate(state.selectedDate);
    } catch (e) {
      state = state.copyWith(errorMessage: e.toString());
      rethrow;
    }
  }
}

final logbookProvider =
    StateNotifierProvider<LogbookNotifier, LogbookState>((ref) {
  return LogbookNotifier(ref);
});
