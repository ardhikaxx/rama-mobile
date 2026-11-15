import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/app_settings.dart';
import 'app_providers.dart';
import 'reminder_provider.dart';

class SettingsNotifier extends StateNotifier<AsyncValue<AppSettings>> {
  final Ref _ref;

  SettingsNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSettings();
  }

  Future<void> loadSettings() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      final settings = await repo.getSettings();
      state = AsyncValue.data(settings);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSettings(AppSettings newSettings) async {
    try {
      final repo = _ref.read(settingsRepositoryProvider);
      await repo.updateSettings(newSettings);
      state = AsyncValue.data(newSettings);

      // Re-evaluate notification schedules if workdays or snooze changed
      final reminderNotifier = _ref.read(reminderScheduleProvider.notifier);
      await reminderNotifier.syncNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateWorkingHours({
    required String startTime,
    required String endTime,
  }) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(
      workingStartTime: startTime,
      workingEndTime: endTime,
    );
    await updateSettings(updated);
  }

  Future<void> updateActiveDays(List<int> days) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(activeDays: days);
    await updateSettings(updated);
  }

  Future<void> updateSnoozeInterval(int minutes) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(snoozeIntervalMinutes: minutes);
    await updateSettings(updated);
  }

  Future<void> updateSoundAndVibration({
    required bool sound,
    required bool vibration,
  }) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(
      soundEnabled: sound,
      vibrationEnabled: vibration,
    );
    await updateSettings(updated);
  }

  Future<void> updateThemeMode(String mode) async {
    final current = state.valueOrNull ?? const AppSettings();
    final updated = current.copyWith(themeMode: mode);
    await updateSettings(updated);
  }
}

final settingsProvider =
    StateNotifierProvider<SettingsNotifier, AsyncValue<AppSettings>>((ref) {
  return SettingsNotifier(ref);
});
