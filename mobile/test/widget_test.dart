import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/main.dart';
import 'package:smart_heat/models/cart_item.dart';
import 'package:smart_heat/providers/cart_provider.dart';
import 'package:smart_heat/screens/screensaver_screen.dart';

void main() {
  testWidgets('Screensaver smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify that the slogan and CTA texts are present.
    // Slogan translated to Indonesian per SCR-01 polish spec.
    expect(find.text('CITA RASA AUTENTIK\nDI SETIAP SUAPAN.'), findsOneWidget);
    expect(find.text('tap everywhare to start'), findsOneWidget);
  });

  testWidgets(
    'MyApp maintains CartNotifier instance and cart state across rebuilds',
    (WidgetTester tester) async {
      // 1. Pump MyApp pertama kali
      await tester.pumpWidget(const MyApp());

      final initialContext = tester.element(find.byType(ScreensaverScreen));
      final initialNotifier = CartProvider.of(initialContext, listen: false);

      // 2. Tambahkan item ke keranjang
      initialNotifier.addItem(
        const CartItem(
          productId: 'prod_test',
          productName: 'Test Product',
          productImagePath: '',
          basePrice: 20000,
          quantity: 2,
          spiceLevel: 'Sedang',
          selectedToppings: [],
        ),
      );

      expect(initialNotifier.uniqueItemCount, 1);
      expect(initialNotifier.totalItemCount, 2);

      // 3. Trigger rebuild pada root widget MyApp
      await tester.pumpWidget(const MyApp());

      final rebuiltContext = tester.element(find.byType(ScreensaverScreen));
      final rebuiltNotifier = CartProvider.of(rebuiltContext, listen: false);

      // 4. Verifikasi bahwa instance adalah objek yang persis sama (tidak dibuat ulang)
      expect(identical(initialNotifier, rebuiltNotifier), isTrue);

      // 5. Verifikasi bahwa isi keranjang tidak hilang akibat rebuild
      expect(rebuiltNotifier.uniqueItemCount, 1);
      expect(rebuiltNotifier.totalItemCount, 2);
      expect(rebuiltNotifier.items.first.productName, 'Test Product');
    },
  );
}
