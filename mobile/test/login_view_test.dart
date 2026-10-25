import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';
import 'package:smart_heat/views/auth/operator_login_view.dart';

void main() {
  group('OperatorLoginView (UC-F014 Tests)', () {
    testWidgets('Renders all elements matching SKPPL Gambar 6.6', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OperatorLoginView(onLoginSuccess: () {}),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('SMART H-EAT'), findsOneWidget);
      expect(find.text('OPERATOR MODE'), findsOneWidget);
      expect(find.text('SELAMAT DATANG'), findsOneWidget);
      expect(find.text('OPERATOR'), findsOneWidget);
      expect(find.text('Masuk ke Dashboard'), findsOneWidget);
      expect(find.byType(TextField), findsNWidgets(2));
    });

    testWidgets('Shows error on invalid credentials according to UC-F014', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: OperatorLoginView(onLoginSuccess: () {}),
        ),
      );
      await tester.pumpAndSettle();

      // Enter wrong password
      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'unknown_user');
      await tester.enterText(textFields.at(1), 'wrong_pass');
      await tester.tap(find.text('Masuk ke Dashboard'));
      await tester.pumpAndSettle();

      // Verify SKPPL Skenario Alternatif error message
      expect(find.textContaining('Kredensial tidak valid'), findsOneWidget);
    });

    testWidgets('Logs in successfully with valid credentials', (tester) async {
      bool loginSuccessCalled = false;
      await tester.pumpWidget(
        MaterialApp(
          home: OperatorLoginView(onLoginSuccess: () {
            loginSuccessCalled = true;
          }),
        ),
      );
      await tester.pumpAndSettle();

      final textFields = find.byType(TextField);
      await tester.enterText(textFields.at(0), 'kemas');
      await tester.enterText(textFields.at(1), 'password');
      await tester.tap(find.text('Masuk ke Dashboard'));
      await tester.pumpAndSettle();

      expect(loginSuccessCalled, isTrue);
      expect(DummyOperatorService().isLoggedIn, isTrue);
    });
  });
}
