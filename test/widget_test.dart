import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rama_app/presentation/navigation/main_navigation_screen.dart';

void main() {
  testWidgets('RAMA Navigation Bar test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MainNavigationScreen(),
        ),
      ),
    );

    // Verify navigation tabs exist
    expect(find.text('Beranda'), findsOneWidget);
    expect(find.text('Presensi'), findsOneWidget);
    expect(find.text('Logbook'), findsOneWidget);
    expect(find.text('Riwayat'), findsOneWidget);
  });
}
