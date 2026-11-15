import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_card.dart';

class DailyProgressCard extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int completedTasks;
  final int totalTasks;
  final bool isWorkday;

  const DailyProgressCard({
    super.key,
    required this.progress,
    required this.completedTasks,
    required this.totalTasks,
    required this.isWorkday,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final percentage = (progress * 100).toInt();

    String subtitleText;
    if (!isWorkday) {
      subtitleText = 'Hari ini tidak dijadwalkan magang. Waktunya istirahat!';
    } else if (completedTasks >= totalTasks && totalTasks > 0) {
      subtitleText = 'Luar biasa! Seluruh target aktivitas magang hari ini selesai.';
    } else if (completedTasks == 0) {
      subtitleText = 'Belum ada aktivitas magang yang dicatat hari ini.';
    } else {
      final remaining = totalTasks - completedTasks;
      subtitleText = '$completedTasks dari $totalTasks aktivitas selesai. Tinggal $remaining lagi!';
    }

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      LucideIcons.target,
                      size: 18,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Progres Harian',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isWorkday
                      ? (percentage == 100
                          ? AppColors.successLight
                          : AppColors.primaryContainer)
                      : const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  isWorkday ? '$percentage%' : 'Libur',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: isWorkday
                        ? (percentage == 100
                            ? AppColors.successDark
                            : AppColors.primaryDark)
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: isWorkday ? progress : 1.0,
              minHeight: 10,
              backgroundColor: isDark ? AppColors.darkSurfaceElevated : const Color(0xFFE2E8F0),
              valueColor: AlwaysStoppedAnimation<Color>(
                isWorkday
                    ? (percentage == 100 ? AppColors.success : AppColors.primary)
                    : AppColors.textTertiary,
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            subtitleText,
            style: TextStyle(
              fontSize: 12.5,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
              height: 1.35,
            ),
          ),
        ],
      ),
    );
  }
}
