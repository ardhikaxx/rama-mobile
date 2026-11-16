import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/attendance_record.dart';
import '../../../../data/models/logbook_entry.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

class MainStatusCard extends StatelessWidget {
  final bool attendanceScheduled;
  final AttendanceRecord? attendanceRecord;
  final bool logbookScheduled;
  final LogbookEntry? todayLogbook;
  final VoidCallback onAttendanceTap;
  final VoidCallback onLogbookTap;

  const MainStatusCard({
    super.key,
    required this.attendanceScheduled,
    this.attendanceRecord,
    required this.logbookScheduled,
    this.todayLogbook,
    required this.onAttendanceTap,
    required this.onLogbookTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Status Aktivitas Hari Ini',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildItemCard(
                context,
                title: 'Absensi Magang',
                subtitle: 'Sebelum Pulang',
                icon: LucideIcons.calendarCheck,
                isScheduled: attendanceScheduled,
                isDone: attendanceRecord != null,
                detailText: attendanceRecord != null
                    ? '${DateFormatter.formatTime(attendanceRecord!.timestamp)} (${attendanceRecord!.statusDisplayName})'
                    : null,
                onTap: onAttendanceTap,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildItemCard(
                context,
                title: 'Logbook Harian',
                subtitle: 'Laporan Magang',
                icon: LucideIcons.bookOpen,
                isScheduled: logbookScheduled,
                isDone: todayLogbook != null,
                detailText: todayLogbook != null
                    ? DateFormatter.formatTime(todayLogbook!.createdAt)
                    : null,
                onTap: onLogbookTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isScheduled,
    required bool isDone,
    String? detailText,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color iconColor;
    Color iconBg;
    String statusText;
    BadgeVariant variant;

    if (!isScheduled) {
      iconColor = AppColors.textSecondary;
      iconBg = isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9);
      statusText = 'Libur';
      variant = BadgeVariant.neutral;
    } else if (isDone) {
      iconColor = AppColors.success;
      iconBg = AppColors.successLight;
      statusText = detailText ?? 'Selesai';
      variant = BadgeVariant.success;
    } else {
      iconColor = AppColors.warning;
      iconBg = AppColors.warningLight;
      statusText = 'Belum Dicatat';
      variant = BadgeVariant.warning;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 11,
              color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 10),
          StatusBadge(
            label: statusText,
            variant: variant,
            fontSize: 11,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          ),
        ],
      ),
    );
  }
}
