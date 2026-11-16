import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

enum BadgeVariant { success, warning, danger, info, neutral }

class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeVariant variant;
  final IconData? icon;
  final double fontSize;
  final EdgeInsets padding;

  const StatusBadge({
    super.key,
    required this.label,
    this.variant = BadgeVariant.neutral,
    this.icon,
    this.fontSize = 12,
    this.padding = const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bg;
    Color text;
    Color border;

    switch (variant) {
      case BadgeVariant.success:
        bg = isDark ? const Color(0xFF064E3B).withValues(alpha: 0.45) : AppColors.successLight;
        text = isDark ? const Color(0xFF6EE7B7) : AppColors.successDark;
        border = isDark ? const Color(0xFF10B981).withValues(alpha: 0.4) : AppColors.success.withValues(alpha: 0.3);
        break;
      case BadgeVariant.warning:
        bg = isDark ? AppColors.darkPrimaryContainer : AppColors.primaryContainer;
        text = isDark ? AppColors.primary : const Color(0xFF92400E);
        border = isDark ? AppColors.primary.withValues(alpha: 0.3) : AppColors.primary.withValues(alpha: 0.4);
        break;
      case BadgeVariant.danger:
        bg = isDark ? const Color(0xFF7F1D1D).withValues(alpha: 0.45) : AppColors.dangerLight;
        text = isDark ? const Color(0xFFFCA5A5) : AppColors.dangerDark;
        border = isDark ? const Color(0xFFEF4444).withValues(alpha: 0.4) : AppColors.danger.withValues(alpha: 0.3);
        break;
      case BadgeVariant.info:
        bg = isDark ? const Color(0xFF1E3A8A).withValues(alpha: 0.45) : AppColors.infoLight;
        text = isDark ? const Color(0xFF93C5FD) : const Color(0xFF1D4ED8);
        border = isDark ? const Color(0xFF3B82F6).withValues(alpha: 0.4) : AppColors.info.withValues(alpha: 0.3);
        break;
      case BadgeVariant.neutral:
        bg = isDark ? AppColors.darkSurfaceElevated : AppColors.divider;
        text = isDark ? AppColors.darkTextSecondary : AppColors.textSecondary;
        border = isDark ? AppColors.darkBorder : AppColors.border;
        break;
    }

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: border, width: 0.8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: fontSize + 2, color: text),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: text,
            ),
          ),
        ],
      ),
    );
  }
}
