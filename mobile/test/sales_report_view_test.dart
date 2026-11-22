import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/views/report/sales_report_view.dart';

void main() {
  group('SalesReportView (STEP 4 Tests)', () {
    testWidgets('Renders all cards and design elements matching Mockup Image 4',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SalesReportView(),
        ),
      );
      await tester.pumpAndSettle();

      // 1. Header elements
      expect(find.text('SMART H-EAT'), findsOneWidget);
      expect(find.text('OPERATOR MODE'), findsOneWidget);
      expect(find.text('Laporan Penjualan'), findsOneWidget);

      // 2. Period filter tabs
      expect(find.text('Hari Ini'), findsOneWidget);
      expect(find.text('Minggu Ini'), findsOneWidget);
      expect(find.text('Bulan Ini'), findsOneWidget);

      // 3. Summary KPI Cards
      expect(find.text('Total Pendapatan'), findsOneWidget);
      expect(find.text('Total Terjual'), findsOneWidget);
      expect(find.text('Rp 19 Jt'), findsOneWidget);
      expect(find.text('482 Porsi'), findsOneWidget);

      // 4. Tren Penjualan (7 Hari) & Peak
      expect(find.text('Tren Penjualan (7 Hari)'), findsOneWidget);
      expect(find.text('Puncak: Jum (94 Porsi)'), findsOneWidget);

      // 5. Day labels on bar chart
      expect(find.text('Sen'), findsOneWidget);
      expect(find.text('Sel'), findsOneWidget);
      expect(find.text('Rab'), findsOneWidget);
      expect(find.text('Kam'), findsOneWidget);
      expect(find.text('Jum'), findsOneWidget);
      expect(find.text('Sab'), findsOneWidget);
      expect(find.text('Min'), findsOneWidget);

      // 6. Penjualan per Menu Section
      expect(find.text('Penjualan per Menu'), findsOneWidget);
      expect(find.text('Mie Tarempa Basah'), findsWidgets);
    });

    testWidgets('Tapping period tab switches period and updates data dynamically',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: SalesReportView(),
        ),
      );
      await tester.pumpAndSettle();

      // Tap 'Hari Ini' tab
      await tester.tap(find.text('Hari Ini'));
      await tester.pumpAndSettle();

      expect(find.text('Tren Penjualan (Hari Ini)'), findsOneWidget);
      expect(find.text('Puncak: 12.00 - 13.00 (28 Porsi)'), findsOneWidget);

      // Tap 'Bulan Ini' tab
      await tester.tap(find.text('Bulan Ini'));
      await tester.pumpAndSettle();

      expect(find.text('Tren Penjualan (Bulan Ini)'), findsOneWidget);
      expect(find.text('Rp 78 Jt'), findsOneWidget);
      expect(find.text('1940 Porsi'), findsOneWidget);
    });

    testWidgets('Bottom navigation correctly reports navigation callback',
        (tester) async {
      int? tappedIndex;

      await tester.pumpWidget(
        MaterialApp(
          home: SalesReportView(
            onNavigateTab: (index) {
              tappedIndex = index;
            },
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Tap Dashboard icon on bottom nav
      await tester.tap(find.text('Dashboard'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 0);

      // Tap Stok icon on bottom nav
      await tester.tap(find.text('Stok'));
      await tester.pumpAndSettle();
      expect(tappedIndex, 1);
    });
  });
}
