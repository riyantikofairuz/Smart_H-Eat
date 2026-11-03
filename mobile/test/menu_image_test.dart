import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/core/constants/menu_image_helper.dart';
import 'package:smart_heat/models/menu_model.dart';
import 'package:smart_heat/screens/stock/stock_screen.dart';
import 'package:smart_heat/services/dummy_data_service.dart';

void main() {
  setUp(() async {
    DummyDataService().resetToDefault();
    await MenuImageHelper.init();
  });

  group('MenuImageHelper Tests', () {
    test('Maps standard default menus to their exact asset paths', () {
      expect(
        MenuImageHelper.getDefaultAssetPathForName('Nasi Cumi Hitam'),
        'assets/images/menu/Nasi Cumi Hitam.jpg',
      );
      expect(
        MenuImageHelper.getDefaultAssetPathForName('Mie Tarempa Lembab Seafood'),
        'assets/images/menu/Mie Tarempa Lembab.jpg',
      );
      expect(
        MenuImageHelper.getDefaultAssetPathForName('Mie Tarempa Banjir'),
        'assets/images/menu/Mie Tarempa Banjir.jpg',
      );
      expect(
        MenuImageHelper.getDefaultAssetPathForName('Nasi Rendang Sapi Hangat'),
        'assets/images/menu/Nasi Rendang Sapi Hangat.jpg',
      );
    });

    test('Candidate paths include exact TitleCase, slug, keyword variations, and extensions', () {
      const menu = MenuModel(
        id: 9,
        categoryId: 3,
        categoryName: 'Mie & Pasta',
        name: 'Mie Tarempa Lembab Seafood',
        price: 25000,
        stock: 6,
      );
      final candidates = MenuImageHelper.getCandidateAssetPaths(menu);
      expect(candidates, contains('assets/images/menu/Mie Tarempa Lembab.jpg'));
      expect(candidates, contains('assets/images/menu/Mie Tarempa Lembab Seafood.jpg'));
      expect(candidates, contains('assets/images/menu/mie_tarempa_lembab_seafood.jpg'));
    });

    test('resolveExistingAssetPath returns bundled path when asset exists, and null when missing', () {
      final dummy = DummyDataService();

      // Menu yang memiliki file foto di bundle
      final nasiCumi = dummy.menus.firstWhere((m) => m.name == 'Nasi Cumi Hitam');
      expect(
        MenuImageHelper.resolveExistingAssetPath(nasiCumi),
        'assets/images/menu/Nasi Cumi Hitam.jpg',
      );

      final mieLembab = dummy.menus.firstWhere((m) => m.name == 'Mie Tarempa Lembab Seafood');
      expect(
        MenuImageHelper.resolveExistingAssetPath(mieLembab),
        'assets/images/menu/Mie Tarempa Lembab.jpg',
      );

      final mieBanjir = dummy.menus.firstWhere((m) => m.name == 'Mie Tarempa Banjir');
      expect(
        MenuImageHelper.resolveExistingAssetPath(mieBanjir),
        'assets/images/menu/Mie Tarempa Banjir.jpg',
      );

      final nasiRendang = dummy.menus.firstWhere((m) => m.name == 'Nasi Rendang Sapi Hangat');
      expect(
        MenuImageHelper.resolveExistingAssetPath(nasiRendang),
        'assets/images/menu/Nasi Rendang Sapi Hangat.jpg',
      );

      final sotoAyam = dummy.menus.firstWhere((m) => m.name == 'Soto Ayam Lamongan Hangat');
      expect(
        MenuImageHelper.resolveExistingAssetPath(sotoAyam),
        'assets/images/menu/Soto Ayam Lamongan Hangat.jpg',
      );

      final supAyam = dummy.menus.firstWhere((m) => m.name == 'Sup Ayam Jamur Panas');
      expect(
        MenuImageHelper.resolveExistingAssetPath(supAyam),
        'assets/images/menu/Sup Ayam Jamur Panas.jpg',
      );

      final ayamBakar = dummy.menus.firstWhere((m) => m.name == 'Nasi Ayam Bakar Madu');
      expect(
        MenuImageHelper.resolveExistingAssetPath(ayamBakar),
        'assets/images/menu/Nasi Ayam Bakar Madu.jpg',
      );

      final bento = dummy.menus.firstWhere((m) => m.name == 'Bento Nasi Ayam Teriyaki');
      expect(
        MenuImageHelper.resolveExistingAssetPath(bento),
        'assets/images/menu/Bento Nasi Ayam Teriyaki.jpg',
      );

      // Menu yang belum memiliki file foto di bundle -> harus null agar langsung menampilkan placeholder
      const menuTanpaFoto = MenuModel(
        id: 99,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Menu Tanpa Foto',
        price: 10000,
        stock: 5,
      );
      expect(MenuImageHelper.resolveExistingAssetPath(menuTanpaFoto), isNull);
    });

    test('Slugify helper formats names into clean asset file names', () {
      expect(MenuImageHelper.slugify('Ayam Geprek Sambal Matah'), 'ayam_geprek_sambal_matah');
      expect(MenuImageHelper.slugify('Mie Goreng Spesial (Pedas)'), 'mie_goreng_spesial_pedas');
    });

    test('Category icon resolver returns appropriate food icons', () {
      expect(MenuImageHelper.getCategoryIcon('Nasi'), Icons.rice_bowl_rounded);
      expect(MenuImageHelper.getCategoryIcon('Sup & Kuah'), Icons.soup_kitchen_rounded);
      expect(MenuImageHelper.getCategoryIcon('Mie & Pasta'), Icons.ramen_dining_rounded);
      expect(MenuImageHelper.getCategoryIcon('Lainnya'), Icons.restaurant_rounded);
    });
  });

  group('StockScreen Menu Thumbnail & Placeholder UI Tests', () {
    testWidgets('StockScreen renders menu cards with verified images and placeholders without crash', (tester) async {
      tester.view.physicalSize = const Size(420, 900);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() => tester.view.resetPhysicalSize());

      await tester.pumpWidget(
        const MaterialApp(
          home: StockScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Verify that StockScreen renders
      expect(find.text('Daftar Menu Tersedia'), findsOneWidget);

      // Verify that food cards are rendered
      expect(find.text('Nasi Cumi Hitam'), findsOneWidget);
      expect(find.text('Nasi Ayam Bakar Madu'), findsOneWidget);

      // Verify Nasi Cumi Hitam image widget exists
      final nasiCumiImageFinder = find.byWidgetPredicate((widget) {
        if (widget is Image && widget.image is AssetImage) {
          final assetImage = widget.image as AssetImage;
          return assetImage.assetName == 'assets/images/menu/Nasi Cumi Hitam.jpg';
        }
        return false;
      });
      expect(nasiCumiImageFinder, findsOneWidget);

      // Verify Nasi Rendang Sapi Hangat image widget exists
      final rendangImageFinder = find.byWidgetPredicate((widget) {
        if (widget is Image && widget.image is AssetImage) {
          final assetImage = widget.image as AssetImage;
          return assetImage.assetName == 'assets/images/menu/Nasi Rendang Sapi Hangat.jpg';
        }
        return false;
      });
      expect(rendangImageFinder, findsOneWidget);
    });
  });
}
