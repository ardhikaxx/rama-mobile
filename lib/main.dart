import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/constants/app_constants.dart';
import 'core/theme/app_theme.dart';
import 'presentation/navigation/main_navigation_screen.dart';
import 'providers/settings_provider.dart';
import 'services/notification_service.dart';
import 'services/permission_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notification service & timezone
  try {
    await NotificationService.instance.initialize();
    // Non-blocking permission request
    PermissionService.requestNotificationPermission();
  } catch (e) {
    debugPrint('Notification service initialization notice: $e');
  }

  runApp(
    const ProviderScope(
      child: RamaApp(),
    ),
  );
}

class RamaApp extends ConsumerWidget {
  const RamaApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    final themeModeStr = settingsAsync.valueOrNull?.themeMode ?? 'system';

    ThemeMode themeMode;
    switch (themeModeStr) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      case 'system':
      default:
        themeMode = ThemeMode.system;
        break;
    }

    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('id', 'ID'),
        Locale('en', 'US'),
      ],
      locale: const Locale('id', 'ID'),
      home: const MainNavigationScreen(),
    );
  }
}
