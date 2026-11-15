import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_card.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onCheckInTap;
  final VoidCallback onCheckOutTap;
  final VoidCallback onLogbookTap;
  final VoidCallback onHistoryTap;

  const QuickActionsCard({
    super.key,
    required this.onCheckInTap,
    required this.onCheckOutTap,
    required this.onLogbookTap,
    required this.onHistoryTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Aksi Cepat',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                label: 'Absen Datang',
                icon: LucideIcons.logIn,
                color: AppColors.primary,
                bgColor: AppColors.primaryContainer,
                onTap: onCheckInTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                context,
                label: 'Absen Pulang',
                icon: LucideIcons.logOut,
                color: AppColors.primaryDark,
                bgColor: const Color(0xFFE0E7FF),
                onTap: onCheckOutTap,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _buildActionButton(
                context,
                label: 'Buat Logbook',
                icon: LucideIcons.filePlus,
                color: AppColors.success,
                bgColor: AppColors.successLight,
                onTap: onLogbookTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                context,
                label: 'Lihat Riwayat',
                icon: LucideIcons.history,
                color: AppColors.info,
                bgColor: AppColors.infoLight,
                onTap: onHistoryTap,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required String label,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.18) : bgColor,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 19),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
