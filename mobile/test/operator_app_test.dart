import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/main.dart';
import 'package:smart_heat/screens/auth/login_screen.dart';
import 'package:smart_heat/screens/dashboard/dashboard_screen.dart';
import 'package:smart_heat/screens/main_navigation_screen.dart';
import 'package:smart_heat/screens/reports/reports_placeholder_screen.dart';
import 'package:smart_heat/screens/stock/stock_screen.dart';
import 'package:smart_heat/services/dummy_data_service.dart';
import 'package:smart_heat/widgets/operator_header.dart';

void main() {
  setUp(() {
    DummyDataService().resetToDefault();
  });

  testWidgets('Simulated Login Flow: Validation -> Direct Dashboard -> Tab Navigation & Back Button',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    // 1. Build App starting at Login
    await tester.pumpWidget(const SmartHeatApp());
    await tester.pumpAndSettle();

    expect(find.byType(OperatorHeader), findsOneWidget);
    expect(find.text('SELAMAT DATANG\nOPERATOR'), findsOneWidget);

    // 2. Test empty input validation
    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pumpAndSettle();

    expect(find.text('Username / email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);

    // 3. Enter credentials and tap Login
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'kemas');
    await tester.enterText(textFields.last, 'operator123');
    await tester.pumpAndSettle();

    // Tap Login
    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 4. Verify Dashboard Screen is directly active with Screenshot 2 components
    expect(find.byType(MainNavigationScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Greeting card
    expect(find.text('Halo, Pak Kemas'), findsOneWidget);

    // Alert Card
    expect(find.text('PERHATIAN'), findsOneWidget);
    expect(find.text('Mesin Perlu Restock\nSegera!'), findsOneWidget);

    // Operational summary title and 3 metric cards
    expect(find.text('RINGKASAN OPERASIONAL'), findsOneWidget);
    expect(find.text('Total Pendapatan Hari ini'), findsOneWidget);
    expect(find.text('Rp 4,25 Jt'), findsOneWidget);
    expect(find.text('Porsi Terjual'), findsOneWidget);
    expect(find.text('6 Porsi'), findsOneWidget);
    expect(find.text('Suhu Vending'), findsOneWidget);
    expect(find.text('60°C'), findsOneWidget);
    expect(find.text('Suhu Optimal'), findsOneWidget);

    // 5. Test Navigation: Tap Alert Card -> Navigates to Stock Tab
    await tester.tap(find.text('Mesin Perlu Restock\nSegera!'));
    await tester.pumpAndSettle();

    expect(find.byType(StockScreen), findsOneWidget);

    // 6. Test Navigation: Tap "Laporan" on Bottom Navigation Bar
    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();

    expect(find.byType(ReportsPlaceholderScreen), findsOneWidget);
    expect(find.text('Laporan Penjualan'), findsOneWidget);

    // 7. Switch back to Dashboard via Bottom Nav
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Halo, Pak Kemas'), findsOneWidget);

    // 8. Test Logout Action & Dialog
    await tester.tap(find.byIcon(Icons.logout_rounded));
    await tester.pumpAndSettle();

    expect(find.text('Konfirmasi Keluar'), findsOneWidget);

    // Confirm logout
    await tester.tap(find.widgetWithText(ElevatedButton, 'Keluar'));
    await tester.pumpAndSettle();

    // Verify back to LoginScreen
    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('SELAMAT DATANG\nOPERATOR'), findsOneWidget);
  });

  testWidgets('StockScreen: Chips, Cards, Edit, Delete Confirmation, and FAB Overlay',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SmartHeatApp());
    await tester.pumpAndSettle();

    // Fast login
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'kemas');
    await tester.enterText(textFields.last, 'operator123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Go to Stok tab
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    expect(find.byType(StockScreen), findsOneWidget);
    expect(find.text('Daftar Menu Tersedia'), findsOneWidget);

    // Verify Initial Category Chips
    // Verify initial visible chips
    expect(find.text('Semua (12)'), findsOneWidget);
    expect(find.text('Nasi (6)'), findsOneWidget);

    // Drag from 'Semua (12)' leftwards to reveal remaining chips
    await tester.drag(find.text('Semua (12)'), const Offset(-250, 0));
    await tester.pumpAndSettle();
    expect(find.text('Mie & Pasta (4)'), findsOneWidget);
    expect(find.text('Sup & Kuah (2)'), findsOneWidget);

    // Filter by "Sup & Kuah (2)"
    await tester.tap(find.text('Sup & Kuah (2)'));
    await tester.pumpAndSettle();

    expect(find.text('Sup Ayam Jamur Panas'), findsOneWidget);
    expect(find.text('Soto Ayam Lamongan Hangat'), findsOneWidget);

    // Tap "Edit" on the first Sup item
    final editButtons = find.text('Edit');
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Menu'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);

    // Cancel edit
    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    // Tap "Hapus" on the first Sup item
    final deleteButtons = find.text('Hapus');
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Verify delete confirmation dialog
    expect(find.text('Hapus Menu?'), findsOneWidget);
    await tester.tap(find.widgetWithText(ElevatedButton, 'Hapus'));
    await tester.pumpAndSettle();

    // Verify count reduced
    expect(find.text('Sup & Kuah (1)'), findsOneWidget);

    // Wait for SnackBar to dismiss
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Test FAB (+) opens Speed Dial overlay
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    // Verify Speed Dial options are displayed and bottom sheet title is not displayed
    expect(find.text('Pilih Aksi Penambahan'), findsNothing);
    expect(find.text('Tambah Kategori'), findsOneWidget);
    expect(find.text('Tambah Menu'), findsOneWidget);
    expect(find.widgetWithIcon(FloatingActionButton, Icons.close_rounded), findsOneWidget);

    // 1. Test Tambah Kategori
    await tester.tap(find.text('Tambah Kategori'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kategori Baru'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Masukkan nama kategori baru'), 'Camilan');
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Verify SnackBar dismissed
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Switch filter back to "Semua" to view all items
    await tester.drag(find.text('Sup & Kuah (1)'), const Offset(350, 0));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Semua (11)'));
    await tester.pumpAndSettle();

    // 2. Test Tambah Menu
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Tambah Menu'));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Menu Baru'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextField, 'Contoh: Nasi Rendang Hangat'), 'Roti Bakar Coklat');
    await tester.enterText(find.widgetWithText(TextField, '20000'), '15000');
    await tester.enterText(find.widgetWithText(TextField, '10'), '8');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan Menu'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Roti Bakar Coklat'), findsOneWidget);

    // Wait for SnackBar
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // 3. Test Edit Menu (Simpan Perubahan)
    final editButtonsAfterAdd = find.text('Edit');
    await tester.tap(editButtonsAfterAdd.first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Menu'), findsOneWidget);
    final editTextFields = find.byType(TextField);
    await tester.enterText(editTextFields.first, 'Roti Bakar Coklat Spesial');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Simpan Perubahan'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Roti Bakar Coklat Spesial'), findsOneWidget);
  });

  testWidgets('StockScreen Interactive Flow: Cancel Delete, Cancel FAB, Empty State, and Tab Switching',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SmartHeatApp());
    await tester.pumpAndSettle();

    // Fast login
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'kemas');
    await tester.enterText(textFields.last, 'operator123');
    await tester.pumpAndSettle();

    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // 1. Pindah ke Tab Stok
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();
    expect(find.byType(StockScreen), findsOneWidget);

    // 2. Uji Buka dan Batalkan Dialog Hapus
    final deleteButtons = find.text('Hapus');
    await tester.tap(deleteButtons.first);
    await tester.pumpAndSettle();

    // Verifikasi dialog muncul
    expect(find.text('Hapus Menu?'), findsOneWidget);
    expect(find.text('Batal'), findsOneWidget);

    // Tekan Batal
    await tester.tap(find.text('Batal'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Dialog tertutup dan menu tetap utuh (12 items)
    expect(find.text('Hapus Menu?'), findsNothing);
    expect(find.text('Semua (12)'), findsOneWidget);

    // 3. Uji Buka dan Tutup Speed Dial (FAB toggle dan Barrier dismissal)
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add_rounded));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Menu Speed Dial terbuka, FAB berubah menjadi close icon
    expect(find.text('Pilih Aksi Penambahan'), findsNothing);
    expect(find.text('Tambah Menu'), findsOneWidget);
    expect(find.text('Tambah Kategori'), findsOneWidget);
    expect(find.widgetWithIcon(FloatingActionButton, Icons.close_rounded), findsOneWidget);

    // Tekan FAB lagi untuk menutup Speed Dial
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.close_rounded));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Speed Dial tertutup dan FAB kembali menjadi add icon
    expect(find.text('Tambah Menu'), findsNothing);
    expect(find.text('Tambah Kategori'), findsNothing);
    expect(find.widgetWithIcon(FloatingActionButton, Icons.add_rounded), findsOneWidget);

    // Buka kembali dan uji tutup melalui sentuhan barrier luar
    await tester.tap(find.widgetWithIcon(FloatingActionButton, Icons.add_rounded));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('speed_dial_barrier')), findsOneWidget);
    await tester.tap(find.byKey(const Key('speed_dial_barrier')));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Tambah Menu'), findsNothing);
    expect(find.text('Tambah Kategori'), findsNothing);
    expect(find.widgetWithIcon(FloatingActionButton, Icons.add_rounded), findsOneWidget);

    // 4. Uji Buka dan Batalkan Edit Menu
    final editButtons = find.text('Edit');
    await tester.tap(editButtons.first);
    await tester.pumpAndSettle();

    expect(find.text('Edit Menu'), findsOneWidget);
    await tester.enterText(find.byType(TextField).first, 'Nama Berubah Tidak Disimpan');
    await tester.pumpAndSettle();

    // Tekan Batal pada form Edit
    await tester.tap(find.text('Batal'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    expect(find.text('Edit Menu'), findsNothing);
    expect(find.text('Nama Berubah Tidak Disimpan'), findsNothing);

    // 5. Uji Kategori Kosong & Empty State
    // Tambah Kategori baru yang belum memiliki menu
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Tambah Kategori'));
    await tester.pumpAndSettle();

    await tester.enterText(find.widgetWithText(TextField, 'Masukkan nama kategori baru'), 'Camilan Hangat');
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(ElevatedButton, 'Simpan'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Tunggu SnackBar hilang
    await tester.pump(const Duration(seconds: 4));
    await tester.pumpAndSettle();

    // Gulir daftar chip horizontal hingga chip kategori baru ter-render
    await tester.scrollUntilVisible(
      find.text('Camilan Hangat (0)'),
      50.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();

    expect(find.text('Camilan Hangat (0)'), findsOneWidget);
    await tester.tap(find.text('Camilan Hangat (0)'));
    await tester.pumpAndSettle();

    // Verifikasi Empty State muncul
    expect(find.text('Tidak Ada Menu Tersedia'), findsOneWidget);
    expect(find.text('Lihat Semua Menu'), findsOneWidget);

    // Tekan tombol "Lihat Semua Menu" pada empty state
    await tester.tap(find.text('Lihat Semua Menu'));
    await tester.pumpAndSettle();

    // Daftar kembali menampilkan semua menu
    expect(find.text('Tidak Ada Menu Tersedia'), findsNothing);
    expect(find.text('Nasi Cumi Hitam'), findsOneWidget);

    // 6. Uji Navigasi Antar Tab (Dashboard -> Stok -> Laporan -> Dashboard)
    // Pindah ke Laporan
    await tester.tap(find.text('Laporan'));
    await tester.pumpAndSettle();
    expect(find.byType(ReportsPlaceholderScreen), findsOneWidget);

    // Pindah ke Dashboard
    await tester.tap(find.text('Dashboard'));
    await tester.pumpAndSettle();
    expect(find.byType(DashboardScreen), findsOneWidget);

    // Pindah kembali ke Stok
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();
    expect(find.byType(StockScreen), findsOneWidget);
  });

  testWidgets('SKPPL Hot Food Scope: Mie Tarempa Lembab Seafood, Mie Tarempa Banjir, Nasi Cumi Hitam',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SmartHeatApp());
    await tester.pumpAndSettle();

    // Login
    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'kemas');
    await tester.enterText(textFields.last, 'operator123');
    await tester.pumpAndSettle();
    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();

    // Go to Stok
    await tester.tap(find.text('Stok'));
    await tester.pumpAndSettle();

    // 1. Verifikasi Menu Nasi Cumi Hitam tampil dengan karakteristik Kering
    expect(find.text('Nasi Cumi Hitam'), findsOneWidget);
    expect(find.text('Kering'), findsWidgets);

    // 2. Filter ke Mie & Pasta
    await tester.scrollUntilVisible(
      find.text('Mie & Pasta (4)'),
      50.0,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('Mie & Pasta (4)'));
    await tester.pumpAndSettle();

    // 3. Verifikasi Mie Tarempa Lembab Seafood dan Mie Tarempa Banjir
    expect(find.text('Mie Tarempa Lembab Seafood'), findsOneWidget);
    expect(find.text('Lembab'), findsWidgets);
    expect(find.text('Mie Tarempa Banjir'), findsOneWidget);
    expect(find.text('Banjir'), findsWidgets);

    // 4. Verifikasi tidak ada menu minuman
    expect(find.text('Kopi Panas'), findsNothing);
    expect(find.text('Teh Manis'), findsNothing);
    expect(find.text('Jus Jeruk'), findsNothing);
    expect(find.text('Air Mineral'), findsNothing);
  });

  testWidgets('Login with custom username reflects on Dashboard greeting card',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(420, 900);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() => tester.view.resetPhysicalSize());

    await tester.pumpWidget(const SmartHeatApp());
    await tester.pumpAndSettle();

    final textFields = find.byType(TextField);
    await tester.enterText(textFields.first, 'arda');
    await tester.enterText(textFields.last, 'password123');
    await tester.tap(find.text('Masuk ke Sistem'));
    await tester.pumpAndSettle();

    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.text('Halo, Arda'), findsOneWidget);
  });
}

