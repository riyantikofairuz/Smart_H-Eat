import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/main.dart';
import 'package:smart_heat/services/auth_service.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';
import 'package:smart_heat/widgets/operator_header.dart';
import 'package:smart_heat/widgets/smart_heat_logo.dart';

void main() {
  testWidgets('LoginScreen displays all UI elements and validates input', (WidgetTester tester) async {
    // Provide a standard mobile viewport size (e.g. 400x850)
    tester.view.physicalSize = const Size(400, 850);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // Build the app using MockAuthService for clean unit testing
    await tester.pumpWidget(SmartHeatApp(authService: MockAuthService()));
    await tester.pumpAndSettle();

    // Verify Header Elements
    expect(find.descendant(of: find.byType(OperatorHeader), matching: find.text('Smart H-EAT')), findsOneWidget);
    expect(find.text('OPERATOR MODE'), findsOneWidget);

    // Verify Smart H-EAT Logo Widget & Asset Image
    expect(find.byType(SmartHeatLogo), findsOneWidget);
    final imageFinder = find.descendant(of: find.byType(SmartHeatLogo), matching: find.byType(Image));
    expect(imageFinder, findsOneWidget);
    final Image imageWidget = tester.widget<Image>(imageFinder);
    expect((imageWidget.image as AssetImage).assetName, 'assets/images/smart_heat_logo.jpg');

    // Verify Card Titles & Subtitle
    expect(find.text('SELAMAT DATANG\nOPERATOR'), findsOneWidget);
    expect(
      find.text('Silakan autentikasi akun Anda untuk membuka sesi kerja dan monitoring sistem H-EAT.'),
      findsOneWidget,
    );

    // Verify Input Fields and Hint texts
    expect(find.text('Masukan username/email'), findsOneWidget);
    expect(find.text('Masukan Password'), findsOneWidget);
    expect(find.text('Masuk ke Sistem'), findsOneWidget);

    // Test Validation: tap button with empty inputs
    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pumpAndSettle();

    expect(find.text('Username / email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    // Enter valid credentials and tap login
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'kemas');
    await tester.enterText(textFields.last, 'password');
    await tester.pumpAndSettle();

    // Verify visibility toggle button exists and works
    final visibilityToggle = find.byKey(const Key('password_visibility_toggle'));
    expect(visibilityToggle, findsOneWidget);
    expect(find.byIcon(Icons.visibility_off_outlined), findsOneWidget);

    await tester.tap(visibilityToggle);
    await tester.pumpAndSettle();
    expect(find.byIcon(Icons.visibility_outlined), findsOneWidget);

    await tester.tap(find.text('Masuk ke Sistem'));
    // Advance timer for simulated mock auth call
    await tester.pump(const Duration(milliseconds: 900));
    await tester.pumpAndSettle();

    // Verify snackbar appears with welcome message
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Selamat datang, Pak Kemas!'), findsOneWidget);
  });

  test('Smart H-EAT logo asset bundle verification', () async {
    final byteDataJpg = await rootBundle.load('assets/images/smart_heat_logo.jpg');
    expect(byteDataJpg.lengthInBytes, greaterThan(1000));

    final byteDataPng = await rootBundle.load('assets/images/smart_heat_logo.png');
    expect(byteDataPng.lengthInBytes, greaterThan(1000));
  });

  testWidgets('SmartHeatLogo widget renders correctly with BoxFit.contain and default dimensions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: SmartHeatLogo(size: 78),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final imageFinder = find.byType(Image);
    expect(imageFinder, findsOneWidget);
    final Image imageWidget = tester.widget<Image>(imageFinder);
    expect(imageWidget.fit, BoxFit.contain);
    expect((imageWidget.image as AssetImage).assetName, 'assets/images/smart_heat_logo.jpg');
  });

  testWidgets('Operator Mode Dashboard verification matching Image 1', (WidgetTester tester) async {
    DummyOperatorService().login('kemas', 'password');

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Verify Image 1 & 2 elements on Dashboard
    expect(find.textContaining('Halo, Pak Kemas'), findsOneWidget);
    expect(find.text('Mesin Aktif'), findsOneWidget);
    expect(find.text('Sudirman Hub'), findsOneWidget);
    expect(find.text('PK'), findsNothing);
    expect(find.text('PERHATIAN'), findsOneWidget);
    expect(find.text('Mesin Perlu Restock Segera!'), findsOneWidget);
    expect(find.text('RINGKASAN OPERASIONAL'), findsOneWidget);
    expect(find.text('Live Update'), findsOneWidget);
    expect(find.text('Total Pendapatan Hari ini'), findsOneWidget);
    expect(find.text('Porsi Terjual'), findsOneWidget);
    expect(find.text('Suhu Vending'), findsOneWidget);
    expect(find.text('Suhu Optimal'), findsOneWidget);
    expect(find.byKey(const Key('dashboard_notification_button')), findsOneWidget);
    expect(find.byKey(const Key('dashboard_logout_button')), findsOneWidget);
  });

  testWidgets('Bottom navigation switches between Dashboard, Stok, and Laporan', (WidgetTester tester) async {
    DummyOperatorService().login('kemas', 'password');

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Tap "Stok" in bottom navigation
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // Verify Menu & Stok tab elements matching Image 3
    expect(find.text('Daftar Menu Tersedia'), findsOneWidget);
    expect(find.textContaining('Semua'), findsOneWidget);
    expect(find.byKey(const Key('stock_fab_add')), findsOneWidget);

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

  testWidgets('Speed dial pop-up opens Add Menu view and back works seamlessly', (WidgetTester tester) async {
    DummyOperatorService().login('kemas', 'password');

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Go to Stok tab
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // Tap Speed Dial FAB (+)
    await tester.tap(find.byKey(const Key('stock_fab_add')));
    await tester.pumpAndSettle();

    // Verify Speed dial pop-up options (Image 4)
    expect(find.byKey(const Key('speed_dial_add_menu')), findsOneWidget);
    expect(find.byKey(const Key('speed_dial_add_category')), findsOneWidget);

    // Tap "Tambah Menu"
    await tester.tap(find.byKey(const Key('speed_dial_add_menu')));
    await tester.pumpAndSettle();

    // Verify Add Menu view is rendered
    expect(find.text('Tambah Menu Baru'), findsAtLeastNWidgets(1));
    expect(find.text('Nama Makanan / Menu'), findsOneWidget);
    expect(find.text('Kategori Makanan'), findsOneWidget);
    expect(find.text('Pengaturan Slot Mesin'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Verify returned to Stok
    expect(find.text('Daftar Menu Tersedia'), findsOneWidget);
  });

  testWidgets('Speed dial pop-up opens Manage Categories view and back works seamlessly', (WidgetTester tester) async {
    DummyOperatorService().login('kemas', 'password');

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Go to Stok tab
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // Tap Speed Dial FAB (+)
    await tester.tap(find.byKey(const Key('stock_fab_add')));
    await tester.pumpAndSettle();

    // Tap "Tambah Kategori"
    await tester.tap(find.byKey(const Key('speed_dial_add_category')));
    await tester.pumpAndSettle();

    // Verify Category view is rendered
    expect(find.text('Tambah Kategori Baru'), findsAtLeastNWidgets(1));
    expect(find.text('Daftar Kategori Aktif'), findsOneWidget);

    // Tap back button
    await tester.tap(find.byIcon(Icons.arrow_back_ios_new_rounded));
    await tester.pumpAndSettle();

    // Verify returned to Stok
    expect(find.text('Daftar Menu Tersedia'), findsOneWidget);
  });

  testWidgets('Category chips filter menus dynamically in Menu & Stok view', (WidgetTester tester) async {
    DummyOperatorService().login('kemas', 'password');

    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    // Go to Stok tab
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // Verify menus exist
    expect(find.text('Mie Tarempa Kering'), findsOneWidget);

    // Tap category chip
    await tester.tap(find.textContaining('Semua'));
    await tester.pumpAndSettle();
    expect(find.text('Mie Tarempa Kering'), findsOneWidget);
  });
}
