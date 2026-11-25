import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';
import 'package:smart_heat/views/menu/edit_menu_view.dart';

void main() {
  Widget createTestWidget({int? menuId}) {
    return MaterialApp(
      home: EditMenuView(menuId: menuId),
    );
  }

  group('EditMenuView (STEP 3 Tests)', () {
    testWidgets('Renders all cards and design elements matching Image 3', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(menuId: 1));
      await tester.pumpAndSettle();

      // Header branding & title
      expect(find.text('SMART H-EAT'), findsOneWidget);
      expect(find.text('OPERATOR MODE'), findsOneWidget);
      expect(find.text('Edit Menu'), findsOneWidget);

      // Card 1: Foto Makanan
      expect(find.text('Foto Makanan'), findsOneWidget);
      expect(find.textContaining('Foto'), findsAtLeastNWidgets(1));

      // Card 2: Form Input Utama (pre-filled with Rendang Daging Sapi)
      expect(find.text('Nama Makanan / Menu'), findsOneWidget);
      expect(find.text('Kategori Makanan'), findsOneWidget);
      expect(find.text('Tingkat Kepedasan'), findsOneWidget);

      // Pre-filled name verification in TextField controller
      final textField = tester.widget<TextField>(find.byType(TextField).first);
      expect(textField.controller?.text, equals('Mie Tarempa Kering'));

      // Card 3: Pengaturan Slot Mesin
      expect(find.text('Pengaturan Slot Mesin'), findsOneWidget);
      expect(find.text('Konfigurasi kapasitas tray mesin'), findsOneWidget);
      expect(find.text('Tambah Stok'), findsOneWidget);

      // Button Simpan Menu
      expect(find.text('Simpan Menu'), findsOneWidget);
    });

    testWidgets('Validates empty menu name on save', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(menuId: 1));
      await tester.pumpAndSettle();

      // Clear the name field
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, '');

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Menu');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.text('Nama makanan / menu tidak boleh kosong!'), findsOneWidget);
    });

    testWidgets('Prevents duplicate menu names with other menus', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(menuId: 2)); // Editing menu 2 (Mie Tarempa Basah)
      await tester.pumpAndSettle();

      // Enter name of menu 1 (Mie Tarempa Kering)
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, 'Mie Tarempa Kering');

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Menu');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      expect(find.text('Menu "Mie Tarempa Kering" sudah digunakan oleh menu lain!'), findsOneWidget);
    });

    testWidgets('Successfully updates menu data in DummyOperatorService', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(menuId: 1));
      await tester.pumpAndSettle();

      const updatedName = 'Rendang Sapi Spesial Padang';
      final nameField = find.byType(TextField).first;
      await tester.enterText(nameField, updatedName);

      // Select 'Pedas' spiciness after scrolling into view
      final pedasChip = find.text('Pedas');
      await tester.ensureVisible(pedasChip);
      await tester.tap(pedasChip);
      await tester.pumpAndSettle();

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Menu');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      final service = DummyOperatorService();
      final updatedMenu = service.getMenuById(1);
      expect(updatedMenu, isNotNull);
      expect(updatedMenu!.name, equals(updatedName));
      expect(updatedMenu.spiciness, equals('Pedas'));
    });
  });
}
