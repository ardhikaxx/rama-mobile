import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/app_providers.dart';
import '../../../providers/attendance_provider.dart';
import '../../../providers/logbook_provider.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/confirm_dialog.dart';

class BackupRestoreScreen extends ConsumerStatefulWidget {
  const BackupRestoreScreen({super.key});

  @override
  ConsumerState<BackupRestoreScreen> createState() => _BackupRestoreScreenState();
}

class _BackupRestoreScreenState extends ConsumerState<BackupRestoreScreen> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final exportService = ref.watch(exportServiceProvider);
    final backupRepo = ref.watch(backupRepositoryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cadangan & Ekspor Data'),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                // Info Card
                AppCard(
                  padding: const EdgeInsets.all(16),
                  color: isDark ? AppColors.darkSurface : AppColors.primaryContainer,
                  border: BorderSide(color: isDark ? AppColors.darkBorder : AppColors.primary.withValues(alpha: 0.35)),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(LucideIcons.shieldCheck, color: AppColors.accentAmber, size: 22),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Penyimpanan 100% Lokal',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: isDark ? AppColors.darkTextPrimary : AppColors.primaryDark,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seluruh data RAMA disimpan secara lokal di perangkat Anda. Gunakan fitur cadangan berkala ini untuk mengantisipasi ganti ponsel atau pembersihan memori.',
                              style: TextStyle(
                                fontSize: 12,
                                color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                                height: 1.35,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Cadangan JSON
                const Text(
                  'Cadangan Penuh (Backup JSON)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActionRow(
                        title: 'Buat & Bagikan Cadangan',
                        subtitle: 'Simpan semua absensi, logbook, dan pengaturan ke berkas JSON',
                        icon: LucideIcons.download,
                        iconColor: AppColors.primary,
                        buttonLabel: 'Ekspor Backup',
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isLoading = true);
                          try {
                            await exportService.shareBackupFile();
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Gagal mengekspor: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                      ),
                      const Divider(height: 24),
                      _buildActionRow(
                        title: 'Pulihkan Data (Restore)',
                        subtitle: 'Ganti atau pulihkan data dari berkas cadangan RAMA (.json)',
                        icon: LucideIcons.upload,
                        iconColor: AppColors.warning,
                        buttonLabel: 'Pilih Berkas',
                        isOutlined: true,
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          final data = await exportService.pickAndParseBackupFile();
                          if (data == null || !context.mounted) return;

                          final confirmed = await ConfirmDialog.show(
                            context,
                            title: 'Konfirmasi Pemulihan Data',
                            message:
                                'Proses ini akan memulihkan data dari berkas cadangan. Data yang ada saat ini akan digantikan dengan data cadangan. Lanjutkan?',
                            confirmText: 'Pulihkan Sekarang',
                            isDestructive: true,
                            icon: LucideIcons.alertTriangle,
                          );

                          if (confirmed == true && mounted) {
                            setState(() => _isLoading = true);
                            try {
                              await backupRepo.restoreFromBackupMap(data, replaceAll: true);
                              // Reload all providers
                              ref.invalidate(settingsProvider);
                              ref.invalidate(reminderScheduleProvider);
                              ref.invalidate(attendanceProvider);
                              ref.invalidate(logbookProvider);

                              if (mounted) {
                                messenger.showSnackBar(
                                  const SnackBar(
                                    content: Text('Data cadangan berhasil dipulihkan!'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                messenger.showSnackBar(
                                  SnackBar(content: Text('Gagal memulihkan data: $e')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Ekspor CSV
                const Text(
                  'Ekspor Format Spreadsheet (CSV)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      _buildActionRow(
                        title: 'Ekspor Rekap Absensi (.csv)',
                        subtitle: 'Buka rekapan presensi di Microsoft Excel atau Google Sheets',
                        icon: LucideIcons.fileSpreadsheet,
                        iconColor: AppColors.success,
                        buttonLabel: 'Ekspor Absensi',
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isLoading = true);
                          try {
                            await exportService.shareAttendanceCsv();
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Gagal mengekspor CSV: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                      ),
                      const Divider(height: 24),
                      _buildActionRow(
                        title: 'Ekspor Rekap Logbook (.csv)',
                        subtitle: 'Daftar semua uraian aktivitas, pembelajaran, dan kendala',
                        icon: LucideIcons.fileText,
                        iconColor: AppColors.info,
                        buttonLabel: 'Ekspor Logbook',
                        onTap: () async {
                          final messenger = ScaffoldMessenger.of(context);
                          setState(() => _isLoading = true);
                          try {
                            await exportService.shareLogbookCsv();
                          } catch (e) {
                            if (mounted) {
                              messenger.showSnackBar(
                                SnackBar(content: Text('Gagal mengekspor CSV: $e')),
                              );
                            }
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),
              ],
            ),
            if (_isLoading)
              Container(
                color: Colors.black38,
                child: const Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionRow({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required String buttonLabel,
    bool isOutlined = false,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 11.5,
                  color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 10),
              if (!isOutlined)
                ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(120, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
                )
              else
                OutlinedButton(
                  onPressed: onTap,
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size(120, 36),
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                  ),
                  child: Text(buttonLabel, style: const TextStyle(fontSize: 12)),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
