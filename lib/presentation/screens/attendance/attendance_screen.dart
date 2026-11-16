import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/app_snackbar.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/attendance_record.dart';
import '../../../data/models/reminder_schedule.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import 'widgets/attendance_card.dart';
import 'widgets/attendance_dialog.dart';

class AttendanceScreen extends ConsumerWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final attendanceState = ref.watch(attendanceProvider);
    final schedules = ref.watch(reminderScheduleProvider).valueOrNull ?? [];
    final settings = ref.watch(settingsProvider).valueOrNull;

    final now = DateTime.now();
    final isWorkday = settings?.activeDays.contains(now.weekday) ?? true;

    ReminderSchedule? attendanceSchedule;
    for (final s in schedules) {
      if (s.type == AppConstants.reminderAttendance || s.type == AppConstants.reminderCheckOut) {
        attendanceSchedule = s;
        break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Presensi Magang'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.refreshCw, size: 20),
            tooltip: 'Muat Ulang',
            onPressed: () {
              ref.read(attendanceProvider.notifier).loadTodayAttendance();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Skeletonizer(
          enabled: attendanceState.isLoading,
          child: RefreshIndicator(
          onRefresh: () async {
            await ref.read(attendanceProvider.notifier).loadTodayAttendance();
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
            children: [
              // Date Banner
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurface : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.border,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(LucideIcons.calendarDays, color: AppColors.accentAmber, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Tanggal Hari Ini',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        Text(
                          DateFormatter.formatIndonesianDate(now),
                          style: const TextStyle(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Single Daily Attendance Card (Sebelum Pulang)
              AttendanceCard(
                type: AppConstants.attendance,
                schedule: attendanceSchedule,
                record: attendanceState.record,
                isWorkday: isWorkday,
                onConfirm: () => _handleRecord(context, ref, AppConstants.attendance),
                onEdit: () => _handleEdit(context, ref, attendanceState.record!),
              ),

              const SizedBox(height: 18),

              // Policy Info Banner
              AppCard(
                padding: const EdgeInsets.all(14),
                color: isDark ? AppColors.darkSurface : AppColors.background,
                border: BorderSide(
                  color: isDark ? AppColors.darkBorder : AppColors.border,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      LucideIcons.clock,
                      color: AppColors.accentAmber,
                      size: 20,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Konfirmasi absensi magang dilakukan satu kali setiap hari setelah seluruh aktivitas kerja magang selesai sebelum pulang. Waktu kehadiran Anda akan tercatat otomatis dari perangkat dan tersimpan offline secara permanen.',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
        ),
      ),
    );
  }

  void _handleRecord(BuildContext context, WidgetRef ref, String type) {
    AttendanceDialog.show(
      context,
      type: type,
      onConfirmed: (status, notes) async {
        try {
          await ref.read(attendanceProvider.notifier).recordAttendance(
            type: type,
            status: status,
            notes: notes,
          );
          if (context.mounted) {
            AppSnackBar.showSuccess(
              context,
              message: 'Absensi magang sebelum pulang berhasil dicatat!',
            );
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackBar.showError(
              context,
              message: e.toString(),
            );
          }
        }
      },
    );
  }

  void _handleEdit(BuildContext context, WidgetRef ref, AttendanceRecord record) {
    AttendanceDialog.show(
      context,
      type: record.type,
      initialRecord: record,
      onConfirmed: (status, notes) async {
        try {
          final updated = record.copyWith(
            status: status,
            notes: notes,
            updatedAt: DateTime.now(),
          );
          await ref.read(attendanceProvider.notifier).updateRecord(updated);
          if (context.mounted) {
            AppSnackBar.showSuccess(
              context,
              message: 'Data absensi magang berhasil diperbarui!',
            );
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackBar.showError(
              context,
              message: e.toString(),
            );
          }
        }
      },
    );
  }
}
