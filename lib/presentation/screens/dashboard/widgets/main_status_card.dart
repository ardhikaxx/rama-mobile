import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/attendance_record.dart';
import '../../../../data/models/logbook_entry.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

class MainStatusCard extends StatelessWidget {
  final bool checkInScheduled;
  final AttendanceRecord? checkInRecord;
  final bool checkOutScheduled;
  final AttendanceRecord? checkOutRecord;
  final bool logbookScheduled;
  final LogbookEntry? todayLogbook;
  final VoidCallback onCheckInTap;
  final VoidCallback onCheckOutTap;
  final VoidCallback onLogbookTap;

  const MainStatusCard({
    super.key,
    required this.checkInScheduled,
    this.checkInRecord,
    required this.checkOutScheduled,
    this.checkOutRecord,
    required this.logbookScheduled,
    this.todayLogbook,
    required this.onCheckInTap,
    required this.onCheckOutTap,
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
                title: 'Absen Datang',
                icon: LucideIcons.logIn,
                isScheduled: checkInScheduled,
                isDone: checkInRecord != null,
                detailText: checkInRecord != null
                    ? DateFormatter.formatTime(checkInRecord!.timestamp)
                    : null,
                onTap: onCheckInTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildItemCard(
                context,
                title: 'Absen Pulang',
                icon: LucideIcons.logOut,
                isScheduled: checkOutScheduled,
                isDone: checkOutRecord != null,
                detailText: checkOutRecord != null
                    ? DateFormatter.formatTime(checkOutRecord!.timestamp)
                    : null,
                onTap: onCheckOutTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildItemCard(
                context,
                title: 'Logbook',
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
      statusText = 'Belum';
      variant = BadgeVariant.warning;
    }

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          StatusBadge(
            label: statusText,
            variant: variant,
            fontSize: 10.5,
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          ),
        ],
      ),
    );
  }
}
