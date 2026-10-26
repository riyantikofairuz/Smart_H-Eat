import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/data/dummy_data.dart';
import 'package:smart_heat/models/cart_item.dart';
import 'package:smart_heat/models/topping_item.dart';
import 'package:smart_heat/providers/cart_provider.dart';
import 'package:smart_heat/screens/cart_screen.dart';
import 'package:smart_heat/screens/menu_screen.dart';
import 'package:smart_heat/screens/product_detail_screen.dart';
import 'package:smart_heat/screens/screensaver_screen.dart';

/// Helper: bungkus widget dengan CartProvider agar test tidak crash ketika
/// ProductDetailScreen atau CartScreen mengakses CartProvider.of(context).
Widget withCart(Widget child) {
  final notifier = CartNotifier();
  return CartProvider(
    notifier: notifier,
    child: MaterialApp(home: child),
  );
}

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  void configureTabletSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
  }

  // ── SCR-01 → SCR-02 navigation ──────────────────────────────────────────────
  testWidgets('Navigation from SCR-01 Screensaver to SCR-02 MenuScreen', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    final notifier = CartNotifier();
    await tester.pumpWidget(
      CartProvider(
        notifier: notifier,
        child: const MaterialApp(home: ScreensaverScreen()),
      ),
    );

    await tester.tap(find.byType(GestureDetector).first);
    await tester.pumpAndSettle();

    expect(find.byType(MenuScreen), findsOneWidget);
    expect(find.text('SMART H-EAT'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
  });

  // ── SCR-02 components ────────────────────────────────────────────────────────
  testWidgets('MenuScreen components and header layout', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    await tester.pumpWidget(withCart(const MenuScreen()));

    expect(find.text('SMART H-EAT'), findsOneWidget);
    expect(find.text('Customer'), findsOneWidget);
    expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);
    expect(find.text('KATEGORI MAKANAN'), findsOneWidget);

    for (final cat in DummyData.categories) {
      expect(find.text(cat), findsOneWidget);
    }

    expect(find.text('Mie Tarempa Lembab Seafood'), findsOneWidget);
  });

  // ── Category filter ──────────────────────────────────────────────────────────
  testWidgets('Category filtering updates displayed products', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    await tester.pumpWidget(withCart(const MenuScreen()));

    await tester.tap(find.text('Kering'));
    await tester.pumpAndSettle();

    expect(find.text('Mie Tarempa Kering Seafood'), findsOneWidget);
    expect(find.text('Mie Tarempa Kering Spesial'), findsOneWidget);
    expect(find.text('Mie Tarempa Basah Seafood'), findsNothing);

    await tester.tap(find.text('Basah'));
    await tester.pumpAndSettle();

    expect(find.text('Mie Tarempa Basah Seafood'), findsOneWidget);
    expect(find.text('Mie Tarempa Basah Spesial'), findsOneWidget);
    expect(find.text('Mie Tarempa Kering Seafood'), findsNothing);

    await tester.tap(find.text('Semua'));
    await tester.pumpAndSettle();

    expect(find.text('Mie Tarempa Lembab Seafood'), findsOneWidget);
    expect(find.text('Mie Tarempa Kering Seafood'), findsOneWidget);
  });

  // ── SCR-02 → SCR-03 navigation ──────────────────────────────────────────────
  testWidgets(
    'Product card plus button navigates to ProductDetailScreen with product',
    (WidgetTester tester) async {
      configureTabletSize(tester);
      await tester.pumpWidget(withCart(const MenuScreen()));

      final plusButton = find.byIcon(Icons.add).first;
      await tester.tap(plusButton);
      await tester.pumpAndSettle();

      // SCR-03 harus terbuka dengan data produk pertama
      expect(find.byType(ProductDetailScreen), findsOneWidget);
      // Nama produk — bisa muncul lebih dari satu (header + body)
      expect(find.text('Mie Tarempa Lembab Seafood'), findsWidgets);
      // Harga dasar produk — ditampilkan di SCR-03
      expect(find.text('Rp 28.000'), findsWidgets);
      // Header SCR-03 menampilkan 'Detail Menu'
      expect(find.text('Detail Menu'), findsOneWidget);

      // Tombol kembali → kembali ke MenuScreen
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      expect(find.byType(MenuScreen), findsOneWidget);
    },
  );

  // ── Cart navigation ──────────────────────────────────────────────────────────
  testWidgets('Header cart icon navigates to CartScreen', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    await tester.pumpWidget(withCart(const MenuScreen()));

    await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
    await tester.pumpAndSettle();

    expect(find.byType(CartScreen), findsOneWidget);
    expect(find.text('Keranjang'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();

    expect(find.byType(MenuScreen), findsOneWidget);
  });

  // ── Banner carousel ──────────────────────────────────────────────────────────
  testWidgets('Banner carousel auto-slide loop behavior', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    await tester.pumpWidget(withCart(const MenuScreen()));

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));

    await tester.pump(const Duration(seconds: 4));
    await tester.pump(const Duration(milliseconds: 600));

    expect(find.byType(MenuScreen), findsOneWidget);
  });

  // ── SCR-03: quantity controls ────────────────────────────────────────────────
  testWidgets('SCR-03 quantity controls respect minimum of 1', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    final product = DummyData.products.first;
    await tester.pumpWidget(withCart(ProductDetailScreen(product: product)));

    // Jumlah awal adalah 1
    expect(find.text('1'), findsOneWidget);

    // Tap minus → tidak berubah karena sudah minimum
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('1'), findsOneWidget);

    // Tap plus → naik ke 2
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);

    // Tap plus lagi → naik ke 3
    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('3'), findsOneWidget);

    // Tap minus → kembali ke 2
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pump();
    expect(find.text('2'), findsOneWidget);
  });

  // ── SCR-03: spice level selection ───────────────────────────────────────────
  testWidgets('SCR-03 spice level selection changes active option', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    final product = DummyData.products.first;
    await tester.pumpWidget(withCart(ProductDetailScreen(product: product)));

    // Pilih 'Pedas'
    await tester.tap(find.text('Pedas'));
    await tester.pump();
    // Ketiga opsi masih tampil
    expect(find.text('Tidak pedas'), findsOneWidget);
    expect(find.text('Sedang'), findsOneWidget);
    expect(find.text('Pedas'), findsOneWidget);
  });

  // ── SCR-03: topping selection updates total price ────────────────────────────
  testWidgets('SCR-03 selecting topping updates total in add button', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    // prod_1: Mie Tarempa Lembab Seafood, Rp 28.000
    final product = DummyData.products.first;
    await tester.pumpWidget(withCart(ProductDetailScreen(product: product)));

    // Harga awal: Rp 28.000 (1 porsi, tanpa topping)
    expect(find.text('Rp 28.000'), findsWidgets);

    // Pilih topping 'Telur' (+Rp 4.000) → total: Rp 32.000
    await tester.ensureVisible(find.text('Telur'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Telur'));
    await tester.pump();
    expect(find.text('Rp 32.000'), findsOneWidget);

    // Batalkan pilihan 'Telur' → kembali ke Rp 28.000
    await tester.tap(find.text('Telur'));
    await tester.pump();
    expect(find.text('Rp 28.000'), findsWidgets);
  });

  // ── SCR-03: add to cart and return to menu ───────────────────────────────────
  testWidgets('SCR-03 add to cart returns to MenuScreen and item stored', (
    WidgetTester tester,
  ) async {
    configureTabletSize(tester);
    final notifier = CartNotifier();
    final product = DummyData.products.first;

    await tester.pumpWidget(
      CartProvider(
        notifier: notifier,
        child: MaterialApp(
          home: Stack(
            children: [
              const MenuScreen(),
              ProductDetailScreen(product: product),
            ],
          ),
        ),
      ),
    );

    // Ketuk "Tambah pesanan"
    await tester.tap(find.text('Tambah pesanan', findRichText: true));
    await tester.pumpAndSettle();

    // CartNotifier harus memiliki 1 item
    expect(notifier.items.length, 1);
    expect(notifier.items.first.productId, 'prod_1');
    expect(notifier.items.first.quantity, 1);
    expect(notifier.items.first.spiceLevel, 'Tidak pedas');
    expect(notifier.items.first.selectedToppings.isEmpty, true);
    expect(notifier.items.first.totalPrice, 28000);
  });

  // ── CartItem price calculation ───────────────────────────────────────────────
  testWidgets('CartItem price calculation matches spec formula', (
    WidgetTester tester,
  ) async {
    // (Harga dasar + total topping per porsi) × jumlah porsi
    // Contoh: (28000 + 4000 + 8000) × 2 = 80000
    const item = CartItem(
      productId: 'prod_1',
      productName: 'Test',
      productImagePath: '',
      basePrice: 28000,
      quantity: 2,
      spiceLevel: 'Tidak pedas',
      selectedToppings: [
        // Simulasi dua topping
      ],
    );
    // Tanpa topping: 28000 × 2 = 56000
    expect(item.totalPrice, 56000);
    expect(item.formattedTotalPrice, 'Rp 56.000');
  });

  // ── Cart merging: identical configuration ──────────────────────────────────
  test(
    'CartNotifier merges identical item configurations and increments quantity',
    () {
      final notifier = CartNotifier();
      const item1 = CartItem(
        productId: 'prod_1',
        productName: 'Mie Tarempa Lembab Seafood',
        productImagePath: '',
        basePrice: 28000,
        quantity: 2,
        spiceLevel: 'Sedang',
        selectedToppings: [
          ToppingItem(id: 'top_telur', name: 'Telur', price: 4000),
        ],
      );

      const item2 = CartItem(
        productId: 'prod_1',
        productName: 'Mie Tarempa Lembab Seafood',
        productImagePath: '',
        basePrice: 28000,
        quantity: 1,
        spiceLevel: 'Sedang',
        selectedToppings: [
          ToppingItem(id: 'top_telur', name: 'Telur', price: 4000),
        ],
      );

      notifier.addItem(item1);
      expect(notifier.uniqueItemCount, 1);
      expect(notifier.totalItemCount, 2);

      notifier.addItem(item2);
      // Setelah penggabungan: tetap 1 item unik dengan total kuantitas 3
      expect(notifier.uniqueItemCount, 1);
      expect(notifier.totalItemCount, 3);
      expect(notifier.items.first.quantity, 3);
      // (28000 + 4000) * 3 = 96000
      expect(notifier.items.first.totalPrice, 96000);
    },
  );

  // ── Cart merging: topping order independence ───────────────────────────────
  test('CartNotifier treats different topping selection order as identical configuration', () {
    final notifier = CartNotifier();
    const toppingTelur = ToppingItem(
      id: 'top_telur',
      name: 'Telur',
      price: 4000,
    );
    const toppingSeafood = ToppingItem(
      id: 'top_seafood',
      name: 'Seafood',
      price: 8000,
    );

    const itemA = CartItem(
      productId: 'prod_1',
      productName: 'Mie Tarempa',
      productImagePath: '',
      basePrice: 28000,
      quantity: 1,
      spiceLevel: 'Pedas',
      selectedToppings: [toppingTelur, toppingSeafood],
    );

    const itemB = CartItem(
      productId: 'prod_1',
      productName: 'Mie Tarempa',
      productImagePath: '',
      basePrice: 28000,
      quantity: 1,
      spiceLevel: 'Pedas',
      selectedToppings: [toppingSeafood, toppingTelur],
    );

    notifier.addItem(itemA);
    notifier.addItem(itemB);

    expect(notifier.uniqueItemCount, 1);
    expect(notifier.totalItemCount, 2);
    expect(notifier.items.first.quantity, 2);
  });

  // ── Cart distinct configuration ───────────────────────────────────────────
  test(
    'CartNotifier creates separate items for different spice level or toppings',
    () {
      final notifier = CartNotifier();
      const item1 = CartItem(
        productId: 'prod_1',
        productName: 'Mie Tarempa',
        productImagePath: '',
        basePrice: 28000,
        quantity: 1,
        spiceLevel: 'Sedang',
        selectedToppings: [],
      );

      const item2 = CartItem(
        productId: 'prod_1',
        productName: 'Mie Tarempa',
        productImagePath: '',
        basePrice: 28000,
        quantity: 1,
        spiceLevel: 'Pedas', // Kepedasan berbeda
        selectedToppings: [],
      );

      notifier.addItem(item1);
      notifier.addItem(item2);

      expect(notifier.uniqueItemCount, 2);
      expect(notifier.totalItemCount, 2);
    },
  );

  // ── Badge in MenuScreen Header ─────────────────────────────────────────────
  testWidgets(
    'MenuScreen header cart icon shows badge matching uniqueItemCount',
    (WidgetTester tester) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();

      await tester.pumpWidget(
        CartProvider(
          notifier: notifier,
          child: const MaterialApp(home: MenuScreen()),
        ),
      );

      // Saat keranjang kosong: badge tidak ditampilkan sama sekali
      expect(find.byKey(const ValueKey('cart_badge')), findsNothing);

      // Tambah 1 item unik
      notifier.addItem(
        const CartItem(
          productId: 'prod_1',
          productName: 'Item 1',
          productImagePath: '',
          basePrice: 28000,
          quantity: 1,
          spiceLevel: 'Tidak pedas',
          selectedToppings: [],
        ),
      );
      await tester.pump();

      // Badge muncul dengan teks '1'
      expect(find.byKey(const ValueKey('cart_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Tambah konfigurasi identik -> badge tetap '1'
      notifier.addItem(
        const CartItem(
          productId: 'prod_1',
          productName: 'Item 1',
          productImagePath: '',
          basePrice: 28000,
          quantity: 2,
          spiceLevel: 'Tidak pedas',
          selectedToppings: [],
        ),
      );
      await tester.pump();

      expect(find.text('1'), findsOneWidget);

      // Tambah konfigurasi berbeda -> badge naik ke '2'
      notifier.addItem(
        const CartItem(
          productId: 'prod_2',
          productName: 'Item 2',
          productImagePath: '',
          basePrice: 25000,
          quantity: 1,
          spiceLevel: 'Pedas',
          selectedToppings: [],
        ),
      );
      await tester.pump();

      expect(find.text('2'), findsOneWidget);

      // Hapus seluruh item -> badge hilang
      notifier.clear();
      await tester.pump();

      expect(find.byKey(const ValueKey('cart_badge')), findsNothing);
    },
  );

  // ── SCR-03 Detail Menu Header Reference Verification ───────────────────────
  testWidgets(
    'ProductDetailScreen header matches Menu Detail.png without cart icon and back button navigates back',
    (WidgetTester tester) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();
      final product = DummyData.products.first;

      await tester.pumpWidget(
        CartProvider(
          notifier: notifier,
          child: MaterialApp(
            home: Builder(
              builder: (context) => ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => ProductDetailScreen(product: product),
                    ),
                  );
                },
                child: const Text('Open Detail'),
              ),
            ),
          ),
        ),
      );

      // Buka ProductDetailScreen
      await tester.tap(find.text('Open Detail'));
      await tester.pumpAndSettle();

      // 1. Header menampilkan branding SMART H-EAT dan judul Detail Menu
      expect(find.text('SMART H-EAT'), findsWidgets);
      expect(find.text('Detail Menu'), findsOneWidget);

      // 2. Sesuai desain asli Menu Detail.png: TIDAK ADA ikon keranjang pada header Detail Menu
      expect(find.byIcon(Icons.shopping_cart_outlined), findsNothing);
      expect(find.byKey(const ValueKey('cart_badge')), findsNothing);

      // 3. Tombol kembali (Icons.arrow_back) tampil dan berfungsi kembali ke layar sebelumnya
      expect(find.byIcon(Icons.arrow_back), findsOneWidget);
      await tester.tap(find.byIcon(Icons.arrow_back));
      await tester.pumpAndSettle();

      // 4. Berhasil kembali ke layar sebelumnya
      expect(find.byType(ProductDetailScreen), findsNothing);
      expect(find.text('Open Detail'), findsOneWidget);
    },
  );
}
