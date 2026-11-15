import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../providers/attendance_provider.dart';
import '../../../../providers/dashboard_provider.dart';
import '../../../../providers/logbook_provider.dart';
import '../attendance/widgets/attendance_dialog.dart';
import '../settings/reminder_settings_screen.dart';
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
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 48, color: Colors.red),
                    const SizedBox(height: 12),
                    Text('Gagal memuat dashboard: $err'),
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

                  // Today's Status Card
                  MainStatusCard(
                    checkInScheduled: data.checkInScheduled,
                    checkInRecord: data.checkInRecord,
                    checkOutScheduled: data.checkOutScheduled,
                    checkOutRecord: data.checkOutRecord,
                    logbookScheduled: data.logbookScheduled,
                    todayLogbook: data.todayLogbook,
                    onCheckInTap: () => _handleCheckIn(context, ref, data.checkInRecord != null),
                    onCheckOutTap: () => _handleCheckOut(context, ref, data.checkOutRecord != null),
                    onLogbookTap: () => onNavigateTab(2), // Tab Logbook
                  ),
                  const SizedBox(height: 18),

                  // Next Reminder Card
                  NextReminderCard(
                    schedule: data.nextReminder,
                    countdown: data.nextReminderCountdown,
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
                  const SizedBox(height: 18),

                  // Quick Actions Card
                  QuickActionsCard(
                    onCheckInTap: () => _handleCheckIn(context, ref, data.checkInRecord != null),
                    onCheckOutTap: () => _handleCheckOut(context, ref, data.checkOutRecord != null),
                    onLogbookTap: () => onNavigateTab(2),
                    onHistoryTap: () => onNavigateTab(3),
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

  void _handleCheckIn(BuildContext context, WidgetRef ref, bool alreadyDone) {
    if (alreadyDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi datang hari ini sudah tercatat. Buka tab Absensi untuk koreksi data.'),
        ),
      );
      onNavigateTab(1); // navigate to Attendance tab
      return;
    }

    AttendanceDialog.show(
      context,
      type: 'check_in',
      onConfirmed: (status, notes) async {
        try {
          await ref.read(attendanceProvider.notifier).recordAttendance(
            type: 'check_in',
            status: status,
            notes: notes,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Absensi datang berhasil dicatat!')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
    );
  }

  void _handleCheckOut(BuildContext context, WidgetRef ref, bool alreadyDone) {
    if (alreadyDone) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Absensi pulang hari ini sudah tercatat. Buka tab Absensi untuk koreksi data.'),
        ),
      );
      onNavigateTab(1); // navigate to Attendance tab
      return;
    }

    AttendanceDialog.show(
      context,
      type: 'check_out',
      onConfirmed: (status, notes) async {
        try {
          await ref.read(attendanceProvider.notifier).recordAttendance(
            type: 'check_out',
            status: status,
            notes: notes,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Absensi pulang berhasil dicatat!')),
            );
          }
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(e.toString())),
            );
          }
        }
      },
    );
  }
}
