import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rama_app/presentation/screens/logbook/logbook_screen.dart';

void main() {
  testWidgets('LogbookScreen renders form fields properly', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: LogbookScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Generator Logbook'), findsOneWidget);
    expect(find.text('Form Pengisian'), findsOneWidget);
    expect(find.text('Hasil & Pratinjau'), findsOneWidget);
    expect(find.text('Buat & Lihat Hasil Laporan'), findsOneWidget);
    expect(find.textContaining('Uraian Aktivitas'), findsWidgets);
    expect(find.textContaining('Pembelajaran'), findsWidgets);
    expect(find.textContaining('Kendala'), findsWidgets);
    expect(find.text('Tidak Ada Kendala'), findsOneWidget);

    // Tap "Tidak Ada Kendala" to verify explicit user action fills the field
    await tester.tap(find.text('Tidak Ada Kendala'));
    await tester.pumpAndSettle();

    expect(find.textContaining('Tidak ada kendala dalam pelaksanaan kegiatan hari ini'), findsOneWidget);
  });
}
