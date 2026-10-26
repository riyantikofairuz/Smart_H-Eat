import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/models/cart_item.dart';
import 'package:smart_heat/providers/cart_provider.dart';
import 'package:smart_heat/screens/cart_screen.dart';
import 'package:smart_heat/screens/menu_screen.dart';
import 'package:smart_heat/screens/payment_screen.dart';
import 'package:smart_heat/screens/screensaver_screen.dart';

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    PaymentPage.globalScenario = null;
  });

  void configureTabletSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(720, 1280);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
      PaymentPage.globalScenario = null;
    });
  }

  Widget createTestWidget({
    required CartNotifier notifier,
    Widget? home,
    Map<String, WidgetBuilder>? routes,
  }) {
    return CartProvider(
      notifier: notifier,
      child: MaterialApp(
        home: home ?? const PaymentPage(),
        routes: routes ?? const {},
      ),
    );
  }

  final sampleItem28k = const CartItem(
    productId: 'prod_1',
    productName: 'Mie Tarempa Lembab Seafood',
    productImagePath: 'assets/mie_tarempa_lembab_seafood.png',
    basePrice: 28000,
    quantity: 1,
    spiceLevel: 'Sedang',
    selectedToppings: [],
  );

  final sampleItem112k = const CartItem(
    productId: 'prod_2',
    productName: 'Paket Spesial Seafood',
    productImagePath: 'assets/mie_tarempa_kering_seafood.png',
    basePrice: 28000,
    quantity: 4, // 28.000 x 4 = 112.000
    spiceLevel: 'Pedas',
    selectedToppings: [],
  );

  group('SCR-05 — Payment Flow Specification Tests', () {
    // -------------------------------------------------------------------------
    // 1. Cart dapat membuka QR Payment
    // -------------------------------------------------------------------------
    testWidgets('1. Cart opens QR Payment page upon confirming checkout', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();
      notifier.addItem(sampleItem28k);

      await tester.pumpWidget(
        createTestWidget(notifier: notifier, home: const CartScreen()),
      );
      await tester.pumpAndSettle();

      expect(find.byType(CartScreen), findsOneWidget);
      expect(find.text('Rp 28.000'), findsAtLeastNWidgets(1));

      // Tekan tombol Lanjut ke Pembayaran pada CartScreen
      final checkoutFinder = find.byKey(const ValueKey('checkout_button'));
      await tester.tap(checkoutFinder);
      await tester.pumpAndSettle();

      // Konfirmasi pesanan pada dialog
      expect(
        find.byKey(const ValueKey('order_confirmation_dialog')),
        findsOneWidget,
      );
      await tester.tap(find.byKey(const ValueKey('confirm_order_button')));
      await tester.pumpAndSettle();

      // SCR-05A terbuka pada Pending / QR State
      expect(find.byType(PaymentPage), findsOneWidget);
      expect(find.byKey(const ValueKey('qr_code_container')), findsOneWidget);
      expect(find.byKey(const ValueKey('qr_scan_instruction')), findsOneWidget);
      expect(
        find.text('Pindai kode QR untuk melakukan pembayaran'),
        findsOneWidget,
      );
    });

    // -------------------------------------------------------------------------
    // 2. Nominal QR sama dengan total keranjang dan tidak memiliki awalan Rp
    // -------------------------------------------------------------------------
    testWidgets('2. QR nominal matches cart total and has no Rp prefix', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();
      notifier.addItem(sampleItem112k); // Total: 112.000

      await tester.pumpWidget(
        createTestWidget(notifier: notifier, home: const CartScreen()),
      );
      await tester.pumpAndSettle();

      // Checkout dari CartScreen
      await tester.tap(find.byKey(const ValueKey('checkout_button')));
      await tester.pumpAndSettle();
      await tester.tap(find.byKey(const ValueKey('confirm_order_button')));
      await tester.pumpAndSettle();

      expect(find.byType(PaymentPage), findsOneWidget);

      final bannerFinder = find.byKey(const ValueKey('nominal_header_banner'));
      expect(bannerFinder, findsOneWidget);

      // Format angka konsisten dengan titik pemisah tanpa awalan Rp
      expect(
        find.descendant(of: bannerFinder, matching: find.text('112.000')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: bannerFinder, matching: find.textContaining('Rp')),
        findsNothing,
      );
    });

    // -------------------------------------------------------------------------
    // 3. QR Payment tidak menampilkan back arrow
    // -------------------------------------------------------------------------
    testWidgets('3. QR Payment does not display back arrow or return buttons', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();
      notifier.addItem(sampleItem28k);

      await tester.pumpWidget(createTestWidget(notifier: notifier));
      await tester.pumpAndSettle();

      // Header hanya menampilkan teks statis SMART H-EAT dan Pembayaran
      final headerFinder = find.byKey(const ValueKey('payment_header_bar'));
      expect(headerFinder, findsOneWidget);
      expect(
        find.descendant(of: headerFinder, matching: find.text('SMART H-EAT')),
        findsOneWidget,
      );
      expect(
        find.descendant(of: headerFinder, matching: find.text('Pembayaran')),
        findsOneWidget,
      );

      // Tidak ada ikon atau tombol kembali di header maupun layar
      expect(
        find.descendant(of: headerFinder, matching: find.byType(IconButton)),
        findsNothing,
      );
      expect(find.byIcon(Icons.arrow_back), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios), findsNothing);
      expect(find.byIcon(Icons.arrow_back_ios_new_rounded), findsNothing);

      // PopScope mencegah back hardware gesture Android
      final popScopeFinder = find.byType(PopScope);
      expect(popScopeFinder, findsOneWidget);
      final popScope = tester.widget<PopScope>(popScopeFinder);
      expect(popScope.canPop, isFalse);
    });

    // -------------------------------------------------------------------------
    // 4. Mode default tetap berada di QR selama belum dibatalkan atau disentuh
    // -------------------------------------------------------------------------
    testWidgets(
      '4. Default mode stays on QR payment indefinitely until interacted',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.stayOnQr,
            ),
          ),
        );
        await tester.pumpAndSettle();

        final qrFinder = find.byKey(const ValueKey('qr_code_container'));
        expect(qrFinder, findsOneWidget);

        // Layar dibiarkan tanpa interaksi selama 5, 10, dan 30 detik
        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(seconds: 10));
        await tester.pump(const Duration(seconds: 30));

        // Tetap berada pada tampilan QR tanpa otomatis sukses/gagal
        expect(find.byKey(const ValueKey('qr_code_container')), findsOneWidget);
        expect(find.text('Pembayaran Gagal'), findsNothing);
        expect(find.text('Pembayaran Berhasil'), findsNothing);
        expect(find.byType(PaymentPage), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 5. Batalkan Pesanan menampilkan layar gagal selama 3 detik, kosongkan keranjang, navigasi ke Screensaver
    // -------------------------------------------------------------------------
    testWidgets(
      '5. Batalkan Pesanan opens Payment Failed, holds for 3s, clears cart, and navigates to Screensaver',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const MenuScreen()),
        );
        await tester.pumpAndSettle();

        // Buka CartScreen
        await tester.tap(find.byIcon(Icons.shopping_cart_outlined));
        await tester.pumpAndSettle();

        // Buka PaymentPage
        await tester.tap(find.byKey(const ValueKey('checkout_button')));
        await tester.pumpAndSettle();
        await tester.tap(find.byKey(const ValueKey('confirm_order_button')));
        await tester.pumpAndSettle();

        expect(find.byType(PaymentPage), findsOneWidget);
        expect(notifier.uniqueItemCount, 1);

        // Tekan tombol "Batalkan Pesanan"
        final cancelOrderButton = find.byKey(
          const ValueKey('cancel_order_button'),
        );
        expect(cancelOrderButton, findsOneWidget);
        expect(find.text('Batalkan Pesanan'), findsOneWidget);

        await tester.tap(cancelOrderButton);
        await tester.pump();

        // 1. Menampilkan layar Pembayaran Gagal, BUKAN MenuScreen
        expect(find.byType(MenuScreen), findsNothing);
        expect(find.byType(PaymentPage), findsOneWidget);
        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);
        expect(find.text('Pembayaran Gagal'), findsOneWidget);
        expect(
          find.text(
            'Pembayaran tidak berhasil dan sesi pesanan telah berakhir.',
          ),
          findsOneWidget,
        );

        // 2. Tombol pembatalan dan QR code disembunyikan
        expect(find.byKey(const ValueKey('cancel_order_button')), findsNothing);
        expect(find.byKey(const ValueKey('qr_code_container')), findsNothing);

        // 3. Keranjang TIDAK langsung dikosongkan sebelum 3 detik selesai
        expect(notifier.uniqueItemCount, 1);
        expect(notifier.items.isNotEmpty, isTrue);

        // 4. Setelah 2 detik: layar gagal masih bertahan
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(PaymentPage), findsOneWidget);
        expect(find.text('Pembayaran Gagal'), findsOneWidget);
        expect(notifier.items.isNotEmpty, isTrue);

        // 5. Tepat setelah 3 detik: keranjang dikosongkan dan navigasi ke Screensaver (SCR-01)
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(notifier.uniqueItemCount, 0);
        expect(notifier.totalItemCount, 0);
        expect(notifier.items.isEmpty, isTrue);

        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(find.byType(PaymentPage), findsNothing);
        expect(find.byType(MenuScreen), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // 5b. Mengetuk QR Code memicu layar Pembayaran Berhasil selama 3 detik, kosongkan keranjang, navigasi ke Screensaver
    // -------------------------------------------------------------------------
    testWidgets(
      '5b. Tapping QR Code triggers Payment Success, holds for 3s, clears cart, and navigates to Screensaver',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const PaymentPage()),
        );
        await tester.pumpAndSettle();

        expect(find.byType(PaymentPage), findsOneWidget);
        final qrFinder = find.byKey(const ValueKey('qr_code_container'));
        expect(qrFinder, findsOneWidget);

        // Ketuk QR Code
        await tester.tap(qrFinder);
        await tester.pump();

        // 1. Menampilkan layar Pembayaran Berhasil
        expect(
          find.byKey(const ValueKey('success_status_box')),
          findsOneWidget,
        );
        expect(find.text('Pembayaran Berhasil'), findsOneWidget);
        expect(
          find.text(
            'Pesanan Anda berhasil diproses dan akan segera disiapkan.',
          ),
          findsOneWidget,
        );

        // 2. Panel bawah dan QR disembunyikan
        expect(
          find.byKey(const ValueKey('payment_bottom_panel')),
          findsNothing,
        );
        expect(find.byKey(const ValueKey('qr_code_container')), findsNothing);

        // 3. Keranjang belum dikosongkan saat layar sukses baru muncul
        expect(notifier.items.isNotEmpty, isTrue);

        // 4. Setelah 2 detik: masih di layar sukses
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(PaymentPage), findsOneWidget);
        expect(find.text('Pembayaran Berhasil'), findsOneWidget);

        // 5. Tepat setelah 3 detik: keranjang dikosongkan dan navigasi ke Screensaver
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(notifier.uniqueItemCount, 0);
        expect(notifier.totalItemCount, 0);
        expect(notifier.items.isEmpty, isTrue);

        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(find.byType(PaymentPage), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // 6. Mode success membuka layar sukses
    // -------------------------------------------------------------------------
    testWidgets('6. Success simulation mode opens Payment Success screen', (
      WidgetTester tester,
    ) async {
      configureTabletSize(tester);
      final notifier = CartNotifier();
      notifier.addItem(sampleItem28k);

      await tester.pumpWidget(
        createTestWidget(
          notifier: notifier,
          home: const PaymentPage(
            scenario: PaymentSimulationScenario.simulateSuccess,
            simulationDelay: Duration(seconds: 1),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(PaymentPage), findsOneWidget);
      expect(find.byKey(const ValueKey('qr_code_container')), findsOneWidget);

      // Majukan timer simulasi 1 detik
      await tester.pump(const Duration(seconds: 1));
      await tester.pump();

      // Layar beralih ke Payment Success (SCR-05B)
      expect(find.byKey(const ValueKey('success_status_box')), findsOneWidget);
      expect(find.text('Pembayaran Berhasil'), findsOneWidget);
      expect(
        find.text('Pesanan Anda berhasil diproses dan akan segera disiapkan.'),
        findsOneWidget,
      );
      expect(find.byIcon(Icons.check_rounded), findsOneWidget);

      // Header dan tombol Batalkan Pesanan disembunyikan
      expect(find.byKey(const ValueKey('payment_header_bar')), findsNothing);
      expect(find.byKey(const ValueKey('payment_bottom_panel')), findsNothing);
      expect(find.byKey(const ValueKey('qr_code_container')), findsNothing);

      // Nominal banner tetap terkunci
      final bannerFinder = find.byKey(const ValueKey('nominal_header_banner'));
      expect(
        find.descendant(of: bannerFinder, matching: find.text('28.000')),
        findsOneWidget,
      );
    });

    // -------------------------------------------------------------------------
    // 7. Layar sukses bertahan 3 detik, kemudian keranjang dikosongkan dan navigasi ke Screensaver
    // -------------------------------------------------------------------------
    testWidgets(
      '7. Success screen holds for 3 seconds then clears cart and navigates to Screensaver',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateSuccess,
              simulationDelay: Duration(seconds: 1),
              resultDisplayDuration: Duration(seconds: 3),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Pemicu sukses setelah 1s
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(
          find.byKey(const ValueKey('success_status_box')),
          findsOneWidget,
        );

        // Keranjang masih utuh saat layar sukses baru muncul
        expect(notifier.items.isNotEmpty, isTrue);

        // Setelah 2 detik: masih di PaymentPage
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(PaymentPage), findsOneWidget);

        // Tepat setelah 3 detik berakhir (2s + 1s = 3s total)
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // 1. Keranjang belanja dikosongkan
        expect(notifier.uniqueItemCount, 0);
        expect(notifier.items.isEmpty, isTrue);

        // 2. Navigasi kembali ke Screensaver (SCR-01)
        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(find.byType(PaymentPage), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // 8. Mode failure menampilkan layar gagal hanya setelah timeout simulasi
    // -------------------------------------------------------------------------
    testWidgets(
      '8. Failure simulation mode displays Payment Failed only after QR timeout',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateFailure,
              qrTimeout: Duration(seconds: 2),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Sebelum timeout (1 detik): masih di tampilan QR
        await tester.pump(const Duration(seconds: 1));
        expect(find.byKey(const ValueKey('qr_code_container')), findsOneWidget);
        expect(find.byKey(const ValueKey('failed_status_box')), findsNothing);
        expect(find.text('Pembayaran Gagal'), findsNothing);

        // Timeout tercapai (1 detik lagi, total 2s)
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        // Layar gagal (SCR-05C) muncul
        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);
        expect(find.text('Pembayaran Gagal'), findsOneWidget);
        expect(
          find.text(
            'Pembayaran tidak berhasil dan sesi pesanan telah berakhir.',
          ),
          findsOneWidget,
        );
        expect(find.byIcon(Icons.close_rounded), findsOneWidget);

        // Header dan panel bawah disembunyikan
        expect(find.byKey(const ValueKey('payment_header_bar')), findsNothing);
        expect(
          find.byKey(const ValueKey('payment_bottom_panel')),
          findsNothing,
        );

        // Nominal banner tetap terkunci
        final bannerFinder = find.byKey(
          const ValueKey('nominal_header_banner'),
        );
        expect(
          find.descendant(of: bannerFinder, matching: find.text('28.000')),
          findsOneWidget,
        );
      },
    );

    // -------------------------------------------------------------------------
    // 9. Layar gagal bertahan 3 detik, kemudian keranjang dikosongkan dan navigasi ke Screensaver
    // -------------------------------------------------------------------------
    testWidgets(
      '9. Failed screen holds for 3 seconds then clears cart and navigates to Screensaver',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateFailure,
              qrTimeout: Duration(seconds: 1),
              resultDisplayDuration: Duration(seconds: 3),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Pemicu gagal setelah 1s timeout
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);

        // Keranjang masih utuh sebelum 3 detik habis
        expect(notifier.items.isNotEmpty, isTrue);

        // Setelah 2 detik: masih di layar gagal PaymentPage
        await tester.pump(const Duration(seconds: 2));
        expect(find.byType(PaymentPage), findsOneWidget);

        // Tepat setelah 3 detik berakhir (2s + 1s = 3s total)
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // 1. Keranjang belanja dikosongkan
        expect(notifier.uniqueItemCount, 0);
        expect(notifier.items.isEmpty, isTrue);

        // 2. Navigasi kembali ke Screensaver (SCR-01)
        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(find.byType(PaymentPage), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // 10. Pembatalan membatalkan timer simulasi yang tertunda dan mencegah navigasi terlambat
    // -------------------------------------------------------------------------
    testWidgets(
      '10. Cancellation cancels all pending simulation timers and prevents late navigation',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        // Jalankan skenario simulasi sukses dengan jeda 5 detik
        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateSuccess,
              simulationDelay: Duration(seconds: 5),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Di detik ke-1, batalkan pesanan
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.byKey(const ValueKey('cancel_order_button')));
        await tester.pump();

        // Pengguna melihat layar gagal, bukan MenuScreen
        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);
        expect(find.text('Pembayaran Gagal'), findsOneWidget);
        expect(find.byType(MenuScreen), findsNothing);

        // Bertahan selama 3 detik lalu menuju Screensaver
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(find.byType(PaymentPage), findsNothing);

        // Majukan waktu melampaui timer simulasi semula (+10 detik)
        await tester.pump(const Duration(seconds: 10));
        await tester.pump(const Duration(milliseconds: 600));

        // Tetap di Screensaver tanpa ada pemicu layar sukses atau navigasi terlambat
        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(find.text('Pembayaran Berhasil'), findsNothing);
      },
    );

    // -------------------------------------------------------------------------
    // 11. Tidak terjadi navigasi ganda atau hasil pembayaran yang dipicu lebih dari sekali
    // -------------------------------------------------------------------------
    testWidgets(
      '11. No double navigation or duplicate payment triggers occur',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateSuccess,
              simulationDelay: Duration(seconds: 1),
              resultDisplayDuration: Duration(seconds: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Tunggu hingga sukses dan transisi ke Screensaver
        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);

        // Majukan waktu tambahan untuk memastikan tidak ada timer kedua yang terpanggil
        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 12. Sesi pemesanan baru tidak mewarisi item transaksi sebelumnya
    // -------------------------------------------------------------------------
    testWidgets(
      '12. New order session does not inherit items from previous transactions',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem112k); // 4 porsi pesanan sebelumnya

        // Simulasi transaksi selesai (sukses)
        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateSuccess,
              simulationDelay: Duration(seconds: 1),
              resultDisplayDuration: Duration(seconds: 1),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.pump(const Duration(seconds: 1));
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // Pengguna berada di Screensaver dan keranjang sudah kosong
        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(notifier.items.isEmpty, isTrue);
        expect(notifier.uniqueItemCount, 0);
        expect(notifier.totalItemCount, 0);

        // Pelanggan baru memulai sesi pemesanan baru: Screensaver -> MenuScreen
        await tester.tap(find.byType(ScreensaverScreen));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.byType(MenuScreen), findsOneWidget);

        // Keranjang di MenuScreen tetap bersih tanpa badge
        expect(find.byKey(const ValueKey('cart_badge')), findsNothing);

        // Menambahkan menu baru dari nol
        notifier.addItem(sampleItem28k);
        expect(notifier.uniqueItemCount, 1);
        expect(notifier.items.first.productId, sampleItem28k.productId);
        expect(notifier.items.first.totalPrice, 28000);
      },
    );

    // -------------------------------------------------------------------------
    // 13. Menekan Batalkan Pesanan lalu mengetuk QR tidak memicu layar sukses atau alur ganda
    // -------------------------------------------------------------------------
    testWidgets(
      '13. Pressing Batalkan Pesanan then tapping QR does not trigger success or dual flow',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const PaymentPage()),
        );
        await tester.pumpAndSettle();

        // Tekan Batalkan Pesanan
        await tester.tap(find.byKey(const ValueKey('cancel_order_button')));
        await tester.pump();

        // Layar Pembayaran Gagal aktif
        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);
        expect(find.text('Pembayaran Gagal'), findsOneWidget);

        // QR Code Container sudah tidak ada di tree
        expect(find.byKey(const ValueKey('qr_code_container')), findsNothing);

        // Ketukan pada area tengah tidak mengubah status menjadi sukses
        await tester.tap(find.byKey(const ValueKey('failed_status_box')));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Pembayaran Berhasil'), findsNothing);
        expect(find.text('Pembayaran Gagal'), findsOneWidget);

        // Tunggu sisa waktu (2s) menuju Screensaver
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);

        // Tidak ada timer ganda
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 14. Mengetuk QR lalu menekan Batal tidak memicu layar gagal atau alur ganda
    // -------------------------------------------------------------------------
    testWidgets(
      '14. Tapping QR then pressing cancel does not trigger failure or dual flow',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const PaymentPage()),
        );
        await tester.pumpAndSettle();

        // Ketuk QR Code
        await tester.tap(find.byKey(const ValueKey('qr_code_container')));
        await tester.pump();

        // Layar Pembayaran Berhasil aktif
        expect(
          find.byKey(const ValueKey('success_status_box')),
          findsOneWidget,
        );
        expect(find.text('Pembayaran Berhasil'), findsOneWidget);

        // Tombol Batalkan Pesanan sudah tidak ada di tree
        expect(find.byKey(const ValueKey('cancel_order_button')), findsNothing);

        // Ketukan pada kartu tidak mengubah ke gagal
        await tester.tap(find.byKey(const ValueKey('success_status_box')));
        await tester.pump(const Duration(seconds: 1));

        expect(find.text('Pembayaran Gagal'), findsNothing);
        expect(find.text('Pembayaran Berhasil'), findsOneWidget);

        // Tunggu sisa waktu (2s) menuju Screensaver
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);

        // Tidak ada timer ganda
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 15. Ketukan berulang kali pada Batalkan Pesanan hanya memicu satu timer & navigasi
    // -------------------------------------------------------------------------
    testWidgets(
      '15. Repeated taps on Batalkan Pesanan trigger only a single timer and single navigation',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const PaymentPage()),
        );
        await tester.pumpAndSettle();

        final button = find.byKey(const ValueKey('cancel_order_button'));
        // Ketukan cepat 3 kali berturut-turut sebelum frame selesai
        await tester.tap(button);
        await tester.tap(button);
        await tester.tap(button);
        await tester.pump();

        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);

        // Bertahan tepat 3 detik
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(notifier.items.isEmpty, isTrue);

        // Pastikan tidak ada navigasi atau timer kedua
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 16. Ketukan berulang kali pada QR Code hanya memicu satu timer & navigasi
    // -------------------------------------------------------------------------
    testWidgets(
      '16. Repeated taps on QR Code trigger only a single timer and single navigation',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const PaymentPage()),
        );
        await tester.pumpAndSettle();

        final qrFinder = find.byKey(const ValueKey('qr_code_container'));
        // Ketukan cepat 3 kali berturut-turut
        await tester.tap(qrFinder);
        await tester.tap(qrFinder);
        await tester.tap(qrFinder);
        await tester.pump();

        expect(
          find.byKey(const ValueKey('success_status_box')),
          findsOneWidget,
        );

        // Bertahan tepat 3 detik
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(notifier.items.isEmpty, isTrue);

        // Pastikan tidak ada navigasi atau timer kedua
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 17. Timer timeout QR tidak dapat menimpa hasil simulasi sukses yang sudah dipicu
    // -------------------------------------------------------------------------
    testWidgets(
      '17. QR timeout timer cannot overwrite simulated success triggered by tapping QR code',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        // Skenario timeout kegagalan pada detik ke-2
        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateFailure,
              qrTimeout: Duration(seconds: 2),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Pada detik ke-1 (sebelum timeout 2s), pengguna mengetuk QR code
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.byKey(const ValueKey('qr_code_container')));
        await tester.pump();

        // Layar sukses muncul
        expect(
          find.byKey(const ValueKey('success_status_box')),
          findsOneWidget,
        );
        expect(find.text('Pembayaran Berhasil'), findsOneWidget);

        // Majukan waktu melampaui timeout 2s (misal 2 detik lagi, total 3s dari start)
        await tester.pump(const Duration(seconds: 2));

        // State tetap sukses, TIDAK ditimpa oleh layar gagal!
        expect(
          find.byKey(const ValueKey('success_status_box')),
          findsOneWidget,
        );
        expect(find.text('Pembayaran Berhasil'), findsOneWidget);
        expect(find.byKey(const ValueKey('failed_status_box')), findsNothing);
        expect(find.text('Pembayaran Gagal'), findsNothing);

        // Tepat di detik ke-3 dari pemicu sukses, berpindah ke Screensaver
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 18. Timer timeout QR tidak dapat menimpa alur pembatalan yang sudah dipicu
    // -------------------------------------------------------------------------
    testWidgets(
      '18. QR timeout timer cannot overwrite cancellation flow triggered by Batalkan Pesanan',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem28k);

        // Skenario timeout kegagalan pada detik ke-5
        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateFailure,
              qrTimeout: Duration(seconds: 5),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Pada detik ke-1, batalkan pesanan
        await tester.pump(const Duration(seconds: 1));
        await tester.tap(find.byKey(const ValueKey('cancel_order_button')));
        await tester.pump();

        expect(find.byKey(const ValueKey('failed_status_box')), findsOneWidget);

        // Bertahan 3 detik lalu menuju Screensaver
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        expect(find.byType(ScreensaverScreen), findsOneWidget);

        // Majukan waktu melampaui 5 detik timeout awal (+5 detik lagi)
        await tester.pump(const Duration(seconds: 5));
        await tester.pump(const Duration(milliseconds: 600));

        // Tetap di Screensaver tanpa error atau callback timeout susulan
        expect(find.byType(ScreensaverScreen), findsOneWidget);
      },
    );

    // -------------------------------------------------------------------------
    // 19. Sesi pemesanan baru setelah pembatalan bersih total dari transaksi sebelumnya
    // -------------------------------------------------------------------------
    testWidgets(
      '19. New order session after cancellation is completely clean and ready',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();
        notifier.addItem(sampleItem112k); // 4 porsi pesanan sebelumnya

        await tester.pumpWidget(
          createTestWidget(notifier: notifier, home: const PaymentPage()),
        );
        await tester.pumpAndSettle();

        // Batalkan pesanan
        await tester.tap(find.byKey(const ValueKey('cancel_order_button')));
        await tester.pump();

        // Tunggu 3 detik durasi layar gagal
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 600));

        // Keranjang bersih di Screensaver
        expect(find.byType(ScreensaverScreen), findsOneWidget);
        expect(notifier.items.isEmpty, isTrue);
        expect(notifier.uniqueItemCount, 0);
        expect(notifier.totalItemCount, 0);

        // Masuk ke MenuScreen dari Screensaver
        await tester.tap(find.byType(ScreensaverScreen));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pumpAndSettle();

        expect(find.byType(MenuScreen), findsOneWidget);
        expect(find.byKey(const ValueKey('cart_badge')), findsNothing);

        // Tambah menu baru
        notifier.addItem(sampleItem28k);
        expect(notifier.uniqueItemCount, 1);
        expect(notifier.totalItemCount, 1);
        expect(notifier.items.first.totalPrice, 28000);
      },
    );

    // -------------------------------------------------------------------------
    // Unit tests: formatNominal
    // -------------------------------------------------------------------------
    test(
      'formatNominal formats integers with dot separator and without Rp',
      () {
        expect(PaymentPage.formatNominal(0), '0');
        expect(PaymentPage.formatNominal(500), '500');
        expect(PaymentPage.formatNominal(4000), '4.000');
        expect(PaymentPage.formatNominal(28000), '28.000');
        expect(PaymentPage.formatNominal(50000), '50.000');
        expect(PaymentPage.formatNominal(112000), '112.000');
        expect(PaymentPage.formatNominal(1500000), '1.500.000');
      },
    );

    // -------------------------------------------------------------------------
    // Lifecycle: Disposing PaymentPage cancels all pending timers without error
    // -------------------------------------------------------------------------
    testWidgets(
      'Disposing PaymentPage cancels all pending timers without error',
      (WidgetTester tester) async {
        configureTabletSize(tester);
        final notifier = CartNotifier();

        await tester.pumpWidget(
          createTestWidget(
            notifier: notifier,
            home: const PaymentPage(
              scenario: PaymentSimulationScenario.simulateSuccess,
              simulationDelay: Duration(seconds: 10),
            ),
          ),
        );
        await tester.pump();

        // Ganti widget (dispose PaymentPage) saat timer masih berjalan
        await tester.pumpWidget(
          const MaterialApp(home: Scaffold(body: Text('Disposed'))),
        );
        await tester.pumpAndSettle();

        expect(find.text('Disposed'), findsOneWidget);
        expect(find.byType(PaymentPage), findsNothing);
      },
    );
  });
}
