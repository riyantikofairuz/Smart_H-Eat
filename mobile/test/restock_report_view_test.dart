import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/views/restock/restock_report_view.dart';

void main() {
  group('RestockReportView (UC-F021 Tests)', () {
    testWidgets('Renders KPI cards, search, menu filter, and restock logs', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: RestockReportView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Laporan Restock'), findsOneWidget);
      expect(find.text('Total Porsi Diisi'), findsOneWidget);
      expect(find.text('Aktivitas Restock'), findsOneWidget);
      expect(find.text('Semua Menu'), findsOneWidget);
      expect(find.textContaining('Riwayat Pengisian Stok'), findsOneWidget);
      expect(find.textContaining('Pak Kemas'), findsWidgets);
    });

    testWidgets('Search query filters restock logs correctly', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: RestockReportView(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter search query "Tarempa"
      await tester.enterText(find.byType(TextField), 'Tarempa');
      await tester.pumpAndSettle();

      expect(find.text('Mie Tarempa Basah'), findsWidgets);
    });
  });
}
