import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../providers/calendar_provider.dart';
import '../../../providers/logbook_provider.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_badge.dart';

class CalendarScreen extends ConsumerWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final calendarState = ref.watch(calendarProvider);
    final calendarNotifier = ref.read(calendarProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kalender Aktivitas Magang'),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.calendarDays, size: 20),
            tooltip: 'Hari Ini',
            onPressed: () {
              calendarNotifier.onDaySelected(DateTime.now(), DateTime.now());
            },
          ),
        ],
      ),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await calendarNotifier.loadMonthData(calendarState.focusedDay);
          },
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            children: [
              // Calendar Card
              AppCard(
                padding: const EdgeInsets.all(12),
                child: TableCalendar(
                  firstDay: DateTime(2020),
                  lastDay: DateTime(2030),
                  focusedDay: calendarState.focusedDay,
                  selectedDayPredicate: (day) => isSameDay(calendarState.selectedDay, day),
                  startingDayOfWeek: StartingDayOfWeek.monday,
                  headerStyle: HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                    titleTextStyle: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    leftChevronIcon: Icon(
                      LucideIcons.chevronLeft,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                    rightChevronIcon: Icon(
                      LucideIcons.chevronRight,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.textPrimary,
                    ),
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: TextStyle(
                      color: isDark ? AppColors.primary : AppColors.primaryDark,
                      fontWeight: FontWeight.w700,
                    ),
                    selectedDecoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, day, events) {
                      final key = DateFormatter.toDateKey(day);
                      final detail = calendarState.monthDetails[key];
                      if (detail == null) return null;

                      Color dotColor = AppColors.success;
                      switch (detail.status) {
                        case DayActivityStatus.completed:
                          dotColor = AppColors.success;
                          break;
                        case DayActivityStatus.partial:
                          dotColor = AppColors.warning;
                          break;
                        case DayActivityStatus.unfulfilled:
                          dotColor = AppColors.danger;
                          break;
                        case DayActivityStatus.notScheduled:
                          return null; // No dot for non-scheduled days
                      }

                      return Positioned(
                        bottom: 4,
                        child: Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: dotColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                      );
                    },
                  ),
                  onDaySelected: (selDay, focDay) {
                    calendarNotifier.onDaySelected(selDay, focDay);
                  },
                  onPageChanged: (focDay) {
                    calendarNotifier.onPageChanged(focDay);
                  },
                ),
              ),

              const SizedBox(height: 14),

              // Legend
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildLegendItem('Lengkap', AppColors.success),
                    _buildLegendItem('Sebagian', AppColors.warning),
                    _buildLegendItem('Terlewat/Izin', AppColors.danger),
                    _buildLegendItem('Libur', AppColors.textTertiary),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // Selected Day Summary Card
              _buildSelectedDayDetail(context, ref, calendarState.selectedDayDetail),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _buildSelectedDayDetail(
    BuildContext context,
    WidgetRef ref,
    DayDetail? detail,
  ) {
    if (detail == null) {
      return const SizedBox.shrink();
    }

    final dateFormatted = DateFormatter.formatIndonesianDate(detail.date);

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
                  const Icon(LucideIcons.calendarCheck, size: 19, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Text(
                    dateFormatted,
                    style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
              StatusBadge(
                label: detail.isWorkday ? 'Hari Kerja' : 'Hari Libur',
                variant: detail.isWorkday ? BadgeVariant.info : BadgeVariant.neutral,
                fontSize: 11,
              ),
            ],
          ),
          const Divider(height: 20),

          // Attendance status (Sebelum Pulang)
          _buildDayItemRow(
            icon: LucideIcons.calendarCheck,
            label: 'Absensi Magang (Sebelum Pulang)',
            value: detail.attendance != null
                ? '${DateFormatter.formatTime(detail.attendance!.timestamp)} (${detail.attendance!.statusDisplayName})'
                : 'Belum Dicatat',
            isDone: detail.attendance != null,
          ),
          const SizedBox(height: 10),

          // Logbook status
          _buildDayItemRow(
            icon: LucideIcons.bookOpen,
            label: 'Logbook Harian',
            value: detail.logbook != null
                ? 'Tersimpan (${detail.logbook!.statusDisplayName})'
                : 'Belum Dibuat',
            isDone: detail.logbook != null,
          ),

          const SizedBox(height: 16),

          // Action Button: Buka di Logbook Generator
          ElevatedButton.icon(
            onPressed: () {
              ref.read(logbookProvider.notifier).selectDate(detail.date);
              Navigator.of(context).pop(); // Back to main tabs
            },
            icon: const Icon(LucideIcons.fileEdit, size: 16),
            label: Text(
              detail.logbook != null ? 'Buka Logbook Tanggal Ini' : 'Buat Logbook Tanggal Ini',
            ),
            style: ElevatedButton.styleFrom(
              minimumSize: const Size.fromHeight(42),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayItemRow({
    required IconData icon,
    required String label,
    required String value,
    required bool isDone,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: isDone ? AppColors.success : AppColors.textSecondary,
        ),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isDone ? AppColors.successDark : AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
