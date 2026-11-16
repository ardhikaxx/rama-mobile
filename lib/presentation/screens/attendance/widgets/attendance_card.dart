import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/attendance_record.dart';
import '../../../../data/models/reminder_schedule.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

class AttendanceCard extends StatelessWidget {
  final String type; // check_in or check_out
  final ReminderSchedule? schedule;
  final AttendanceRecord? record;
  final bool isWorkday;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;

  const AttendanceCard({
    super.key,
    required this.type,
    this.schedule,
    this.record,
    required this.isWorkday,
    required this.onConfirm,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isDone = record != null;

    const title = 'Absensi Magang';
    final scheduledTime = schedule?.time ?? '16:30';
    final actualTime = isDone ? DateFormatter.formatTime(record!.timestamp) : null;

    BadgeVariant variant;
    String statusLabel;

    if (!isWorkday) {
      variant = BadgeVariant.neutral;
      statusLabel = 'Libur / Tidak Dijadwalkan';
    } else if (isDone) {
      if (record!.status == AppConstants.statusHadir) {
        variant = BadgeVariant.success;
        statusLabel = 'Hadir ($actualTime)';
      } else if (record!.status == AppConstants.statusIzin) {
        variant = BadgeVariant.warning;
        statusLabel = 'Izin';
      } else if (record!.status == AppConstants.statusSakit) {
        variant = BadgeVariant.danger;
        statusLabel = 'Sakit';
      } else {
        variant = BadgeVariant.neutral;
        statusLabel = 'Libur';
      }
    } else {
      variant = BadgeVariant.warning;
      statusLabel = 'Belum Dicatat';
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      border: isDone
          ? BorderSide(color: AppColors.success.withValues(alpha: 0.5), width: 1.2)
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        LucideIcons.calendarCheck,
                        color: AppColors.primary,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Jadwal Target: $scheduledTime WIB',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              StatusBadge(label: statusLabel, variant: variant),
            ],
          ),

          const SizedBox(height: 14),

          // Detail Info Box
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Waktu Konfirmasi',
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        isDone ? '$actualTime WIB' : '— Belum ada data —',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: isDone
                              ? (isDark ? AppColors.darkTextPrimary : AppColors.textPrimary)
                              : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (record?.notes != null && record!.notes!.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Catatan',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          record!.notes!,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Action Button
          if (!isDone)
            ElevatedButton.icon(
              onPressed: onConfirm,
              icon: const Icon(LucideIcons.check, size: 18),
              label: Text('Konfirmasi $title'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
            )
          else
            Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.successLight,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(LucideIcons.checkCircle2, color: AppColors.successDark, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          'Tercatat ($actualTime)',
                          style: const TextStyle(
                            color: AppColors.successDark,
                            fontWeight: FontWeight.w700,
                            fontSize: 13.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                OutlinedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(LucideIcons.edit2, size: 16),
                  label: const Text('Koreksi'),
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(100, 44),
                  ),
                ),
              ],
            ),
        ],
      ),
    );
  }
}
