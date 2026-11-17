import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rama_app/presentation/screens/dashboard/dashboard_screen.dart';

void main() {
  testWidgets('DashboardScreen renders without error', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: DashboardScreen(
            onNavigateTab: (_) {},
          ),
        ),
      ),
    );

    // Initial pump shows loading skeleton
    expect(find.byType(DashboardScreen), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 100));
  });
}
