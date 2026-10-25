import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/main.dart';
import 'package:smart_heat/services/auth_service.dart';
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
}
