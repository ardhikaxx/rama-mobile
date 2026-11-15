import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../data/models/reminder_schedule.dart';
import '../../../providers/reminder_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/permission_service.dart';
import '../../widgets/app_card.dart';

class ReminderSettingsScreen extends ConsumerStatefulWidget {
  const ReminderSettingsScreen({super.key});

  @override
  ConsumerState<ReminderSettingsScreen> createState() => _ReminderSettingsScreenState();
}

class _ReminderSettingsScreenState extends ConsumerState<ReminderSettingsScreen> {
  bool _isNotifGranted = true;
  bool _isExactAlarmGranted = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  Future<void> _checkPermissions() async {
    final notif = await PermissionService.isNotificationGranted();
    final alarm = await PermissionService.isExactAlarmGranted();
    if (mounted) {
      setState(() {
        _isNotifGranted = notif;
        _isExactAlarmGranted = alarm;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final schedules = ref.watch(reminderScheduleProvider).valueOrNull ?? [];
    final reminderNotifier = ref.read(reminderScheduleProvider.notifier);
    final settings = ref.watch(settingsProvider).valueOrNull;
    final settingsNotifier = ref.read(settingsProvider.notifier);

    ReminderSchedule? checkInSchedule;
    ReminderSchedule? checkOutSchedule;
    ReminderSchedule? logbookSchedule;

    for (final s in schedules) {
      if (s.type == AppConstants.reminderCheckIn) checkInSchedule = s;
      if (s.type == AppConstants.reminderCheckOut) checkOutSchedule = s;
      if (s.type == AppConstants.reminderLogbook) logbookSchedule = s;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan Pengingat'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          children: [
            // Permission Notice Card if not granted
            if (!_isNotifGranted || !_isExactAlarmGranted) ...[
              _buildPermissionWarningCard(isDark),
              const SizedBox(height: 16),
            ],

            // Intro Banner
            const Text(
              'Jadwal Pengingat Magang',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            const Text(
              'Atur waktu pengingat harian agar Anda selalu disiplin melakukan absensi dan menulis logbook tepat waktu.',
              style: TextStyle(
                fontSize: 12.5,
                color: AppColors.textSecondary,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 16),

            // 1. Check-In Reminder
            if (checkInSchedule != null)
              _buildReminderCard(
                schedule: checkInSchedule,
                icon: LucideIcons.logIn,
                color: AppColors.primary,
                onToggle: (val) => reminderNotifier.toggleSchedule(checkInSchedule!.type, val),
                onPickTime: () => _pickTimeForSchedule(checkInSchedule!),
                onToggleDay: (day) => _toggleDayForSchedule(checkInSchedule!, day),
              ),
            const SizedBox(height: 14),

            // 2. Check-Out Reminder
            if (checkOutSchedule != null)
              _buildReminderCard(
                schedule: checkOutSchedule,
                icon: LucideIcons.logOut,
                color: AppColors.primaryDark,
                onToggle: (val) => reminderNotifier.toggleSchedule(checkOutSchedule!.type, val),
                onPickTime: () => _pickTimeForSchedule(checkOutSchedule!),
                onToggleDay: (day) => _toggleDayForSchedule(checkOutSchedule!, day),
              ),
            const SizedBox(height: 14),

            // 3. Logbook Reminder
            if (logbookSchedule != null)
              _buildReminderCard(
                schedule: logbookSchedule,
                icon: LucideIcons.bookOpen,
                color: AppColors.success,
                onToggle: (val) => reminderNotifier.toggleSchedule(logbookSchedule!.type, val),
                onPickTime: () => _pickTimeForSchedule(logbookSchedule!),
                onToggleDay: (day) => _toggleDayForSchedule(logbookSchedule!, day),
              ),
            const SizedBox(height: 20),

            // Snooze & Sound Preferences
            const Text(
              'Preferensi Notifikasi & Snooze',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 10),
            AppCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Sound switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Bunyikan Notifikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Putar suara nada dering pengingat', style: TextStyle(fontSize: 12)),
                    value: settings?.soundEnabled ?? true,
                    onChanged: (val) {
                      settingsNotifier.updateSoundAndVibration(
                        sound: val,
                        vibration: settings?.vibrationEnabled ?? true,
                      );
                    },
                  ),
                  const Divider(),

                  // Vibration switch
                  SwitchListTile(
                    contentPadding: EdgeInsets.zero,
                    title: const Text('Getaran Notifikasi', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Getarkan perangkat saat alarm berdering', style: TextStyle(fontSize: 12)),
                    value: settings?.vibrationEnabled ?? true,
                    onChanged: (val) {
                      settingsNotifier.updateSoundAndVibration(
                        sound: settings?.soundEnabled ?? true,
                        vibration: val,
                      );
                    },
                  ),
                  const Divider(),

                  // Snooze interval dropdown
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Interval Pengingat Susulan', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            Text('Ulangi jika belum melakukan aktivitas', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                          ],
                        ),
                        DropdownButton<int>(
                          value: settings?.snoozeIntervalMinutes ?? 15,
                          underline: const SizedBox.shrink(),
                          borderRadius: BorderRadius.circular(12),
                          items: const [
                            DropdownMenuItem(value: 10, child: Text('10 Menit')),
                            DropdownMenuItem(value: 15, child: Text('15 Menit')),
                            DropdownMenuItem(value: 30, child: Text('30 Menit')),
                          ],
                          onChanged: (val) {
                            if (val != null) {
                              settingsNotifier.updateSnoozeInterval(val);
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Battery Optimization Note
            AppCard(
              padding: const EdgeInsets.all(14),
              color: isDark ? AppColors.darkSurface : const Color(0xFFF8FAFC),
              border: BorderSide(
                color: isDark ? AppColors.darkBorder : AppColors.border,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(LucideIcons.batteryCharging, size: 18, color: AppColors.info),
                      SizedBox(width: 8),
                      Text('Tips Keakuratan Alarm & Baterai', style: TextStyle(fontSize: 13.5, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Beberapa pabrikan Android menerapkan pembatasan baterai agresif. Agar notifikasi pengingat tepat waktu, Anda dapat mengecualikan RAMA dari pengoptimalan baterai.',
                    style: TextStyle(fontSize: 12, color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary, height: 1.35),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: () async {
                      await PermissionService.requestIgnoreBatteryOptimizations();
                    },
                    icon: const Icon(LucideIcons.shieldCheck, size: 16),
                    label: const Text('Buka Pengaturan Baterai', style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(36),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionWarningCard(bool isDark) {
    return AppCard(
      padding: const EdgeInsets.all(14),
      color: isDark ? AppColors.darkSurface : const Color(0xFFFFFBEB),
      border: const BorderSide(color: Color(0xFFFDE68A)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(LucideIcons.alertTriangle, color: AppColors.warning, size: 20),
              SizedBox(width: 8),
              Text(
                'Izin Notifikasi Diperlukan',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Untuk menampilkan pengingat absensi dan logbook tepat waktu, RAMA membutuhkan izin notifikasi dan alarm tepat di perangkat Android Anda.',
            style: TextStyle(fontSize: 12, height: 1.35),
          ),
          const SizedBox(height: 10),
          ElevatedButton(
            onPressed: () async {
              await PermissionService.requestNotificationPermission();
              await PermissionService.requestExactAlarmPermission();
              await _checkPermissions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(36),
            ),
            child: const Text('Aktifkan Izin Sistem', style: TextStyle(fontSize: 12)),
          ),
        ],
      ),
    );
  }

  Widget _buildReminderCard({
    required ReminderSchedule schedule,
    required IconData icon,
    required Color color,
    required Function(bool) onToggle,
    required VoidCallback onPickTime,
    required Function(int) onToggleDay,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AppCard(
      padding: const EdgeInsets.all(16),
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
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: color, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        schedule.typeDisplayName,
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                      Text(
                        schedule.message,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 11.5,
                          color: isDark ? AppColors.darkTextSecondary : AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Switch(
                value: schedule.isEnabled,
                onChanged: onToggle,
                activeThumbColor: AppColors.primary,
              ),
            ],
          ),

          const SizedBox(height: 12),
          const Divider(),
          const SizedBox(height: 8),

          // Time Picker button
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Jam Pengingat:', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
              InkWell(
                onTap: schedule.isEnabled ? onPickTime : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: schedule.isEnabled ? AppColors.primaryContainer : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: schedule.isEnabled ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        LucideIcons.clock,
                        size: 15,
                        color: schedule.isEnabled ? AppColors.primary : AppColors.textTertiary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${schedule.time} WIB',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: schedule.isEnabled ? AppColors.primaryDark : AppColors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Active Days Selector
          const Text('Hari Aktif:', style: TextStyle(fontSize: 12.5, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(7, (i) {
              final dayIndex = i + 1; // 1 = Monday .. 7 = Sunday
              final isDayActive = schedule.activeDays.contains(dayIndex);
              final dayLabel = AppConstants.shortDayNames[dayIndex] ?? '';

              return InkWell(
                onTap: schedule.isEnabled ? () => onToggleDay(dayIndex) : null,
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isDayActive
                        ? (schedule.isEnabled ? AppColors.primary : AppColors.textSecondary)
                        : (isDark ? AppColors.darkSurfaceElevated : const Color(0xFFF1F5F9)),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isDayActive ? Colors.transparent : (isDark ? AppColors.darkBorder : AppColors.border),
                    ),
                  ),
                  child: Text(
                    dayLabel,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: isDayActive
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
    );
  }

  Future<void> _pickTimeForSchedule(ReminderSchedule schedule) async {
    final current = schedule.timeOfDay;
    final picked = await showTimePicker(
      context: context,
      initialTime: current,
    );

    if (picked != null) {
      final formatted = DateFormatter.formatTimeOfDay(picked);
      await ref.read(reminderScheduleProvider.notifier).updateTime(schedule.type, formatted);
    }
  }

  Future<void> _toggleDayForSchedule(ReminderSchedule schedule, int day) async {
    final days = List<int>.from(schedule.activeDays);
    if (days.contains(day)) {
      if (days.length > 1) {
        days.remove(day);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Minimal satu hari aktif harus dipilih.')),
        );
        return;
      }
    } else {
      days.add(day);
      days.sort();
    }
    await ref.read(reminderScheduleProvider.notifier).updateActiveDays(schedule.type, days);
  }
}
