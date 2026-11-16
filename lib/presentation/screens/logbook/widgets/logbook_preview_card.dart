import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/logbook_entry.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

class LogbookPreviewCard extends StatelessWidget {
  final String activities;
  final String learnings;
  final String obstacles;
  final String? reportText;
  final LogbookEntry? savedEntry;
  final VoidCallback onCopyActivities;
  final VoidCallback onCopyLearnings;
  final VoidCallback onCopyObstacles;
  final VoidCallback onCopyAll;
  final VoidCallback onSave;
  final VoidCallback onEdit;
  final VoidCallback onMarkSubmitted;

  const LogbookPreviewCard({
    super.key,
    required this.activities,
    required this.learnings,
    required this.obstacles,
    this.reportText,
    this.savedEntry,
    required this.onCopyActivities,
    required this.onCopyLearnings,
    required this.onCopyObstacles,
    required this.onCopyAll,
    required this.onSave,
    required this.onEdit,
    required this.onMarkSubmitted,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSaved = savedEntry != null;

    BadgeVariant variant = BadgeVariant.info;
    String statusLabel = 'Pratinjau Laporan';

    if (isSaved) {
      switch (savedEntry!.status) {
        case AppConstants.logbookSubmitted:
          variant = BadgeVariant.success;
          statusLabel = 'Sudah Dikirim';
          break;
        case AppConstants.logbookCopied:
          variant = BadgeVariant.info;
          statusLabel = 'Sudah Disalin';
          break;
        case AppConstants.logbookCreated:
        default:
          variant = BadgeVariant.warning;
          statusLabel = 'Sudah Dibuat & Tersimpan';
          break;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section 1: Uraian Aktivitas Magang
        _buildSectionBox(
          isDark: isDark,
          title: '1. Uraian Aktivitas Magang',
          subtitle: 'Aktivitas & tugas operasional yang dikerjakan',
          icon: LucideIcons.briefcase,
          color: AppColors.primary,
          content: activities,
          onCopy: onCopyActivities,
          copyLabel: 'Salin Aktivitas',
        ),
        const SizedBox(height: 14),

        // Section 2: Pembelajaran yang Diperoleh
        _buildSectionBox(
          isDark: isDark,
          title: '2. Pembelajaran yang Diperoleh',
          subtitle: 'Kompetensi teknis, alur kerja & wawasan baru',
          icon: LucideIcons.graduationCap,
          color: AppColors.success,
          content: learnings,
          onCopy: onCopyLearnings,
          copyLabel: 'Salin Pembelajaran',
        ),
        const SizedBox(height: 14),

        // Section 3: Kendala yang Dihadapi
        _buildSectionBox(
          isDark: isDark,
          title: '3. Kendala yang Dihadapi',
          subtitle: 'Tantangan kerja atau status kelancaran kegiatan',
          icon: LucideIcons.shieldAlert,
          color: const Color(0xFFD97706),
          content: obstacles,
          onCopy: onCopyObstacles,
          copyLabel: 'Salin Kendala',
        ),
        const SizedBox(height: 16),

        // Action Card (Aksi Simpan, Salin Semua, Tandai Dikirim)
        AppCard(
          padding: const EdgeInsets.all(16),
          color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
          border: BorderSide(
            color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
            width: 1.2,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.fileCheck2, size: 18, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Aksi & Simpan Logbook',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  StatusBadge(label: statusLabel, variant: variant),
                ],
              ),

              const SizedBox(height: 14),

              // Action Buttons: Salin Semua & Simpan
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: onCopyAll,
                      icon: const Icon(LucideIcons.copy, size: 15),
                      label: const Text('Salin Semua', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                      style: OutlinedButton.styleFrom(
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: onSave,
                      icon: const Icon(LucideIcons.save, size: 15),
                      label: Text(isSaved ? 'Perbarui' : 'Simpan', style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.w700)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSaved ? AppColors.success : AppColors.primary,
                        foregroundColor: isSaved ? Colors.white : AppColors.onPrimary,
                        minimumSize: const Size.fromHeight(44),
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.outlined(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.edit3, size: 18),
                    tooltip: 'Edit Ulang Kata Kunci',
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(44, 44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ],
              ),

              // Submission status toggle if saved
              if (isSaved) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceElevated : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.border,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Kirim ke Portal Resmi',
                              style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              savedEntry?.isSubmitted ?? false
                                  ? 'Laporan sudah ditandai terkirim ke portal.'
                                  : 'Tandai jika sudah ditempel & dikirim ke portal magang.',
                              style: TextStyle(
                                fontSize: 11,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (!(savedEntry?.isSubmitted ?? false))
                        OutlinedButton.icon(
                          onPressed: onMarkSubmitted,
                          icon: const Icon(LucideIcons.send, size: 14),
                          label: const Text('Tandai Dikirim', style: TextStyle(fontSize: 11.5)),
                          style: OutlinedButton.styleFrom(
                            minimumSize: const Size(110, 36),
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                          ),
                        )
                      else
                        const StatusBadge(
                          label: 'Terkirim ✓',
                          variant: BadgeVariant.success,
                          fontSize: 11.5,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSectionBox({
    required bool isDark,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required String content,
    required VoidCallback onCopy,
    required String copyLabel,
  }) {
    return AppCard(
      padding: const EdgeInsets.all(16),
      color: isDark ? AppColors.darkSurface : Colors.white,
      border: BorderSide(
        color: isDark ? AppColors.darkBorder : AppColors.border,
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 18, color: color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: onCopy,
                icon: const Icon(LucideIcons.copy, size: 13),
                label: Text(
                  copyLabel,
                  style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w700),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: color == AppColors.primary ? AppColors.onPrimary : Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  minimumSize: const Size(0, 34),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : const Color(0xFFE2E8F0),
              ),
            ),
            child: SelectableText(
              content.isNotEmpty ? content : '-',
              style: TextStyle(
                fontSize: 13,
                height: 1.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
