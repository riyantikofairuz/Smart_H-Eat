import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/models/cart_item.dart';
import 'package:smart_heat/models/topping_item.dart';
import 'package:smart_heat/providers/cart_provider.dart';
import 'package:smart_heat/screens/cart_screen.dart';
import 'package:smart_heat/screens/menu_screen.dart';
import 'package:smart_heat/screens/payment_screen.dart';

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

  Widget createCartWidget({required CartNotifier notifier, Widget? home}) {
    return CartProvider(
      notifier: notifier,
      child: MaterialApp(home: home ?? const CartScreen()),
    );
  }

  final sampleItem1 = const CartItem(
    productId: 'prod_1',
    productName: 'Mie Tarempa Lembab Seafood',
    productImagePath: 'assets/mie_tarempa_lembab_seafood.png',
    basePrice: 28000,
    quantity: 1,
    spiceLevel: 'Sedang',
    selectedToppings: [
      ToppingItem(id: 'top_telur', name: 'Telur', price: 4000),
    ],
  );

  final sampleItem2 = const CartItem(
    productId: 'prod_2',
    productName: 'Nasi Cumi Hitam',
    productImagePath: 'assets/mie_tarempa_kering_seafood.png',
    basePrice: 28000,
    quantity: 2,
    spiceLevel: 'Pedas',
    selectedToppings: [],
  );

  group('SCR-04 — Cart Page Specification Tests', () {
    // 3. Keranjang kosong saat pertama dibuka
    testWidgets(
      '3. Empty State on initial open: icon, Keranjang Kosong, description, Mulai Belanja, Total Rp 0, disabled button',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        // Header persisten
        expect(find.text('SMART H-EAT'), findsOneWidget);
        expect(find.text('Keranjang'), findsOneWidget);
        expect(find.byIcon(Icons.arrow_back), findsOneWidget);

        // Judul Menu Pesanan & Hapus Semua TIDAK boleh muncul
        expect(find.textContaining('Menu Pesanan'), findsNothing);
        expect(find.text('Hapus Semua'), findsNothing);

        // Tombol Tambah Menu sesuai Keranjang Kosong.png
        expect(
          find.byKey(const ValueKey('tambah_menu_button')),
          findsOneWidget,
        );
        expect(find.text('Tambah Menu'), findsOneWidget);
        expect(find.byIcon(Icons.add_circle_outline), findsOneWidget);

        // Total Akhir Rp 0
        expect(find.text('Total Akhir'), findsOneWidget);
        expect(find.text('Rp 0'), findsOneWidget);

        // Tombol Lanjut ke Pembayaran disabled (onPressed null)
        final checkoutButton = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('checkout_button')),
        );
        expect(checkoutButton.onPressed, isNull);
      },
    );

    // 4. Penambahan item dengan konfigurasi identik menggabungkan kuantitas
    test('4. Identical configuration increments quantity without creating new rows', () {
      final notifier = CartNotifier();
      notifier.addItem(sampleItem1);
      expect(notifier.uniqueItemCount, 1);
      expect(notifier.totalItemCount, 1);

      notifier.addItem(sampleItem1.copyWith(quantity: 2));
      expect(notifier.uniqueItemCount, 1);
      expect(notifier.totalItemCount, 3);
      expect(notifier.items.first.quantity, 3);
      // (28000 + 4000) * 3 = 96000
      expect(notifier.items.first.totalPrice, 96000);
    });

    // 5. Produk yang sama dengan kepedasan atau topping berbeda menjadi baris terpisah
    test(
      '5. Same product with different spice or toppings creates separate rows',
      () {
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1);

        // Kepedasan berbeda
        final differentSpice = sampleItem1.copyWith(spiceLevel: 'Pedas');
        notifier.addItem(differentSpice);
        expect(notifier.uniqueItemCount, 2);

        // Topping berbeda
        final differentTopping = sampleItem1.copyWith(selectedToppings: []);
        notifier.addItem(differentTopping);
        expect(notifier.uniqueItemCount, 3);
      },
    );

    // 6. Tombol [+] memperbarui kuantitas dan total
    testWidgets('6. Increment button [+] updates quantity and grand total', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();
      notifier.addItem(sampleItem1); // 1 porsi @ 32.000 = Rp 32.000

      await tester.pumpWidget(createCartWidget(notifier: notifier));
      await tester.pumpAndSettle();

      expect(find.text('1'), findsOneWidget);
      expect(find.text('Rp 32.000'), findsWidgets);

      // Ketuk [+]
      await tester.tap(find.byKey(const ValueKey('increment_button')));
      await tester.pumpAndSettle();

      expect(notifier.items.first.quantity, 2);
      expect(find.text('2'), findsOneWidget);
      // Subtotal & Total Akhir sekarang 64.000
      expect(find.text('Rp 64.000'), findsWidgets);
    });

    // 7. Tombol [-] saat kuantitas lebih dari satu mengurangi kuantitas langsung tanpa dialog
    testWidgets(
      '7. Decrement button [-] with quantity > 1 decreases quantity and total without dialog',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(
          sampleItem1.copyWith(quantity: 3),
        ); // 3 porsi = Rp 96.000

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('3'), findsOneWidget);
        expect(find.text('Rp 96.000'), findsWidgets);

        // Ketuk [-] saat kuantitas 3 -> 2
        await tester.tap(find.byKey(const ValueKey('decrement_button')));
        await tester.pumpAndSettle();

        // Tidak ada dialog konfirmasi
        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsNothing,
        );
        expect(find.text('Hapus menu dari keranjang?'), findsNothing);

        expect(notifier.items.first.quantity, 2);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Rp 64.000'), findsWidgets);

        // Ketuk [-] saat kuantitas 2 -> 1 langsung tanpa dialog
        await tester.tap(find.byKey(const ValueKey('decrement_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsNothing,
        );
        expect(notifier.items.first.quantity, 1);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Rp 32.000'), findsWidgets);
      },
    );

    // 8a. Tombol [-] saat kuantitas satu memunculkan dialog konfirmasi
    testWidgets(
      '8a. Decrement button [-] with quantity 1 displays confirmation dialog',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1); // qty 1

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);

        // Ketuk [-] pada kuantitas 1
        await tester.tap(find.byKey(const ValueKey('decrement_button')));
        await tester.pumpAndSettle();

        // Dialog konfirmasi harus muncul dengan teks dan tombol yang diharapkan
        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsOneWidget,
        );
        expect(find.text('Hapus menu dari keranjang?'), findsOneWidget);
        expect(
          find.text(
            'Menu ini akan dihapus dari keranjang. Apakah Anda yakin ingin melanjutkan?',
          ),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cancel_delete_item_button')),
          findsOneWidget,
        );
        expect(find.text('Batal'), findsOneWidget);
        expect(
          find.byKey(const ValueKey('confirm_delete_item_button')),
          findsOneWidget,
        );
        expect(find.text('Hapus Menu'), findsOneWidget);
      },
    );

    // 8b. Memilih Batal mempertahankan item dan total harga
    testWidgets(
      '8b. Choosing Batal in confirmation dialog retains item with quantity 1 and unchanged total',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1); // qty 1 = Rp 32.000

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('1'), findsOneWidget);
        expect(find.text('Rp 32.000'), findsWidgets);

        // Ketuk [-]
        await tester.tap(find.byKey(const ValueKey('decrement_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsOneWidget,
        );

        // Ketuk tombol Batal
        await tester.tap(
          find.byKey(const ValueKey('cancel_delete_item_button')),
        );
        await tester.pumpAndSettle();

        // Dialog tertutup, item dan total harga tetap utuh
        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsNothing,
        );
        expect(notifier.uniqueItemCount, 1);
        expect(notifier.items.first.quantity, 1);
        expect(notifier.items.first.totalPrice, 32000);
        expect(find.text('1'), findsOneWidget);
        expect(find.text('Rp 32.000'), findsWidgets);

        // Pembeli dapat melanjutkan mengubah kuantitas seperti biasa
        await tester.tap(find.byKey(const ValueKey('increment_button')));
        await tester.pumpAndSettle();
        expect(notifier.items.first.quantity, 2);
        expect(find.text('2'), findsOneWidget);
        expect(find.text('Rp 64.000'), findsWidgets);
      },
    );

    // 8c. Memilih Hapus Menu menghapus hanya baris menu yang dikonfirmasi
    testWidgets(
      '8c. Choosing Hapus Menu removes only the confirmed item and updates total',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1); // qty 1, Rp 32.000
        notifier.addItem(sampleItem2); // qty 2, Rp 56.000

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('Menu Pesanan (2)'), findsOneWidget);
        expect(find.text('Mie Tarempa Lembab Seafood'), findsOneWidget);
        expect(find.text('Nasi Cumi Hitam'), findsOneWidget);
        expect(find.text('Rp 88.000'), findsOneWidget);

        // Ketuk [-] pada item pertama (Mie Tarempa) yang kuantitasnya 1
        final firstDecrement = find
            .byKey(const ValueKey('decrement_button'))
            .first;
        await tester.tap(firstDecrement);
        await tester.pumpAndSettle();

        // Dialog konfirmasi muncul
        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsOneWidget,
        );

        // Ketuk tombol Hapus Menu
        await tester.tap(
          find.byKey(const ValueKey('confirm_delete_item_button')),
        );
        await tester.pumpAndSettle();

        // Dialog tertutup, hanya baris Mie Tarempa yang terhapus, Nasi Cumi Hitam tetap ada
        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsNothing,
        );
        expect(notifier.uniqueItemCount, 1);
        expect(find.text('Mie Tarempa Lembab Seafood'), findsNothing);
        expect(find.text('Nasi Cumi Hitam'), findsOneWidget);
        expect(find.text('Menu Pesanan (1)'), findsOneWidget);
        // Total pembayaran diperbarui menjadi Rp 56.000 (hanya Nasi Cumi Hitam)
        expect(find.text('Rp 56.000'), findsWidgets);
      },
    );

    // 9. Mengonfirmasi penghapusan item terakhir menampilkan Empty State tanpa navigasi otomatis
    testWidgets(
      '9. Confirming deletion of last item shows Empty State without navigating away',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1); // hanya 1 item, qty 1

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('Menu Pesanan (1)'), findsOneWidget);

        // Ketuk tombol [-]
        await tester.tap(find.byKey(const ValueKey('decrement_button')));
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('delete_item_confirmation_dialog')),
          findsOneWidget,
        );

        // Konfirmasi Hapus Menu
        await tester.tap(
          find.byKey(const ValueKey('confirm_delete_item_button')),
        );
        await tester.pumpAndSettle();

        // Tetap di CartScreen, beralih ke Empty State
        expect(find.byType(CartScreen), findsOneWidget);
        expect(notifier.uniqueItemCount, 0);
        expect(
          find.byKey(const ValueKey('tambah_menu_button')),
          findsOneWidget,
        );
        expect(find.text('Tambah Menu'), findsOneWidget);
        expect(find.text('Total Akhir'), findsOneWidget);
        expect(find.text('Rp 0'), findsOneWidget);
        expect(find.textContaining('Menu Pesanan'), findsNothing);

        // Tombol Lanjut ke Pembayaran tetap terlihat dan nonaktif
        final checkoutButton = tester.widget<ElevatedButton>(
          find.byKey(const ValueKey('checkout_button')),
        );
        expect(checkoutButton.onPressed, isNull);
      },
    );

    // 10. Hapus Semua mengosongkan keranjang tanpa dialog dan tetap berada di halaman Keranjang
    testWidgets(
      '10. Hapus Semua clears cart immediately without dialog and stays on CartScreen',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1);
        notifier.addItem(sampleItem2);

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('Menu Pesanan (2)'), findsOneWidget);
        expect(find.text('Hapus Semua'), findsOneWidget);

        // Ketuk Hapus Semua
        await tester.tap(find.byKey(const ValueKey('hapus_semua_button')));
        await tester.pumpAndSettle();

        // Tidak ada dialog konfirmasi yang muncul
        expect(find.byType(AlertDialog), findsNothing);

        // Keranjang kosong, tetap di CartScreen pada Empty State
        expect(notifier.uniqueItemCount, 0);
        expect(find.byType(CartScreen), findsOneWidget);
        expect(
          find.byKey(const ValueKey('tambah_menu_button')),
          findsOneWidget,
        );
        expect(find.text('Tambah Menu'), findsOneWidget);
        expect(find.text('Rp 0'), findsOneWidget);
      },
    );

    // 11. Menu Pesanan (X) menghitung jumlah baris unik dengan benar
    testWidgets(
      '11. Menu Pesanan (X) displays unique row count, not total servings',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1.copyWith(quantity: 5)); // 5 porsi baris 1
        notifier.addItem(sampleItem2.copyWith(quantity: 3)); // 3 porsi baris 2

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        // Total porsi = 8, tetapi jumlah baris konfigurasi = 2
        expect(find.text('Menu Pesanan (2)'), findsOneWidget);
      },
    );

    // 12. Badge keranjang tetap mengikuti aturan eksisting dan tersinkronisasi
    testWidgets('12. Cart badge matches unique count and stays in sync', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();

      await tester.pumpWidget(
        createCartWidget(notifier: notifier, home: const MenuScreen()),
      );
      await tester.pumpAndSettle();

      // Kosong: tidak ada badge
      expect(find.byKey(const ValueKey('cart_badge')), findsNothing);

      // Tambah item: badge muncul dengan '1'
      notifier.addItem(sampleItem1);
      await tester.pump();
      expect(find.byKey(const ValueKey('cart_badge')), findsOneWidget);
      expect(find.text('1'), findsOneWidget);

      // Hapus: badge hilang
      notifier.clear();
      await tester.pump();
      expect(find.byKey(const ValueKey('cart_badge')), findsNothing);
    });

    // 13. Tombol Tambah Menu kembali ke Menu Page
    testWidgets('13. Tambah Menu button returns to Menu Page', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();

      await tester.pumpWidget(
        createCartWidget(notifier: notifier, home: const MenuScreen()),
      );
      await tester.pumpAndSettle();

      // Buka CartScreen dari MenuScreen
      await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);

      // Ketuk Tambah Menu
      await tester.tap(find.byKey(const ValueKey('tambah_menu_button')));
      await tester.pumpAndSettle();

      // Kembali ke MenuScreen
      expect(find.byType(MenuScreen), findsOneWidget);
    });

    // 14. Checkout dengan keranjang terisi membuka popup konfirmasi di tengah layar
    testWidgets(
      '14. Checkout button opens order confirmation popup in Filled State',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1);

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        final checkoutFinder = find.byKey(const ValueKey('checkout_button'));
        final checkoutButton = tester.widget<ElevatedButton>(checkoutFinder);
        expect(checkoutButton.onPressed, isNotNull);

        // Ketuk tombol checkout -> membuka dialog konfirmasi
        await tester.tap(checkoutFinder);
        await tester.pumpAndSettle();

        expect(
          find.byKey(const ValueKey('order_confirmation_dialog')),
          findsOneWidget,
        );
        expect(find.text('Konfirmasi Pesanan'), findsOneWidget);
        expect(
          find.text(
            'Pastikan semua menu dan jumlah pesanan Anda sudah sesuai sebelum melanjutkan ke pembayaran.',
          ),
          findsOneWidget,
        );
        expect(find.textContaining('1 porsi (1 menu)'), findsOneWidget);
        expect(find.text('Rp 32.000'), findsAtLeastNWidgets(1));
        expect(
          find.byKey(const ValueKey('confirm_order_button')),
          findsOneWidget,
        );
        expect(
          find.byKey(const ValueKey('cancel_order_confirmation_button')),
          findsOneWidget,
        );

        // Konfirmasi "Ya, Lanjut ke Pembayaran" -> masuk ke SCR-05
        await tester.tap(find.byKey(const ValueKey('confirm_order_button')));
        await tester.pumpAndSettle();

        expect(find.byType(PaymentPage), findsOneWidget);
      },
    );

    // 14b. Memilih "Belum, Tambah Menu" menutup popup dan kembali ke Menu dengan keranjang utuh
    testWidgets(
      '14b. Selecting Belum, Tambah Menu closes popup, returns to Menu, and preserves cart',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1);

        await tester.pumpWidget(
          createCartWidget(notifier: notifier, home: const MenuScreen()),
        );
        await tester.pumpAndSettle();

        // Buka CartScreen dari MenuScreen
        await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
        await tester.pumpAndSettle();
        expect(find.byType(CartScreen), findsOneWidget);

        // Ketuk checkout
        await tester.tap(find.byKey(const ValueKey('checkout_button')));
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('order_confirmation_dialog')),
          findsOneWidget,
        );

        // Ketuk "Belum, Tambah Menu"
        await tester.tap(
          find.byKey(const ValueKey('cancel_order_confirmation_button')),
        );
        await tester.pumpAndSettle();

        // Kembali ke MenuScreen
        expect(find.byType(MenuScreen), findsOneWidget);
        expect(find.byType(CartScreen), findsNothing);

        // Keranjang tetap utuh
        expect(notifier.uniqueItemCount, 1);
        expect(notifier.totalItemCount, 1);
        expect(notifier.items.first.productId, sampleItem1.productId);
      },
    );

    // 15. Tombol pembayaran disabled pada Empty State dan tidak membuka popup konfirmasi
    testWidgets(
      '15. Checkout button is disabled in Empty State and does not open confirmation popup',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        final checkoutFinder = find.byKey(const ValueKey('checkout_button'));
        final checkoutButton = tester.widget<ElevatedButton>(checkoutFinder);
        expect(checkoutButton.onPressed, isNull);

        // Ketukan pada tombol disabled tidak memunculkan popup
        await tester.tap(checkoutFinder);
        await tester.pumpAndSettle();
        expect(
          find.byKey(const ValueKey('order_confirmation_dialog')),
          findsNothing,
        );
      },
    );

    // 16. Back Header dan Back sistem Android kembali ke Menu Page tanpa menghapus state
    testWidgets(
      '16. Back button returns to Menu Page without resetting cart state',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1);

        await tester.pumpWidget(
          createCartWidget(notifier: notifier, home: const MenuScreen()),
        );
        await tester.pumpAndSettle();

        // Masuk ke CartScreen
        await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
        await tester.pumpAndSettle();
        expect(find.byType(CartScreen), findsOneWidget);

        // Tekan tombol back
        await tester.tap(find.byIcon(Icons.arrow_back));
        await tester.pumpAndSettle();

        // Kembali ke MenuScreen dan item tetap ada di cart
        expect(find.byType(MenuScreen), findsOneWidget);
        expect(notifier.uniqueItemCount, 1);
        expect(notifier.items.first.productId, 'prod_1');
      },
    );

    // 17. Daftar panjang tetap dapat digulir sampai kartu terakhir terlihat
    testWidgets(
      '17. Long list can scroll independently and footer remains pinned',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();

        // Tambahkan 10 item berbeda
        for (int i = 1; i <= 10; i++) {
          notifier.addItem(
            CartItem(
              productId: 'prod_$i',
              productName: 'Produk Menu Panjang Nomor $i',
              productImagePath: 'assets/mie_tarempa_lembab_seafood.png',
              basePrice: 20000 + (i * 1000),
              quantity: 1,
              spiceLevel: 'Sedang',
              selectedToppings: const [],
            ),
          );
        }

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('Menu Pesanan (10)'), findsOneWidget);

        // Kartu pertama terlihat, kartu ke-10 belum terlihat
        expect(find.text('Produk Menu Panjang Nomor 1'), findsOneWidget);
        expect(find.text('Produk Menu Panjang Nomor 10'), findsNothing);

        // Gulir ke bawah
        await tester.drag(find.byType(ListView), const Offset(0, -600));
        await tester.pumpAndSettle();

        // Kartu ke-10 sekarang terlihat
        expect(find.text('Produk Menu Panjang Nomor 10'), findsOneWidget);

        // Footer panel Total Akhir & Pembayaran tetap terlihat dan utuh
        expect(find.text('Total Akhir'), findsOneWidget);
        expect(find.byKey(const ValueKey('checkout_button')), findsOneWidget);
      },
    );

    // Topping tidak muncul placeholder jika kosong
    testWidgets(
      'Does not display topping placeholder if item has no toppings',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem2); // tanpa topping

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('Nasi Cumi Hitam'), findsOneWidget);
        expect(find.text('Pedas'), findsOneWidget);
        expect(find.text('-'), findsNothing);
        expect(find.text('Tanpa topping'), findsNothing);
      },
    );

    // 18. Tombol tong sampah individual pada baris menu sudah tidak ditampilkan
    testWidgets(
      '18. Individual trash icon button is not displayed on cart item rows',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem1);
        notifier.addItem(sampleItem2);

        await tester.pumpWidget(createCartWidget(notifier: notifier));
        await tester.pumpAndSettle();

        expect(find.text('Menu Pesanan (2)'), findsOneWidget);

        // Pastikan tidak ada tombol atau ikon tong sampah individual pada baris menu
        expect(find.byIcon(Icons.delete_outline), findsNothing);
        expect(find.byIcon(Icons.delete), findsNothing);
        expect(find.byKey(const ValueKey('delete_item_prod_1')), findsNothing);
        expect(find.byKey(const ValueKey('delete_item_prod_2')), findsNothing);

        // Fitur Hapus Semua di header tetap ada dan berfungsi
        expect(
          find.byKey(const ValueKey('hapus_semua_button')),
          findsOneWidget,
        );
        expect(find.text('Hapus Semua'), findsOneWidget);
      },
    );
  });
}
