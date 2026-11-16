import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:skeletonizer/skeletonizer.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/settings_provider.dart';
import '../../widgets/app_card.dart';
import 'about_screen.dart';
import 'backup_restore_screen.dart';
import 'reminder_settings_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
      ),
      body: SafeArea(
        child: settingsAsync.when(
          loading: () => const Skeletonizer(
            enabled: true,
            child: _SettingsSkeletonView(),
          ),
          error: (err, _) => Center(child: Text('Gagal memuat: $err')),
          data: (settings) {
            return ListView(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              children: [
                // General Schedule & Workdays
                const Text(
                  'Jadwal & Hari Kerja',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Working hours
                      InkWell(
                        onTap: () => _pickWorkingHours(context, ref, settings.workingStartTime, settings.workingEndTime),
                        borderRadius: BorderRadius.circular(10),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Row(
                                children: [
                                  Icon(LucideIcons.clock3, size: 18, color: AppColors.primary),
                                  SizedBox(width: 10),
                                  Text(
                                    'Jam Kerja Magang',
                                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Text(
                                    '${settings.workingStartTime} - ${settings.workingEndTime}',
                                    style: const TextStyle(
                                      fontSize: 13.5,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  const Icon(LucideIcons.chevronRight, size: 16, color: AppColors.textTertiary),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const Divider(height: 22),

                      // Active Workdays
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
                              Icon(LucideIcons.calendarDays, size: 18, color: AppColors.primary),
                              SizedBox(width: 10),
                              Text(
                                'Hari Aktif Magang',
                                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(7, (i) {
                              final dayIndex = i + 1;
                              final isActive = settings.activeDays.contains(dayIndex);
                              final label = AppConstants.shortDayNames[dayIndex] ?? '';

                              return InkWell(
                                onTap: () => _toggleWorkday(ref, settings.activeDays, dayIndex),
                                borderRadius: BorderRadius.circular(8),
                                child: Container(
                                  width: 38,
                                  height: 38,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: isActive
                                        ? AppColors.primary
                                        : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9)),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(
                                      color: isActive ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.border),
                                    ),
                                  ),
                                  child: Text(
                                    label,
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: isActive
                                          ? Colors.white
                                          : (isDark ? AppColors.darkTextSecondary : AppColors.textSecondary),
                                    ),
                                  ),
                                ),
                              );
                            }),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Navigation Shortcuts
                const Text(
                  'Preferensi & Data',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: Column(
                    children: [
                      _buildSettingsTile(
                        icon: LucideIcons.bell,
                        color: AppColors.primary,
                        title: 'Pengaturan Pengingat & Notifikasi',
                        subtitle: 'Atur jam alarm datang, pulang, logbook, dan snooze',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const ReminderSettingsScreen()),
                          );
                        },
                      ),
                      const Divider(),
                      _buildSettingsTile(
                        icon: LucideIcons.hardDriveDownload,
                        color: AppColors.success,
                        title: 'Cadangan & Ekspor Data',
                        subtitle: 'Ekspor backup JSON, CSV absensi, dan pulihkan data',
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const BackupRestoreScreen()),
                          );
                        },
                      ),
                      const Divider(),
                      _buildThemeSelector(context, ref, settings.themeMode),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // App Info
                const Text(
                  'Aplikasi',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 10),
                AppCard(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: _buildSettingsTile(
                    icon: LucideIcons.info,
                    color: AppColors.info,
                    title: 'Tentang RAMA',
                    subtitle: 'Versi ${AppConstants.appVersion} • Biar Magang Lebih Teratur',
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const AboutScreen()),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 28),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required Color color,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11.5)),
      trailing: const Icon(LucideIcons.chevronRight, size: 18),
      onTap: onTap,
    );
  }

  Widget _buildThemeSelector(BuildContext context, WidgetRef ref, String currentMode) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(LucideIcons.palette, color: AppColors.primary, size: 20),
              ),
              const SizedBox(width: 14),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Tema Tampilan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                  Text('Mode terang, gelap, atau sistem', style: TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
                ],
              ),
            ],
          ),
          DropdownButton<String>(
            value: currentMode,
            underline: const SizedBox.shrink(),
            borderRadius: BorderRadius.circular(12),
            items: const [
              DropdownMenuItem(value: 'system', child: Text('Sistem')),
              DropdownMenuItem(value: 'light', child: Text('Terang')),
              DropdownMenuItem(value: 'dark', child: Text('Gelap')),
            ],
            onChanged: (val) {
              if (val != null) {
                ref.read(settingsProvider.notifier).updateThemeMode(val);
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _pickWorkingHours(
    BuildContext context,
    WidgetRef ref,
    String currentStart,
    String currentEnd,
  ) async {
    final startParts = currentStart.split(':');
    final startTime = TimeOfDay(
      hour: int.tryParse(startParts[0]) ?? 8,
      minute: int.tryParse(startParts[1]) ?? 0,
    );

    final pickedStart = await showTimePicker(
      context: context,
      initialTime: startTime,
      helpText: 'PILIH JAM MULAI KERJA',
    );
    if (pickedStart == null) return;

    if (context.mounted) {
      final endParts = currentEnd.split(':');
      final endTime = TimeOfDay(
        hour: int.tryParse(endParts[0]) ?? 17,
        minute: int.tryParse(endParts[1]) ?? 0,
      );

      final pickedEnd = await showTimePicker(
        context: context,
        initialTime: endTime,
        helpText: 'PILIH JAM SELESAI KERJA',
      );
      if (pickedEnd == null) return;

      final startStr = DateFormatter.formatTimeOfDay(pickedStart);
      final endStr = DateFormatter.formatTimeOfDay(pickedEnd);

      await ref.read(settingsProvider.notifier).updateWorkingHours(
            startTime: startStr,
            endTime: endStr,
          );
    }
  }

  void _toggleWorkday(WidgetRef ref, List<int> currentDays, int day) {
    final updated = List<int>.from(currentDays);
    if (updated.contains(day)) {
      if (updated.length > 1) {
        updated.remove(day);
      }
    } else {
      updated.add(day);
      updated.sort();
    }
    ref.read(settingsProvider.notifier).updateActiveDays(updated);
  }
}

class _SettingsSkeletonView extends StatelessWidget {
  const _SettingsSkeletonView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      children: [
        const Text(
          'Jadwal & Hari Kerja',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(LucideIcons.clock3, size: 18),
                      SizedBox(width: 10),
                      Text('Jam Kerja Harian'),
                    ],
                  ),
                  Text('08.00 - 16.30 WIB'),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 10),
              Row(
                children: List.generate(
                  5,
                  (i) => Expanded(
                    child: Container(
                      height: 38,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'Notifikasi & Pengingat',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Container(height: 48),
        ),
        const SizedBox(height: 20),
        const Text(
          'Preferensi Lainnya',
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 10),
        AppCard(
          padding: const EdgeInsets.all(16),
          child: Container(height: 48),
        ),
      ],
    );
  }
}
