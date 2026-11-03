import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';
import 'package:smart_heat/views/menu/add_menu_view.dart';

void main() {
  Widget createTestWidget() {
    return const MaterialApp(
      home: AddMenuView(),
    );
  }

  group('AddMenuView (STEP 2 Tests)', () {
    testWidgets('Renders all cards and design elements matching Image 2', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Header branding & title
      expect(find.text('SMART H-EAT'), findsOneWidget);
      expect(find.text('OPERATOR MODE'), findsOneWidget);
      expect(find.text('Tambah Menu Baru'), findsAtLeastNWidgets(1));

      // Card 1: Foto Makanan
      expect(find.text('Foto Makanan'), findsOneWidget);
      expect(find.text('Unggah foto menu'), findsOneWidget);
      expect(find.text('Format JPG, PNG (Maks. 2MB)'), findsOneWidget);

      // Card 2: Form Input Utama
      expect(find.text('Nama Makanan / Menu'), findsOneWidget);
      expect(find.text('Kategori Makanan'), findsOneWidget);
      expect(find.text('Tingkat Kepedasan'), findsOneWidget);
      expect(find.text('Tidak Pedas'), findsOneWidget);
      expect(find.text('Sedang'), findsOneWidget);
      expect(find.text('Pedas'), findsOneWidget);

      // Card 3: Pengaturan Slot Mesin
      expect(find.text('Pengaturan Slot Mesin'), findsOneWidget);
      expect(find.text('Konfigurasi kapasitas tray mesin'), findsOneWidget);
      expect(find.text('Tambah Stok'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);

      // Button Simpan
      expect(find.text('Simpan & Tambahkan Menu'), findsOneWidget);
    });

    testWidgets('Stepper increments and decrements stock count', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final stepperText = find.text('10');
      await tester.ensureVisible(stepperText);
      expect(stepperText, findsOneWidget);

      final stepperRemoveFinder = find.descendant(
        of: find.byType(Row),
        matching: find.byIcon(Icons.remove),
      );
      await tester.ensureVisible(stepperRemoveFinder.first);
      await tester.tap(stepperRemoveFinder.first);
      await tester.pumpAndSettle();

      final stepperAddFinder = find.descendant(
        of: find.byType(Row),
        matching: find.byIcon(Icons.add),
      );
      await tester.ensureVisible(stepperAddFinder.first);
      await tester.tap(stepperAddFinder.first);
      await tester.pumpAndSettle();
    });

    testWidgets('Validates empty menu name on submission', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan & Tambahkan Menu');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.text('Nama makanan / menu harus diisi!'), findsOneWidget);
    });

    testWidgets('Prevents duplicate menu names', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Enter existing menu name (e.g. Mie Tarempa Kering)
      await tester.enterText(find.byType(TextField).first, 'Mie Tarempa Kering');

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan & Tambahkan Menu');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.text('Menu "Mie Tarempa Kering" sudah terdaftar di mesin!'), findsOneWidget);
    });

    testWidgets('Successfully adds a new menu item to DummyOperatorService', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      const uniqueMenuName = 'Gulai Ikan Patin Special';
      await tester.enterText(find.byType(TextField).first, uniqueMenuName);

      // Select 'Pedas' spiciness after scrolling into view
      final pedasChip = find.text('Pedas');
      await tester.ensureVisible(pedasChip);
      await tester.tap(pedasChip);
      await tester.pumpAndSettle();

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan & Tambahkan Menu');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      final service = DummyOperatorService();
      expect(service.menus.any((m) => m.name == uniqueMenuName), isTrue);
      final added = service.menus.firstWhere((m) => m.name == uniqueMenuName);
      expect(added.spiciness, equals('Pedas'));
    });
  });
}
