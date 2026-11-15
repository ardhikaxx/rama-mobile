import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateFormatter {
  static const List<String> _hari = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static String toDateKey(DateTime dateTime) {
    return DateFormat('yyyy-MM-dd').format(dateTime);
  }

  static DateTime parseDateKey(String key) {
    return DateTime.parse(key);
  }

  static String formatIndonesianDate(DateTime dateTime) {
    final dayName = _hari[dateTime.weekday - 1];
    final day = dateTime.day;
    final monthName = _bulan[dateTime.month - 1];
    final year = dateTime.year;
    return '$dayName, $day $monthName $year';
  }

  static String formatIndonesianDateShort(DateTime dateTime) {
    final day = dateTime.day;
    final monthName = _bulan[dateTime.month - 1].substring(0, 3);
    final year = dateTime.year;
    return '$day $monthName $year';
  }

  static String formatMonthYear(DateTime dateTime) {
    final monthName = _bulan[dateTime.month - 1];
    return '$monthName ${dateTime.year}';
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatTimeOfDay(TimeOfDay time) {
    final h = time.hour.toString().padLeft(2, '0');
    final m = time.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  static TimeOfDay parseTimeString(String timeStr) {
    final parts = timeStr.split(':');
    final hour = int.tryParse(parts[0]) ?? 8;
    final minute = parts.length > 1 ? (int.tryParse(parts[1]) ?? 0) : 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String getGreeting([DateTime? now]) {
    final time = now ?? DateTime.now();
    final hour = time.hour;

    if (hour >= 4 && hour < 11) {
      return 'Selamat Pagi';
    } else if (hour >= 11 && hour < 15) {
      return 'Selamat Siang';
    } else if (hour >= 15 && hour < 18) {
      return 'Selamat Sore';
    } else {
      return 'Selamat Malam';
    }
  }

  static String getCountdownText(TimeOfDay targetTime) {
    final now = DateTime.now();
    var target = DateTime(
      now.year,
      now.month,
      now.day,
      targetTime.hour,
      targetTime.minute,
    );

    if (target.isBefore(now)) {
      // scheduled for next day
      target = target.add(const Duration(days: 1));
    }

    final diff = target.difference(now);
    final hours = diff.inHours;
    final minutes = diff.inMinutes % 60;

    if (hours > 0) {
      return '$hours jam $minutes menit lagi';
    } else if (minutes > 0) {
      return '$minutes menit lagi';
    } else {
      return 'Kurang dari 1 menit';
    }
  }
}
