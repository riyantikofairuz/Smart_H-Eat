import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';
import 'package:smart_heat/views/category/add_category_view.dart';

void main() {
  setUp(() {
    // Reset DummyOperatorService to standard categories
    final service = DummyOperatorService();
    service.saveCategories([
      service.categories[0].copyWith(categoryId: 1, name: 'Mie Tarempa Kering', order: 0),
      service.categories[1].copyWith(categoryId: 2, name: 'Mie Tarempa Basah', order: 1),
      service.categories[2].copyWith(categoryId: 3, name: 'Mie Tarempa Lembab', order: 2),
      service.categories[3].copyWith(categoryId: 4, name: 'Mie Tarempa Goreng', order: 3),
      service.categories[4].copyWith(categoryId: 5, name: 'Mie Tarempa Rebus', order: 4),
    ]);
  });

  Widget createTestWidget() {
    return const MaterialApp(
      home: AddCategoryView(),
    );
  }

  group('AddCategoryView (STEP 1 Tests)', () {
    testWidgets('Header renders branding and title', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('SMART H-EAT'), findsOneWidget);
      expect(find.text('OPERATOR MODE'), findsOneWidget);
      expect(find.text('Tambah Kategori Baru'), findsAtLeastNWidgets(1));
      expect(find.text('5 Kategori'), findsOneWidget);
    });

    testWidgets('Validates empty and duplicate category name', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Tap Tambah when empty
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
      await tester.pumpAndSettle();
      expect(find.text('Nama kategori tidak boleh kosong'), findsOneWidget);

      // Enter duplicate name 'Mie Tarempa Kering'
      await tester.enterText(find.byType(TextField).first, 'Mie Tarempa Kering');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
      await tester.pumpAndSettle();
      expect(find.text('Kategori "Mie Tarempa Kering" sudah terdaftar.'), findsOneWidget);
    });

    testWidgets('Adds new category and increments badge counter', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('5 Kategori'), findsOneWidget);

      await tester.enterText(find.byType(TextField).first, 'Minuman Hangat');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
      await tester.pumpAndSettle();

      expect(find.text('6 Kategori'), findsOneWidget);
      expect(find.text('Minuman Hangat'), findsOneWidget);
    });

    testWidgets('Prevents deletion of category with active menus', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // First category is 'Mie Tarempa Kering', which has active menus
      final deleteButtons = find.byIcon(Icons.delete_outline_rounded);
      await tester.tap(deleteButtons.first);
      await tester.pumpAndSettle();

      expect(find.textContaining('tidak dapat dihapus karena masih digunakan'), findsOneWidget);
    });

    testWidgets('Allows editing category name via dialog', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      final editButtons = find.byIcon(Icons.edit_outlined);
      await tester.tap(editButtons.first);
      await tester.pumpAndSettle();

      expect(find.text('Edit Kategori'), findsOneWidget);
      // Clear and enter new name
      await tester.enterText(find.descendant(of: find.byType(AlertDialog), matching: find.byType(TextField)), 'Mie Tarempa Jumbo');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
      await tester.pumpAndSettle();

      expect(find.text('Mie Tarempa Jumbo'), findsOneWidget);
    });

    testWidgets('Simpan Perubahan persists to DummyOperatorService', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).first, 'Pencuci Mulut');
      await tester.tap(find.widgetWithText(ElevatedButton, 'Tambah'));
      await tester.pumpAndSettle();

      final simpanButton = find.widgetWithText(ElevatedButton, 'Simpan Perubahan');
      await tester.ensureVisible(simpanButton);
      await tester.tap(simpanButton);
      await tester.pumpAndSettle();

      final service = DummyOperatorService();
      expect(service.categories.any((c) => c.name == 'Pencuci Mulut'), isTrue);
    });
  });
}
