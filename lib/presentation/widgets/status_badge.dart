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
    Color bg;
    Color text;
    Color border;

    switch (variant) {
      case BadgeVariant.success:
        bg = AppColors.successLight;
        text = AppColors.successDark;
        border = AppColors.success.withValues(alpha: 0.3);
        break;
      case BadgeVariant.warning:
        bg = AppColors.warningLight;
        text = AppColors.warningDark;
        border = AppColors.warning.withValues(alpha: 0.3);
        break;
      case BadgeVariant.danger:
        bg = AppColors.dangerLight;
        text = AppColors.dangerDark;
        border = AppColors.danger.withValues(alpha: 0.3);
        break;
      case BadgeVariant.info:
        bg = AppColors.infoLight;
        text = AppColors.primary;
        border = AppColors.primary.withValues(alpha: 0.3);
        break;
      case BadgeVariant.neutral:
        bg = const Color(0xFFF1F5F9);
        text = AppColors.textSecondary;
        border = AppColors.border;
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
