import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/main.dart';

void main() {
  testWidgets('Operator Mode smoke test & branding verification', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify branding & header elements on Dashboard
    expect(find.text('SMART H-EAT'), findsAtLeastNWidgets(1));
    expect(find.text('OPERATOR MODE'), findsAtLeastNWidgets(1));
    expect(find.text('RINGKASAN OPERASIONAL'), findsOneWidget);
    expect(find.text('Kapasitas Tray Mesin'), findsOneWidget);
  });

  testWidgets('Bottom navigation switches between Dashboard, Stok, and Laporan', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap "Stok" in bottom navigation
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // Verify Menu & Stok tab elements
    expect(find.text('Daftar Menu Tersedia'), findsOneWidget);
    expect(find.byType(TextField), findsOneWidget); // Search bar

    // Tap "Laporan" in bottom navigation
    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();

    // Verify Laporan tab elements
    expect(find.text('Laporan Penjualan'), findsOneWidget);
    expect(find.text('Hari Ini'), findsOneWidget);
    expect(find.text('Minggu Ini'), findsOneWidget);
    expect(find.text('Bulan Ini'), findsOneWidget);

    // Tap back to "Dashboard"
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.text('RINGKASAN OPERASIONAL'), findsOneWidget);
  });

  testWidgets('Navigation to Add Menu and back works seamlessly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap "Tambah Menu" quick action button from dashboard
    await tester.tap(find.text('Tambah Menu'));
    await tester.pumpAndSettle();

    // Verify Add Menu view is rendered
    expect(find.text('Tambah Menu Baru'), findsAtLeastNWidgets(1));
    expect(find.text('Nama Makanan / Menu'), findsOneWidget);
    expect(find.text('Kategori Makanan'), findsOneWidget);
    expect(find.text('Pengaturan Slot Mesin'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Verify returned to Dashboard
    expect(find.text('RINGKASAN OPERASIONAL'), findsOneWidget);
  });

  testWidgets('Navigation to Manage Categories and back works seamlessly', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap "Kelola Kategori" quick action button from dashboard
    await tester.tap(find.text('Kelola Kategori'));
    await tester.pumpAndSettle();

    // Verify Category view is rendered
    expect(find.text('Tambah Kategori Baru'), findsAtLeastNWidgets(1));
    expect(find.text('Daftar Kategori Aktif'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Verify returned to Dashboard
    expect(find.text('RINGKASAN OPERASIONAL'), findsOneWidget);
  });

  testWidgets('Search bar filters menus dynamically in Menu & Stok view', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Go to Stok tab
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // Enter search text "kering"
    await tester.enterText(find.byType(TextField), 'kering');
    await tester.pumpAndSettle();

    // Should find Mie Tarempa Kering
    expect(find.text('Mie Tarempa Kering'), findsOneWidget);

    // Clear search
    await tester.tap(find.byIcon(Icons.clear_rounded));
    await tester.pumpAndSettle();
    expect(find.text('Mie Tarempa Kering'), findsOneWidget);
  });
}
