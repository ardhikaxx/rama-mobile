import 'package:flutter/material.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../data/models/logbook_entry.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

class LogbookPreviewCard extends StatelessWidget {
  final String reportText;
  final LogbookEntry? savedEntry;
  final VoidCallback onCopy;
  final VoidCallback onSave;
  final VoidCallback onEdit;
  final VoidCallback onMarkSubmitted;

  const LogbookPreviewCard({
    super.key,
    required this.reportText,
    this.savedEntry,
    required this.onCopy,
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

    return AppCard(
      padding: const EdgeInsets.all(18),
      color: isDark ? AppColors.darkSurface : const Color(0xFFF1F5F9),
      border: BorderSide(
        color: isDark ? AppColors.darkBorder : const Color(0xFFCBD5E1),
        width: 1.2,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(LucideIcons.fileCheck2, size: 20, color: AppColors.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Hasil Format Logbook',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              StatusBadge(label: statusLabel, variant: variant),
            ],
          ),

          const SizedBox(height: 14),

          // Formatted Report Box
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
            ),
            child: SelectableText(
              reportText,
              style: TextStyle(
                fontFamily: 'monospace',
                fontSize: 13,
                height: 1.5,
                color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Action Buttons: Salin, Simpan, Edit
          Row(
            children: [
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: onCopy,
                  icon: const Icon(LucideIcons.copy, size: 17),
                  label: const Text('Salin Laporan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: ElevatedButton.icon(
                  onPressed: onSave,
                  icon: const Icon(LucideIcons.save, size: 17),
                  label: Text(isSaved ? 'Perbarui' : 'Simpan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isSaved ? AppColors.success : AppColors.primaryDark,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(44),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton.outlined(
                onPressed: onEdit,
                icon: const Icon(LucideIcons.edit3, size: 18),
                tooltip: 'Edit Ulang Input',
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
    );
  }
}
