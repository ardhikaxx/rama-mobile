import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../widgets/app_card.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback onCalendarTap;
  final VoidCallback onStatisticsTap;
  final VoidCallback onLogbookTap;
  final VoidCallback onHistoryTap;

  const QuickActionsCard({
    super.key,
    required this.onCalendarTap,
    required this.onStatisticsTap,
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
                label: 'Kalender Magang',
                subtitle: 'Pantau Jadwal',
                icon: LucideIcons.calendar,
                color: const Color(0xFF8B5CF6),
                bgColor: const Color(0xFFF3E8FF),
                onTap: onCalendarTap,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _buildActionButton(
                context,
                label: 'Statistik & Rekap',
                subtitle: 'Grafik & Kepatuhan',
                icon: LucideIcons.barChart2,
                color: AppColors.accentAmber,
                bgColor: AppColors.primaryContainer,
                onTap: onStatisticsTap,
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
                subtitle: 'Generator Cepat',
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
                subtitle: 'Rekap Aktivitas',
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
    required String subtitle,
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(9),
            decoration: BoxDecoration(
              color: isDark ? color.withValues(alpha: 0.18) : bgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  subtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.5,
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
