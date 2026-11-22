import 'package:flutter_test/flutter_test.dart';
import 'package:smart_heat/models/menu_model.dart';
import 'package:smart_heat/models/sales_report_model.dart';
import 'package:smart_heat/services/dummy_operator_service.dart';

void main() {
  group('DummyOperatorService Tests', () {
    late DummyOperatorService service;

    setUp(() {
      service = DummyOperatorService();
    });

    test('Initial menus and categories are populated', () {
      expect(service.menus.isNotEmpty, isTrue);
      expect(service.categories.isNotEmpty, isTrue);
      expect(service.totalCapacity, greaterThan(0));
      expect(service.totalStock, greaterThan(0));
      expect(service.lowStockMenus, isNotNull);
    });

    test('addMenu inserts a new menu item', () {
      final initialCount = service.menus.length;
      service.addMenu(
        MenuModel(
          menuId: 0,
          name: 'Ramen Pedas Spesial',
          categoryId: 1,
          price: 32000,
          stock: 5,
          slotCapacity: 10,
          description: 'Mie kuah pedas khas Jepang',
        ),
      );

      expect(service.menus.length, equals(initialCount + 1));
      final added = service.menus.firstWhere((m) => m.name == 'Ramen Pedas Spesial');
      expect(added.price, equals(32000));
      expect(added.stock, equals(5));
      expect(added.slotCapacity, equals(10));
      expect(added.description, equals('Mie kuah pedas khas Jepang'));
    });

    test('restockMenu updates stock correctly up to slotCapacity', () {
      final menu = service.menus.first;
      final originalStock = menu.stock;
      final capacity = menu.slotCapacity;

      // Add 2
      service.restockMenu(menu.menuId, 2);
      expect(service.getMenuById(menu.menuId)!.stock, equals((originalStock + 2).clamp(0, capacity)));

      // Fill beyond capacity clamps to capacity
      service.restockMenu(menu.menuId, 999);
      expect(service.getMenuById(menu.menuId)!.stock, equals(capacity));
    });

    test('updateMenu edits menu attributes', () {
      final menu = service.menus.first;
      service.updateMenu(
        menu.copyWith(
          name: 'Updated Menu Name',
          price: 28000,
          stock: 7,
          slotCapacity: 10,
          description: 'Updated Description',
          isActive: false,
        ),
      );

      final updated = service.getMenuById(menu.menuId)!;
      expect(updated.name, equals('Updated Menu Name'));
      expect(updated.price, equals(28000));
      expect(updated.stock, equals(7));
      expect(updated.slotCapacity, equals(10));
      expect(updated.isActive, isFalse);
    });

    test('deleteMenu removes the menu item', () {
      final menu = service.menus.first;
      final targetId = menu.menuId;
      final countBefore = service.menus.length;

      service.deleteMenu(targetId);
      expect(service.menus.length, equals(countBefore - 1));
      expect(service.menus.any((m) => m.menuId == targetId), isFalse);
    });

    test('Category operations: add, update, delete, saveCategories', () {
      final initialCatCount = service.categories.length;

      service.addCategory('Minuman Segar');
      expect(service.categories.length, equals(initialCatCount + 1));
      final added = service.categories.firstWhere((c) => c.name == 'Minuman Segar');

      service.updateCategory(added.categoryId, 'Minuman Dingin');
      expect(service.categories.firstWhere((c) => c.categoryId == added.categoryId).name, equals('Minuman Dingin'));

      service.deleteCategory(added.categoryId);
      expect(service.categories.any((c) => c.categoryId == added.categoryId), isFalse);
    });

    test('getSalesReport returns valid data for all periods', () {
      for (final period in [SalesPeriod.daily, SalesPeriod.weekly, SalesPeriod.monthly]) {
        final report = service.getSalesReport(period);
        expect(report.period, equals(period));
        expect(report.totalPortions, greaterThanOrEqualTo(0));
        expect(report.totalRevenueDisplay, isNotEmpty);
        expect(report.peakSummary, isNotEmpty);
        expect(report.dailyTrends.isNotEmpty, isTrue);
      }
    });
  });
}
