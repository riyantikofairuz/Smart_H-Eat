import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';

void main() {
  group('Smart H-EAT Mie Tarempa & Stock 10 Rules', () {
    late DummyOperatorService service;

    setUp(() {
      service = DummyOperatorService();
    });

    test('Has exactly 5 Mie Tarempa categories', () {
      final categoryNames = service.categories.map((c) => c.name).toList();
      expect(categoryNames, [
        'Mie Tarempa Kering',
        'Mie Tarempa Basah',
        'Mie Tarempa Lembab',
        'Mie Tarempa Goreng',
        'Mie Tarempa Rebus',
      ]);
    });

    test('Initial stock and slot capacity for every menu is 10 portions', () {
      expect(service.menus.length, 5);
      for (final menu in service.menus) {
        expect(menu.stock, 10, reason: '${menu.name} must have initial stock of 10');
        expect(menu.slotCapacity, 10, reason: '${menu.name} must have slot capacity of 10');
        expect(menu.imageUrl, isNotEmpty, reason: '${menu.name} must have an image');
      }
    });

    test('Stocks are managed separately and orders decrement stock', () {
      final initialStock1 = service.getMenuById(1)!.stock;
      final initialStock2 = service.getMenuById(2)!.stock;

      expect(initialStock1, 10);
      expect(initialStock2, 10);

      // Order 3 portions of menu 1
      final success = service.placeOrder(menuId: 1, qty: 3);
      expect(success, isTrue);

      // Menu 1 stock decremented to 7, Menu 2 untouched at 10
      expect(service.getMenuById(1)!.stock, 7);
      expect(service.getMenuById(2)!.stock, 10);
    });

    test('Stock cannot be decremented below 0 and orders blocked when 0', () {
      // Order remaining 7 of menu 1
      final success1 = service.placeOrder(menuId: 1, qty: 7);
      expect(success1, isTrue);
      expect(service.getMenuById(1)!.stock, 0);

      // Attempting to order from menu with 0 stock should fail
      final success2 = service.placeOrder(menuId: 1, qty: 1);
      expect(success2, isFalse);
      expect(service.getMenuById(1)!.stock, 0);
    });

    test('Restock cannot exceed 10 portions', () {
      // Menu 1 currently at 0, restock by 8
      service.restockMenu(1, 8);
      expect(service.getMenuById(1)!.stock, 8);

      // Restock by 5 should be capped at 10 (not 13)
      service.restockMenu(1, 5);
      expect(service.getMenuById(1)!.stock, 10);
    });

    test('updateMenu clamps stock strictly between 0 and 10', () {
      final menu = service.getMenuById(2)!;

      // Try setting stock to 25
      service.updateMenu(menu.copyWith(stock: 25));
      expect(service.getMenuById(2)!.stock, 10);

      // Try setting stock to negative
      service.updateMenu(menu.copyWith(stock: -5));
      expect(service.getMenuById(2)!.stock, 0);
    });
  });
}
