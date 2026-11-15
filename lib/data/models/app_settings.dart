import '../../core/constants/app_constants.dart';

class AppSettings {
  final String workingStartTime;
  final String workingEndTime;
  final List<int> activeDays;
  final int snoozeIntervalMinutes;
  final int maxSnoozeCount;
  final bool soundEnabled;
  final bool vibrationEnabled;
  final bool snoozeEnabled;
  final String themeMode;
  final String userName;
  final String organizationName;

  const AppSettings({
    this.workingStartTime = '08:00',
    this.workingEndTime = '17:00',
    this.activeDays = const [1, 2, 3, 4, 5],
    this.snoozeIntervalMinutes = 15,
    this.maxSnoozeCount = 5,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
    this.snoozeEnabled = true,
    this.themeMode = 'system',
    this.userName = 'Siswa / Mahasiswa Magang',
    this.organizationName = '',
  });

  AppSettings copyWith({
    String? workingStartTime,
    String? workingEndTime,
    List<int>? activeDays,
    int? snoozeIntervalMinutes,
    int? maxSnoozeCount,
    bool? soundEnabled,
    bool? vibrationEnabled,
    bool? snoozeEnabled,
    String? themeMode,
    String? userName,
    String? organizationName,
  }) {
    return AppSettings(
      workingStartTime: workingStartTime ?? this.workingStartTime,
      workingEndTime: workingEndTime ?? this.workingEndTime,
      activeDays: activeDays ?? this.activeDays,
      snoozeIntervalMinutes: snoozeIntervalMinutes ?? this.snoozeIntervalMinutes,
      maxSnoozeCount: maxSnoozeCount ?? this.maxSnoozeCount,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
      snoozeEnabled: snoozeEnabled ?? this.snoozeEnabled,
      themeMode: themeMode ?? this.themeMode,
      userName: userName ?? this.userName,
      organizationName: organizationName ?? this.organizationName,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'working_start_time': workingStartTime,
      'working_end_time': workingEndTime,
      'active_days': activeDays.join(','),
      'snooze_interval_minutes': snoozeIntervalMinutes,
      'max_snooze_count': maxSnoozeCount,
      'sound_enabled': soundEnabled ? 1 : 0,
      'vibration_enabled': vibrationEnabled ? 1 : 0,
      'snooze_enabled': snoozeEnabled ? 1 : 0,
      'theme_mode': themeMode,
      'user_name': userName,
      'organization_name': organizationName,
    };
  }

  factory AppSettings.fromMap(Map<String, dynamic> map) {
    final daysStr = map['active_days'] as String? ?? '1,2,3,4,5';
    final parsedDays = daysStr
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.tryParse(s.trim()) ?? 1)
        .toList();

    return AppSettings(
      workingStartTime: map['working_start_time'] as String? ?? '08:00',
      workingEndTime: map['working_end_time'] as String? ?? '17:00',
      activeDays: parsedDays.isEmpty ? AppConstants.defaultActiveDays : parsedDays,
      snoozeIntervalMinutes: map['snooze_interval_minutes'] as int? ?? 15,
      maxSnoozeCount: map['max_snooze_count'] as int? ?? 5,
      soundEnabled: (map['sound_enabled'] as int? ?? 1) == 1,
      vibrationEnabled: (map['vibration_enabled'] as int? ?? 1) == 1,
      snoozeEnabled: (map['snooze_enabled'] as int? ?? 1) == 1,
      themeMode: map['theme_mode'] as String? ?? 'system',
      userName: map['user_name'] as String? ?? 'Siswa / Mahasiswa Magang',
      organizationName: map['organization_name'] as String? ?? '',
    );
  }
}
