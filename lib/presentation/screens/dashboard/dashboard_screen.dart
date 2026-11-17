import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:rama_app/core/constants/app_constants.dart';
import 'package:rama_app/core/utils/app_snackbar.dart';
import 'package:rama_app/providers/attendance_provider.dart';
import 'package:rama_app/providers/dashboard_provider.dart';
import 'package:rama_app/providers/logbook_provider.dart';
import 'package:rama_app/presentation/screens/attendance/widgets/attendance_dialog.dart';
import 'package:rama_app/presentation/screens/calendar/calendar_screen.dart';
import 'package:rama_app/presentation/screens/settings/reminder_settings_screen.dart';
import 'package:rama_app/presentation/screens/statistics/statistics_screen.dart';
import 'widgets/daily_progress_card.dart';
import 'widgets/greeting_header.dart';
import 'widgets/main_status_card.dart';
import 'widgets/next_reminder_card.dart';
import 'widgets/quick_actions_card.dart';
import 'widgets/weekly_summary_card.dart';

class DashboardScreen extends ConsumerWidget {
  final Function(int) onNavigateTab;

  const DashboardScreen({
    super.key,
    required this.onNavigateTab,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboardAsync = ref.watch(dashboardDataProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(dashboardDataProvider);
            await ref.read(attendanceProvider.notifier).loadTodayAttendance();
            await ref.read(logbookProvider.notifier).loadLogbookForDate(DateTime.now());
          },
          child: dashboardAsync.when(
            loading: () => const Skeletonizer(
              enabled: true,
              child: _DashboardSkeletonView(),
            ),
            error: (err, stack) => SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(24),
                constraints: BoxConstraints(
                  minHeight: MediaQuery.of(context).size.height * 0.7,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Gagal memuat dashboard: $err', textAlign: TextAlign.center),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () => ref.invalidate(dashboardDataProvider),
                      child: const Text('Coba Lagi'),
                    ),
                  ],
                ),
              ),
            ),
            data: (data) {
              return ListView(
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                children: [
                  // App Bar Header
                  GreetingHeader(
                    currentDate: data.currentDate,
                  ),
                  const SizedBox(height: 18),

                  // Today's Status Card (Absensi Magang Sebelum Pulang & Logbook)
                  MainStatusCard(
                    attendanceScheduled: data.attendanceScheduled,
                    attendanceRecord: data.attendanceRecord,
                    logbookScheduled: data.logbookScheduled,
                    todayLogbook: data.todayLogbook,
                    onAttendanceTap: () => _handleAttendance(context, ref, data.attendanceRecord != null),
                    onLogbookTap: () => onNavigateTab(2), // Tab Logbook
                  ),
                  const SizedBox(height: 18),

                  // Quick Actions Card (Kalender, Statistik, Buat Logbook, Lihat Riwayat)
                  QuickActionsCard(
                    onCalendarTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CalendarScreen()),
                      );
                    },
                    onStatisticsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const StatisticsScreen()),
                      );
                    },
                    onLogbookTap: () => onNavigateTab(2),
                    onHistoryTap: () => onNavigateTab(3),
                  ),
                  const SizedBox(height: 18),

                  // Next Reminder Card
                  NextReminderCard(
                    schedule: data.nextReminder,
                    countdown: data.nextReminderCountdown,
                    isPastDeparture: data.isPastDepartureTime,
                    reminderTitle: data.reminderTitle,
                    reminderBadge: data.reminderBadge,
                    reminderMessage: data.reminderMessage,
                    statusType: data.reminderStatusType,
                    onSettingsTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const ReminderSettingsScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 18),

                  // Daily Progress Card
                  DailyProgressCard(
                    progress: data.dailyProgress,
                    completedTasks: data.completedTasksCount,
                    totalTasks: data.totalTasksCount,
                    isWorkday: data.isTodayWorkday,
                  ),
                  const SizedBox(height: 18),

                  // Weekly Summary Card
                  WeeklySummaryCard(
                    completeDays: data.completeDaysThisWeek,
                    logbooksCreated: data.logbooksThisWeek,
                    pendingTasks: data.pendingTasksThisWeek,
                    recordedWorkdays: data.totalWorkdaysRecorded,
                  ),
                  const SizedBox(height: 24),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  void _handleAttendance(BuildContext context, WidgetRef ref, bool alreadyDone) {
    if (alreadyDone) {
      AppSnackBar.showInfo(
        context,
        message: 'Absensi magang hari ini sudah tercatat. Buka tab Presensi untuk koreksi data.',
      );
      onNavigateTab(1); // navigate to Attendance tab
      return;
    }

    AttendanceDialog.show(
      context,
      type: AppConstants.attendance,
      onConfirmed: (status, notes) async {
        try {
          await ref.read(attendanceProvider.notifier).recordAttendance(
            type: AppConstants.attendance,
            status: status,
            notes: notes,
          );
          if (context.mounted) {
            AppSnackBar.showSuccess(
              context,
              message: 'Absensi magang sebelum pulang berhasil dicatat!',
            );
          }
        } catch (e) {
          if (context.mounted) {
            AppSnackBar.showError(
              context,
              message: e.toString(),
            );
          }
        }
      },
    );
  }
}

class _DashboardSkeletonView extends StatelessWidget {
  const _DashboardSkeletonView();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      children: [
        Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(width: 100, height: 22, color: Colors.grey.shade300),
                  const SizedBox(height: 6),
                  Container(width: 180, height: 14, color: Colors.grey.shade300),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 18),
        Container(
          height: 110,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 72,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 80,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        const SizedBox(height: 18),
        Container(
          height: 130,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}
