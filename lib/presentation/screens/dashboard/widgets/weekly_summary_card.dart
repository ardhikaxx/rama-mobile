import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_card.dart';

class WeeklySummaryCard extends StatelessWidget {
  final int completeDays;
  final int logbooksCreated;
  final int pendingTasks;
  final int recordedWorkdays;

  const WeeklySummaryCard({
    super.key,
    required this.completeDays,
    required this.logbooksCreated,
    required this.pendingTasks,
    required this.recordedWorkdays,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ringkasan Minggu Ini',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Absensi Lengkap',
                value: '$completeDays Hari',
                icon: LucideIcons.calendarCheck,
                color: AppColors.success,
                bgColor: AppColors.successLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Logbook Dibuat',
                value: '$logbooksCreated Laporan',
                icon: LucideIcons.fileText,
                color: AppColors.primary,
                bgColor: AppColors.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Belum Selesai',
                value: '$pendingTasks Tugas',
                icon: LucideIcons.clock,
                color: AppColors.warning,
                bgColor: AppColors.warningLight,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildMetricTile(
                context,
                title: 'Total Hari Kerja',
                value: '$recordedWorkdays Hari',
                icon: LucideIcons.briefcase,
                color: AppColors.info,
                bgColor: AppColors.infoLight,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMetricTile(
    BuildContext context, {
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color bgColor,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.15) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w500,
                    color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
