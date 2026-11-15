import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import '../../../core/constants/app_constants.dart';
import '../../../services/notification_service.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/dashboard/dashboard_screen.dart';
import '../screens/history/history_screen.dart';
import '../screens/logbook/logbook_screen.dart';
import 'widgets/floating_pill_nav_bar.dart';

class MainNavigationScreen extends ConsumerStatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  ConsumerState<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends ConsumerState<MainNavigationScreen> {
  int _currentIndex = 0;
  StreamSubscription<String?>? _payloadSubscription;

  static const _navItems = [
    FloatingNavItem(icon: LucideIcons.layoutDashboard, label: 'Beranda'),
    FloatingNavItem(icon: LucideIcons.calendarCheck, label: 'Presensi'),
    FloatingNavItem(icon: LucideIcons.fileText, label: 'Logbook'),
    FloatingNavItem(icon: LucideIcons.history, label: 'Riwayat'),
  ];

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
    final screens = [
      DashboardScreen(onNavigateTab: _onTabTapped),
      const AttendanceScreen(),
      const LogbookScreen(),
      HistoryScreen(onNavigateTab: _onTabTapped),
    ];

    return Scaffold(
      extendBody: true,
      body: IndexedStack(
        index: _currentIndex,
        children: screens,
      ),
      bottomNavigationBar: FloatingPillNavBar(
        currentIndex: _currentIndex,
        onTabTapped: _onTabTapped,
        items: _navItems,
      ),
    );
  }
}
