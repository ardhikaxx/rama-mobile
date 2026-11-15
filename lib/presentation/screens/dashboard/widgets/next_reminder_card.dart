import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../data/models/reminder_schedule.dart';
import '../../../widgets/app_card.dart';

class NextReminderCard extends StatelessWidget {
  final ReminderSchedule? schedule;
  final String? countdown;
  final VoidCallback onSettingsTap;

  const NextReminderCard({
    super.key,
    this.schedule,
    this.countdown,
    required this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : const Color(0xFFF0FDF4),
      border: BorderSide(
        color: isDark ? AppColors.darkBorder : const Color(0xFFBBF7D0),
        width: 1,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppColors.success.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              LucideIcons.bellRing,
              color: AppColors.success,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      'Pengingat Berikutnya',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (schedule != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.successLight,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          schedule!.time,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.successDark,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  schedule != null
                      ? '${schedule!.typeDisplayName} • ${countdown ?? "Segera"}'
                      : 'Semua pengingat hari ini telah selesai atau nonaktif',
                  style: TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onSettingsTap,
            icon: const Icon(LucideIcons.chevronRight, size: 20),
            color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            tooltip: 'Atur Pengingat',
          ),
        ],
      ),
    );
  }
}
