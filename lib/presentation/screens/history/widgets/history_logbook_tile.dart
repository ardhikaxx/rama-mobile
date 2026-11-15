import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../data/models/logbook_entry.dart';
import '../../../widgets/app_card.dart';
import '../../../widgets/status_badge.dart';

class HistoryLogbookTile extends StatelessWidget {
  final LogbookEntry entry;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback onCopied;

  const HistoryLogbookTile({
    super.key,
    required this.entry,
    required this.onEdit,
    required this.onDelete,
    required this.onCopied,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateObj = DateFormatter.parseDateKey(entry.date);
    final formattedDate = DateFormatter.formatIndonesianDateShort(dateObj);

    BadgeVariant variant;
    switch (entry.status) {
      case AppConstants.logbookSubmitted:
        variant = BadgeVariant.success;
        break;
      case AppConstants.logbookCopied:
        variant = BadgeVariant.info;
        break;
      case AppConstants.logbookCreated:
      default:
        variant = BadgeVariant.warning;
        break;
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Slidable(
        key: ValueKey(entry.id),
        endActionPane: ActionPane(
          motion: const ScrollMotion(),
          children: [
            SlidableAction(
              onPressed: (_) async {
                await Clipboard.setData(ClipboardData(text: entry.generatedTemplate));
                onCopied();
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: LucideIcons.copy,
              label: 'Salin',
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(14)),
            ),
            SlidableAction(
              onPressed: (_) => onEdit(),
              backgroundColor: AppColors.info,
              foregroundColor: Colors.white,
              icon: LucideIcons.edit2,
              label: 'Edit',
            ),
            SlidableAction(
              onPressed: (_) => onDelete(),
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
              icon: LucideIcons.trash2,
              label: 'Hapus',
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(14)),
            ),
          ],
        ),
        child: AppCard(
          padding: const EdgeInsets.all(14),
          onTap: () => _showDetailSheet(context),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(LucideIcons.fileText, color: AppColors.primary, size: 18),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Logbook $formattedDate',
                        style: const TextStyle(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                  StatusBadge(label: entry.statusDisplayName, variant: variant, fontSize: 11),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                entry.activities,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 13,
                  color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                  height: 1.35,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kendala: ${entry.obstacles}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11.5,
                      color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                    ),
                  ),
                  const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiary),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDetailSheet(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return Container(
          padding: const EdgeInsets.all(20),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Detail Logbook (${entry.date})',
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(ctx).pop(),
                    icon: const Icon(LucideIcons.x),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: SingleChildScrollView(
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: isDark ? AppColors.darkBackground : const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SelectableText(
                      entry.generatedTemplate,
                      style: const TextStyle(
                        fontFamily: 'monospace',
                        fontSize: 13,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: entry.generatedTemplate));
                        if (ctx.mounted) {
                          Navigator.of(ctx).pop();
                          onCopied();
                        }
                      },
                      icon: const Icon(LucideIcons.copy, size: 16),
                      label: const Text('Salin Laporan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
