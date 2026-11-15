import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/notification_service.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/logbook/logbook_screen.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  StreamSubscription<String?>? _payloadSubscription;

  @override
  void initState() {
    super.initState();
    _setupNotificationListener();
  }

  void _setupNotificationListener() {
    _payloadSubscription = NotificationService.instance.payloadStream.listen((payload) {
      if (payload == null) return;

      if (payload == AppConstants.payloadCheckIn || payload == AppConstants.payloadCheckOut) {
        setState(() => _currentIndex = 1); // Absensi Tab
      } else if (payload == AppConstants.payloadLogbook) {
        setState(() => _currentIndex = 2); // Logbook Tab
      }
    });
  }

  @override
  void dispose() {
    _payloadSubscription?.cancel();
    super.dispose();
  }

  void _onTabTapped(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const AttendanceScreen(),
      const LogbookScreen(),
      HistoryScreen(onNavigateTab: _onTabTapped),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(
              color: isDark ? AppColors.darkBorder : AppColors.border,
              width: 1,
            ),
          ),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: _onTabTapped,
          elevation: 0,
          backgroundColor: isDark ? AppColors.darkSurface : Colors.white,
          indicatorColor: isDark
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.primaryContainer,
          destinations: const [
            NavigationDestination(
              icon: Icon(LucideIcons.layoutDashboard, size: 21),
              selectedIcon: Icon(LucideIcons.layoutDashboard, color: AppColors.primary, size: 22),
              label: 'Beranda',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.calendarCheck, size: 21),
              selectedIcon: Icon(LucideIcons.calendarCheck, color: AppColors.primary, size: 22),
              label: 'Presensi',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.fileText, size: 21),
              selectedIcon: Icon(LucideIcons.fileText, color: AppColors.primary, size: 22),
              label: 'Logbook',
            ),
            NavigationDestination(
              icon: Icon(LucideIcons.history, size: 21),
              selectedIcon: Icon(LucideIcons.history, color: AppColors.primary, size: 22),
              label: 'Riwayat',
            ),
          ],
        ),
      ),
    );
  }
}
