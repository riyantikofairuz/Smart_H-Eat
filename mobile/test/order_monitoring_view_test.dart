import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';
import 'package:smart_heat/views/orders/order_monitoring_view.dart';

void main() {
  group('OrderMonitoringView (UC-F015 Tests)', () {
    testWidgets('Renders header, active count, filters, and orders list', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderMonitoringView(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Pemantauan Pesanan'), findsOneWidget);
      expect(find.text('Simulasi Pesanan Kiosk'), findsOneWidget);
      expect(find.text('+ Pesanan'), findsOneWidget);

      // Verify filter chips
      expect(find.widgetWithText(FilterChip, 'Semua'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Diproses'), findsOneWidget);
      expect(find.widgetWithText(FilterChip, 'Siap Diambil'), findsOneWidget);

      // Verify initial orders from service
      expect(find.text('A-01'), findsOneWidget);
      expect(find.textContaining('Mie Tarempa Banjir'), findsWidgets);
    });

    testWidgets('Simulates new order and updates active list dynamically', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderMonitoringView(),
        ),
      );
      await tester.pumpAndSettle();

      final initialOrders = DummyOperatorService().orders.length;

      // Tap "+ Pesanan" simulation button
      await tester.tap(find.text('+ Pesanan'));
      await tester.pumpAndSettle();

      expect(DummyOperatorService().orders.length, equals(initialOrders + 1));
      expect(find.textContaining('Pesanan baru masuk'), findsOneWidget);
    });

    testWidgets('Can update order status from diproses to siap_diambil', (tester) async {
      tester.view.physicalSize = const Size(1080, 2400);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await tester.pumpWidget(
        const MaterialApp(
          home: OrderMonitoringView(),
        ),
      );
      await tester.pumpAndSettle();

      final actionButtons = find.widgetWithText(ElevatedButton, 'Siap Diambil');
      if (actionButtons.evaluate().isNotEmpty) {
        await tester.tap(actionButtons.first);
        await tester.pumpAndSettle();
        expect(find.textContaining('siap diambil di vending'), findsOneWidget);
      }
    });
  });
}
