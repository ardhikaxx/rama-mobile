import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:rama_app/presentation/navigation/main_navigation_screen.dart';
import 'package:rama_app/presentation/navigation/widgets/floating_pill_nav_bar.dart';

void main() {
  testWidgets('RAMA Floating Pill Navigation Bar and Tab Navigation test',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    Finder navLabel(String label) => find.descendant(
          of: find.byType(FloatingPillNavBar),
          matching: find.text(label),
        );

    // Initial state: Beranda is active (has text and icon), others only have icon
    expect(navLabel('Beranda'), findsOneWidget);
    expect(navLabel('Presensi'), findsNothing);
    expect(navLabel('Logbook'), findsNothing);
    expect(navLabel('Riwayat'), findsNothing);

    // Tap Presensi tab icon
    await tester.tap(find.byIcon(LucideIcons.calendarCheck));
    await tester.pumpAndSettle();

    // Now Presensi is active (has text), Beranda is inactive (only icon)
    expect(navLabel('Presensi'), findsOneWidget);
    expect(navLabel('Beranda'), findsNothing);

    // Tap Logbook tab icon
    await tester.tap(find.byIcon(LucideIcons.fileText));
    await tester.pumpAndSettle();

    expect(navLabel('Logbook'), findsOneWidget);
    expect(navLabel('Presensi'), findsNothing);

    // Tap Riwayat tab icon
    await tester.tap(find.byIcon(LucideIcons.history));
    await tester.pumpAndSettle();

    expect(navLabel('Riwayat'), findsOneWidget);
    expect(navLabel('Logbook'), findsNothing);
  });
}
