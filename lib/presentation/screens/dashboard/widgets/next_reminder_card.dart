import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:rama_app/core/constants/app_colors.dart';
import 'package:rama_app/data/models/reminder_schedule.dart';
import 'package:rama_app/presentation/widgets/app_card.dart';

class NextReminderCard extends StatelessWidget {
  final ReminderSchedule? schedule;
  final String? countdown;
  final VoidCallback onSettingsTap;
  final bool isPastDeparture;
  final String? reminderTitle;
  final String? reminderBadge;
  final String? reminderMessage;
  final String? statusType; // 'past_pending', 'all_completed', 'active_countdown', 'upcoming', 'holiday', 'normal'

  const NextReminderCard({
    super.key,
    this.schedule,
    this.countdown,
    required this.onSettingsTap,
    this.isPastDeparture = false,
    bool? isPastDepartureTime,
    this.reminderTitle,
    this.reminderBadge,
    this.reminderMessage,
    this.statusType,
    String? reminderStatusType,
  }) : isPastDepartureResolved = isPastDeparture || (isPastDepartureTime ?? false),
       statusTypeResolved = statusType ?? reminderStatusType;

  final bool isPastDepartureResolved;
  final String? statusTypeResolved;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final type = statusTypeResolved ?? (schedule == null ? 'all_completed' : 'normal');

    Color cardBg;
    BorderSide cardBorder;
    Color iconBg;
    Color iconColor;
    IconData iconData;
    Color titleColor;
    Color badgeBg;
    Color badgeTextColor;

    switch (type) {
      case 'past_pending':
        // Warning / Amber - Past departure time and tasks still pending
        cardBg = isDark ? const Color(0xFF261D0C) : const Color(0xFFFFFBEB);
        cardBorder = BorderSide(
          color: isDark ? const Color(0xFF78350F) : const Color(0xFFFDE68A),
          width: 1.2,
        );
        iconBg = AppColors.warning.withValues(alpha: 0.18);
        iconColor = AppColors.warningDark;
        iconData = LucideIcons.clockAlert;
        titleColor = isDark ? const Color(0xFFFBBF24) : AppColors.warningDark;
        badgeBg = isDark ? const Color(0xFF78350F) : AppColors.warningLight;
        badgeTextColor = isDark ? const Color(0xFFFDE68A) : AppColors.warningDark;
        break;

      case 'all_completed':
        // Success / Green - All tasks done
        cardBg = isDark ? const Color(0xFF0F2317) : const Color(0xFFF0FDF4);
        cardBorder = BorderSide(
          color: isDark ? const Color(0xFF14532D) : const Color(0xFFBBF7D0),
          width: 1,
        );
        iconBg = AppColors.success.withValues(alpha: 0.15);
        iconColor = AppColors.success;
        iconData = LucideIcons.checkCheck;
        titleColor = isDark ? const Color(0xFF4ADE80) : AppColors.successDark;
        badgeBg = isDark ? const Color(0xFF14532D) : AppColors.successLight;
        badgeTextColor = isDark ? const Color(0xFFBBF7D0) : AppColors.successDark;
        break;

      case 'active_countdown':
        // Warm Gold / Primary - In the 1-hour pre-departure window (15:30 - 16:30)
        cardBg = isDark ? const Color(0xFF2B2508) : const Color(0xFFFFFDF0);
        cardBorder = BorderSide(
          color: isDark ? const Color(0xFF71590B) : const Color(0xFFFDE047),
          width: 1.2,
        );
        iconBg = AppColors.primary.withValues(alpha: 0.25);
        iconColor = isDark ? AppColors.primary : AppColors.primaryDark;
        iconData = LucideIcons.bellRing;
        titleColor = isDark ? AppColors.primary : AppColors.primaryDark;
        badgeBg = isDark ? const Color(0xFF71590B) : AppColors.primaryContainer;
        badgeTextColor = isDark ? AppColors.primaryLight : AppColors.primaryDark;
        break;

      case 'holiday':
        // Info / Blue - Holiday
        cardBg = isDark ? AppColors.darkSurface : const Color(0xFFF0F9FF);
        cardBorder = BorderSide(
          color: isDark ? AppColors.darkBorder : const Color(0xFFBAE6FD),
          width: 1,
        );
        iconBg = AppColors.info.withValues(alpha: 0.15);
        iconColor = AppColors.info;
        iconData = LucideIcons.coffee;
        titleColor = isDark ? AppColors.darkTextSecondary : AppColors.info;
        badgeBg = isDark ? AppColors.darkSurfaceElevated : AppColors.infoLight;
        badgeTextColor = AppColors.info;
        break;

      default:
        // Normal / Greenish
        cardBg = isDark ? AppColors.darkSurface : const Color(0xFFF0FDF4);
        cardBorder = BorderSide(
          color: isDark ? AppColors.darkBorder : const Color(0xFFBBF7D0),
          width: 1,
        );
        iconBg = AppColors.success.withValues(alpha: 0.15);
        iconColor = AppColors.success;
        iconData = LucideIcons.bellRing;
        titleColor = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        badgeBg = isDark ? AppColors.darkSurfaceElevated : AppColors.successLight;
        badgeTextColor = AppColors.successDark;
    }

    final displayTitle = reminderTitle ?? 'Pengingat Berikutnya';
    final displayBadge = reminderBadge != null && reminderBadge!.isNotEmpty
        ? reminderBadge!
        : (schedule != null ? schedule!.time : '');
    final displayMessage = reminderMessage != null && reminderMessage!.isNotEmpty
        ? reminderMessage!
        : (schedule != null
            ? '${schedule!.typeDisplayName} • ${countdown ?? "Segera"}'
            : 'Semua pengingat hari ini telah selesai atau nonaktif');

    return AppCard(
      padding: const EdgeInsets.all(16),
      color: cardBg,
      border: cardBorder,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              iconData,
              color: iconColor,
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
                      displayTitle,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    if (displayBadge.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: badgeBg,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          displayBadge,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: badgeTextColor,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  displayMessage,
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
