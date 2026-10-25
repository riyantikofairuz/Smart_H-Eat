import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/views/variations/manage_variations_view.dart';

void main() {
  group('ManageVariationsView (UC-F017 Tests)', () {
    testWidgets('Renders header, menu selector, and variation groups', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ManageVariationsView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Kelola Variasi Menu'), findsOneWidget);
      expect(find.text('Pilih Menu Makanan:'), findsOneWidget);
      expect(find.text('+ Tambah Grup'), findsOneWidget);
      expect(find.textContaining('Tingkat Kepedasan'), findsWidgets);
    });

    testWidgets('Validates invalid extra price input according to UC-F017', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: ManageVariationsView(),
        ),
      );
      await tester.pumpAndSettle();

      final addOptionButton = find.text('+ Tambah Opsi Pilihan').first;
      await tester.tap(addOptionButton);
      await tester.pumpAndSettle();

      // Enter option name and invalid negative price
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'Level Super');
      await tester.enterText(textFields.at(1), '-5000');

      await tester.tap(find.text('Simpan Opsi'));
      await tester.pumpAndSettle();

      // Expect SKPPL UC-F017 Skenario Alternatif error message
      expect(find.text('Nominal harga variasi tidak valid'), findsOneWidget);
    });
  });
}
