import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/reminder_schedule.dart';
import 'app_providers.dart';
import 'settings_provider.dart';

class ReminderScheduleNotifier
    extends StateNotifier<AsyncValue<List<ReminderSchedule>>> {
  final Ref _ref;

  ReminderScheduleNotifier(this._ref) : super(const AsyncValue.loading()) {
    loadSchedules();
  }

  Future<void> loadSchedules() async {
    state = const AsyncValue.loading();
    try {
      final repo = _ref.read(reminderRepositoryProvider);
      final schedules = await repo.getAllSchedules();
      state = AsyncValue.data(schedules);
      await syncNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateSchedule(ReminderSchedule schedule) async {
    try {
      final repo = _ref.read(reminderRepositoryProvider);
      await repo.updateSchedule(schedule);

      final current = state.valueOrNull ?? [];
      final updated = current.map((s) => s.type == schedule.type ? schedule : s).toList();
      state = AsyncValue.data(updated);

      await syncNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateTime(String type, String time) async {
    try {
      final repo = _ref.read(reminderRepositoryProvider);
      await repo.updateTime(type, time);

      final current = state.valueOrNull ?? [];
      final updated = current.map((s) {
        if (s.type == type) {
          return s.copyWith(time: time, updatedAt: DateTime.now());
        }
        return s;
      }).toList();
      state = AsyncValue.data(updated);

      await syncNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> toggleSchedule(String type, bool isEnabled) async {
    try {
      final repo = _ref.read(reminderRepositoryProvider);
      await repo.toggleSchedule(type, isEnabled);

      final current = state.valueOrNull ?? [];
      final updated = current.map((s) {
        if (s.type == type) {
          return s.copyWith(isEnabled: isEnabled, updatedAt: DateTime.now());
        }
        return s;
      }).toList();
      state = AsyncValue.data(updated);

      if (!isEnabled) {
        final notif = _ref.read(notificationServiceProvider);
        await notif.cancelRemindersForType(type);
      } else {
        await syncNotifications();
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> updateActiveDays(String type, List<int> days) async {
    try {
      final repo = _ref.read(reminderRepositoryProvider);
      await repo.updateActiveDays(type, days);

      final current = state.valueOrNull ?? [];
      final updated = current.map((s) {
        if (s.type == type) {
          return s.copyWith(activeDays: days, updatedAt: DateTime.now());
        }
        return s;
      }).toList();
      state = AsyncValue.data(updated);

      await syncNotifications();
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> syncNotifications() async {
    final schedules = state.valueOrNull;
    if (schedules == null) return;

    final notifService = _ref.read(notificationServiceProvider);
    final settings = _ref.read(settingsProvider).valueOrNull;
    final sound = settings?.soundEnabled ?? true;
    final vibration = settings?.vibrationEnabled ?? true;

    for (final schedule in schedules) {
      await notifService.scheduleWeeklyReminders(
        schedule: schedule,
        sound: sound,
        vibration: vibration,
      );
    }
  }
}

final reminderScheduleProvider =
    StateNotifierProvider<ReminderScheduleNotifier, AsyncValue<List<ReminderSchedule>>>((ref) {
  return ReminderScheduleNotifier(ref);
});
