import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:rama_app/presentation/navigation/main_navigation_screen.dart';

void main() {
  testWidgets('RAMA Floating Pill Navigation Bar test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    // Initial state: Beranda is active (has text and icon), others only have icon
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Presensi'), findsNothing);
    expect(find.text('Logbook'), findsNothing);
    expect(find.text('Riwayat'), findsNothing);

    // Tap Presensi tab icon
    await tester.tap(find.byIcon(LucideIcons.calendarCheck));
    await tester.pumpAndSettle();

    // Now Presensi is active (has text), Beranda is inactive (only icon)
    expect(find.text('Presensi'), findsOneWidget);
    expect(find.text('Beranda'), findsNothing);
  });
}
