import 'package:flutter/material.dart';
import '../../core/constants/app_constants.dart';

class ReminderSchedule {
  final int? id;
  final String type; // check_in, check_out, logbook
  final String time; // HH:mm
  final bool isEnabled;
  final List<int> activeDays; // 1 = Senin .. 7 = Minggu
  final String title;
  final String message;
  final DateTime? updatedAt;

  const ReminderSchedule({
    this.id,
    required this.type,
    required this.time,
    this.isEnabled = true,
    this.activeDays = const [1, 2, 3, 4, 5],
    required this.title,
    required this.message,
    this.updatedAt,
  });

  TimeOfDay get timeOfDay {
    final parts = time.split(':');
    final h = int.tryParse(parts[0]) ?? 8;
    final m = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: h, minute: m);
  }

  int get hour => timeOfDay.hour;
  int get minute => timeOfDay.minute;

  String get typeDisplayName {
    switch (type) {
      case AppConstants.reminderCheckIn:
        return 'Absensi Datang';
      case AppConstants.reminderCheckOut:
        return 'Absensi Pulang';
      case AppConstants.reminderLogbook:
        return 'Pengisian Logbook';
      default:
        return 'Pengingat';
    }
  }

  ReminderSchedule copyWith({
    int? id,
    String? type,
    String? time,
    bool? isEnabled,
    List<int>? activeDays,
    String? title,
    String? message,
    DateTime? updatedAt,
  }) {
    return ReminderSchedule(
      id: id ?? this.id,
      type: type ?? this.type,
      time: time ?? this.time,
      isEnabled: isEnabled ?? this.isEnabled,
      activeDays: activeDays ?? this.activeDays,
      title: title ?? this.title,
      message: message ?? this.message,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'time': time,
      'is_enabled': isEnabled ? 1 : 0,
      'active_days': activeDays.join(','),
      'title': title,
      'message': message,
      'updated_at': (updatedAt ?? DateTime.now()).toIso8601String(),
    };
  }

  factory ReminderSchedule.fromMap(Map<String, dynamic> map) {
    final daysStr = map['active_days'] as String? ?? '1,2,3,4,5';
    final parsedDays = daysStr
        .split(',')
        .where((s) => s.trim().isNotEmpty)
        .map((s) => int.tryParse(s.trim()) ?? 1)
        .toList();

    return ReminderSchedule(
      id: map['id'] as int?,
      type: map['type'] as String,
      time: map['time'] as String,
      isEnabled: (map['is_enabled'] as int? ?? 1) == 1,
      activeDays: parsedDays.isEmpty ? AppConstants.defaultActiveDays : parsedDays,
      title: map['title'] as String? ?? '',
      message: map['message'] as String? ?? '',
      updatedAt: map['updated_at'] != null ? DateTime.tryParse(map['updated_at'] as String) : null,
    );
  }

  static List<ReminderSchedule> defaultSchedules() {
    return [
      const ReminderSchedule(
        type: AppConstants.reminderCheckIn,
        time: '07:30',
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5],
        title: 'Waktunya Absensi Datang',
        message: 'Jangan lupa catat kehadiran magangmu hari ini.',
      ),
      const ReminderSchedule(
        type: AppConstants.reminderCheckOut,
        time: '16:00',
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5],
        title: 'Waktunya Absensi Pulang',
        message: 'Pastikan absensi pulangmu sudah dicatat sebelum meninggalkan tempat magang.',
      ),
      const ReminderSchedule(
        type: AppConstants.reminderLogbook,
        time: '17:00',
        isEnabled: true,
        activeDays: [1, 2, 3, 4, 5],
        title: 'Jangan Lupa Isi Logbook',
        message: 'Yuk, dokumentasikan aktivitas dan pembelajaranmu hari ini.',
      ),
    ];
  }
}
