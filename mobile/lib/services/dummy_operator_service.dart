import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';
import '../models/operator_model.dart';
import '../models/order_model.dart';
import '../models/restock_log_model.dart';
import '../models/sales_report_model.dart';
import '../models/variation_model.dart';

class DummyOperatorService extends ChangeNotifier {
  static final DummyOperatorService _instance = DummyOperatorService._internal();
  factory DummyOperatorService() => _instance;
  DummyOperatorService._internal() {
    _initializeSeedData();
  }

  // Operator Auth (F014)
  OperatorModel? _currentOperator = const OperatorModel(
    operatorId: 1,
    name: 'Pak Kemas',
    username: 'kemas',
    password: 'password',
    role: 'Operator Lapangan & Mesin',
  );

  bool _isLoggedIn = true; // Default true for seamless widget test compatibility

  OperatorModel? get currentOperator => _currentOperator;
  bool get isLoggedIn => _isLoggedIn;

  Future<bool> login(String username, String password) async {
    final cleanUsername = username.trim().toLowerCase();
    final cleanPassword = password.trim();

    // Check against authorized credentials
    final validUsernames = ['kemas', 'operator', 'admin', 'operator@smartheat.id'];
    final validPasswords = ['password', '123456', 'operator123', 'admin123'];

    if (validUsernames.contains(cleanUsername) && validPasswords.contains(cleanPassword)) {
      _currentOperator = OperatorModel(
        operatorId: cleanUsername == 'admin' ? 99 : 1,
        name: cleanUsername == 'kemas' ? 'Pak Kemas' : 'Operator Smart H-EAT',
        username: cleanUsername,
        password: cleanPassword,
        role: 'Operator Lapangan',
      );
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }

  // Categories (F016 - 5 Kategori Mie Tarempa)
  final List<CategoryModel> _categories = [
    CategoryModel(categoryId: 1, name: 'Mie Tarempa Kering', order: 0),
    CategoryModel(categoryId: 2, name: 'Mie Tarempa Basah', order: 1),
    CategoryModel(categoryId: 3, name: 'Mie Tarempa Lembab', order: 2),
    CategoryModel(categoryId: 4, name: 'Mie Tarempa Goreng', order: 3),
    CategoryModel(categoryId: 5, name: 'Mie Tarempa Rebus', order: 4),
  ];

  List<CategoryModel> get categories => List.unmodifiable(_categories);

  void addCategory(String name) {
    if (name.trim().isEmpty) return;
    final newId = _categories.isEmpty
        ? 1
        : (_categories.map((c) => c.categoryId).reduce((a, b) => a > b ? a : b) + 1);
    _categories.add(CategoryModel(
      categoryId: newId,
      name: name.trim(),
      order: _categories.length,
    ));
    notifyListeners();
  }

  void updateCategory(int id, String newName) {
    final index = _categories.indexWhere((c) => c.categoryId == id);
    if (index != -1 && newName.trim().isNotEmpty) {
      _categories[index].name = newName.trim();
      notifyListeners();
    }
  }

  void deleteCategory(int id) {
    _categories.removeWhere((c) => c.categoryId == id);
    notifyListeners();
  }

  void reorderCategories(int oldIndex, int newIndex) {
    if (oldIndex < newIndex) {
      newIndex -= 1;
    }
    final item = _categories.removeAt(oldIndex);
    _categories.insert(newIndex, item);
    for (int i = 0; i < _categories.length; i++) {
      _categories[i].order = i;
    }
    notifyListeners();
  }

  void saveCategories(List<CategoryModel> updatedCategories) {
    _categories.clear();
    for (int i = 0; i < updatedCategories.length; i++) {
      _categories.add(updatedCategories[i].copyWith(order: i));
    }
    notifyListeners();
  }

  // Menus (F016 & F018)
  final List<MenuModel> _menus = [];
  List<MenuModel> get menus => List.unmodifiable(_menus);

  int get totalStock => _menus.fold<int>(0, (sum, m) => sum + m.stock);
  int get totalCapacity => _menus.fold<int>(0, (sum, m) => sum + m.slotCapacity);
  List<MenuModel> get lowStockMenus => _menus.where((m) => m.stock <= m.minStock).toList();

  MenuModel? getMenuById(int id) {
    try {
      return _menus.firstWhere((m) => m.menuId == id);
    } catch (_) {
      return null;
    }
  }

  void addMenu(MenuModel menu) {
    final newId = _menus.isEmpty
        ? 1
        : (_menus.map((m) => m.menuId).reduce((a, b) => a > b ? a : b) + 1);
    // Atur stok maksimal 10 porsi per menu
    final clampedStock = menu.stock.clamp(0, 10);
    _menus.add(menu.copyWith(
      menuId: newId,
      stock: clampedStock,
      slotCapacity: 10,
    ));
    notifyListeners();
  }

  void updateMenu(MenuModel updated) {
    final index = _menus.indexWhere((m) => m.menuId == updated.menuId);
    if (index != -1) {
      final clampedStock = updated.stock.clamp(0, 10);
      _menus[index] = updated.copyWith(
        stock: clampedStock,
        slotCapacity: 10,
      );
      notifyListeners();
    }
  }

  void deleteMenu(int id) {
    _menus.removeWhere((m) => m.menuId == id);
    notifyListeners();
  }

  // Variations (F017)
  void addVariationGroup(int menuId, String groupName, bool isRequired) {
    final menu = getMenuById(menuId);
    if (menu == null || groupName.trim().isEmpty) return;

    final newGroupId = menu.variationGroups.isEmpty
        ? 1
        : (menu.variationGroups.map((g) => g.groupId).reduce((a, b) => a > b ? a : b) + 1);

    menu.variationGroups.add(MenuVariationGroup(
      groupId: newGroupId,
      menuId: menuId,
      name: groupName.trim(),
      isRequired: isRequired,
      options: [],
    ));
    notifyListeners();
  }

  void updateVariationGroup(int menuId, int groupId, String newName, bool isRequired) {
    final menu = getMenuById(menuId);
    if (menu == null || newName.trim().isEmpty) return;
    final groupIndex = menu.variationGroups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex != -1) {
      menu.variationGroups[groupIndex].name = newName.trim();
      menu.variationGroups[groupIndex].isRequired = isRequired;
      notifyListeners();
    }
  }

  void deleteVariationGroup(int menuId, int groupId) {
    final menu = getMenuById(menuId);
    if (menu == null) return;
    menu.variationGroups.removeWhere((g) => g.groupId == groupId);
    notifyListeners();
  }

  bool addVariationOption(int menuId, int groupId, String optionName, double extraPrice) {
    if (extraPrice < 0) return false;
    final menu = getMenuById(menuId);
    if (menu == null || optionName.trim().isEmpty) return false;
    final groupIndex = menu.variationGroups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex == -1) return false;

    final group = menu.variationGroups[groupIndex];
    final newOptionId = group.options.isEmpty
        ? 1
        : (group.options.map((o) => o.optionId).reduce((a, b) => a > b ? a : b) + 1);

    group.options.add(MenuVariationOption(
      optionId: newOptionId,
      groupId: groupId,
      name: optionName.trim(),
      extraPrice: extraPrice,
    ));
    notifyListeners();
    return true;
  }

  bool updateVariationOption(
    int menuId,
    int groupId,
    int optionId,
    String optionName,
    double extraPrice,
  ) {
    if (extraPrice < 0) return false;
    final menu = getMenuById(menuId);
    if (menu == null || optionName.trim().isEmpty) return false;
    final groupIndex = menu.variationGroups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex == -1) return false;

    final group = menu.variationGroups[groupIndex];
    final optIndex = group.options.indexWhere((o) => o.optionId == optionId);
    if (optIndex != -1) {
      group.options[optIndex].name = optionName.trim();
      group.options[optIndex].extraPrice = extraPrice;
      notifyListeners();
      return true;
    }
    return false;
  }

  void deleteVariationOption(int menuId, int groupId, int optionId) {
    final menu = getMenuById(menuId);
    if (menu == null) return;
    final groupIndex = menu.variationGroups.indexWhere((g) => g.groupId == groupId);
    if (groupIndex == -1) return;

    menu.variationGroups[groupIndex].options.removeWhere((o) => o.optionId == optionId);
    notifyListeners();
  }

  // Restock & Restock Logs (F020 & F021)
  final List<RestockLogModel> _restockLogs = [];
  List<RestockLogModel> get restockLogs => List.unmodifiable(_restockLogs);

  bool restockMenu(int id, int qtyAdded, {String note = 'Restock rutin tray mesin'}) {
    if (qtyAdded <= 0) return false;
    final index = _menus.indexWhere((m) => m.menuId == id);
    if (index != -1) {
      final current = _menus[index];
      final stockBefore = current.stock;
      const maxLimit = 10;
      final newStock = (current.stock + qtyAdded).clamp(0, maxLimit);
      if (newStock == stockBefore) {
        return false; // Sudah mencapai batas maksimal 10 porsi
      }
      _menus[index] = current.copyWith(stock: newStock, slotCapacity: maxLimit);

      // Record to restock_logs (SKPPL F020 & F021)
      final newLogId = _restockLogs.isEmpty ? 1 : (_restockLogs.first.restockLogId + 1);
      _restockLogs.insert(
        0,
        RestockLogModel(
          restockLogId: newLogId,
          menuId: current.menuId,
          menuName: current.name,
          operatorId: _currentOperator?.operatorId ?? 1,
          operatorName: _currentOperator?.name ?? 'Pak Kemas',
          qtyAdded: newStock - stockBefore,
          stockBefore: stockBefore,
          stockAfter: newStock,
          note: note,
          createdAt: DateTime.now(),
        ),
      );

      notifyListeners();
      return true;
    }
    return false;
  }

  // Live Orders Monitoring (F015)
  final List<OrderModel> _orders = [];
  List<OrderModel> get orders => List.unmodifiable(_orders);

  int get activeOrdersCount => _orders.where((o) => o.status == 'diproses' || o.status == 'siap_diambil').length;

  void updateOrderStatus(int orderId, String newStatus) {
    final index = _orders.indexWhere((o) => o.orderId == orderId);
    if (index != -1) {
      _orders[index].status = newStatus;
      notifyListeners();
    }
  }

  /// Memproses pesanan dan mengurangi stok menu (maksimal 10, cegah bila stok 0)
  bool placeOrder({
    required int menuId,
    int qty = 1,
    List<OrderItemVariationModel> variations = const [],
  }) {
    if (qty <= 0) return false;
    final index = _menus.indexWhere((m) => m.menuId == menuId);
    if (index == -1) return false;

    final menu = _menus[index];
    // Cegah pemesanan jika stok 0 atau porsi diminta melebihi stok yang ada
    if (menu.stock <= 0 || menu.stock < qty) {
      return false;
    }

    // Kurangi stok menu secara terpisah
    final newStock = (menu.stock - qty).clamp(0, 10);
    _menus[index] = menu.copyWith(stock: newStock);

    final newId = _orders.isEmpty ? 1 : (_orders.map((o) => o.orderId).reduce((a, b) => a > b ? a : b) + 1);
    final queueNum = 'A-0${newId.toString().padLeft(2, '0')}';
    final randomCode = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${100 + newId}';

    final extraTotal = variations.fold<double>(0.0, (sum, v) => sum + v.extraPrice);
    final total = (menu.price * qty) + extraTotal;

    final newOrder = OrderModel(
      orderId: newId,
      orderCode: randomCode,
      queueNumber: queueNum,
      totalAmount: total,
      status: 'diproses',
      paidAt: DateTime.now(),
      items: [
        OrderItemModel(
          orderItemId: newId * 10,
          orderId: newId,
          menuId: menu.menuId,
          menuName: menu.name,
          price: menu.price,
          qty: qty,
          subtotal: total,
          variations: variations,
        ),
      ],
    );

    _orders.insert(0, newOrder);
    notifyListeners();
    return true;
  }

  void simulateIncomingOrder() {
    // Cari menu yang stoknya masih tersedia (> 0)
    final availableMenus = _menus.where((m) => m.stock > 0).toList();
    if (availableMenus.isEmpty) return; // Jika semua stok 0, cegah pesanan

    final newId = _orders.isEmpty ? 1 : (_orders.map((o) => o.orderId).reduce((a, b) => a > b ? a : b) + 1);
    final queueNum = 'A-0${newId.toString().padLeft(2, '0')}';
    final randomCode = 'ORD-${DateTime.now().year}${DateTime.now().month.toString().padLeft(2, '0')}${DateTime.now().day.toString().padLeft(2, '0')}-${100 + newId}';

    final sampleMenu = availableMenus[(newId - 1) % availableMenus.length];
    final menuName = sampleMenu.name;
    final menuPrice = sampleMenu.price;

    // Kurangi stok menu sesuai jumlah pesanan (1 porsi)
    final newStock = (sampleMenu.stock - 1).clamp(0, 10);
    final menuIndex = _menus.indexWhere((m) => m.menuId == sampleMenu.menuId);
    if (menuIndex != -1) {
      _menus[menuIndex] = sampleMenu.copyWith(stock: newStock);
    }

    final newOrder = OrderModel(
      orderId: newId,
      orderCode: randomCode,
      queueNumber: queueNum,
      totalAmount: menuPrice + 2000,
      status: 'diproses',
      paidAt: DateTime.now(),
      items: [
        OrderItemModel(
          orderItemId: newId * 10,
          orderId: newId,
          menuId: sampleMenu.menuId,
          menuName: menuName,
          price: menuPrice,
          qty: 1,
          subtotal: menuPrice + 2000,
          variations: [
            OrderItemVariationModel(
              orderItemVariationId: newId * 100 + 1,
              orderItemId: newId * 10,
              groupName: 'Tingkat Kepedasan',
              optionName: 'Pedas Mantap',
              extraPrice: 2000,
            ),
          ],
        ),
      ],
    );

    _orders.insert(0, newOrder);
    notifyListeners();
  }

  // Reports (F022)
  SalesReportData getSalesReport(SalesPeriod period) {
    switch (period) {
      case SalesPeriod.daily:
        return SalesReportData(
          period: SalesPeriod.daily,
          totalRevenueDisplay: 'Rp 2,8 Jt',
          totalPortions: 70,
          peakSummary: 'Puncak: 12.00 - 13.00 (28 Porsi)',
          dailyTrends: [
            SalesDailyTrend(dayName: '08:00', count: 8),
            SalesDailyTrend(dayName: '10:00', count: 12),
            SalesDailyTrend(dayName: '12:00', count: 28, isPeak: true),
            SalesDailyTrend(dayName: '14:00', count: 10),
            SalesDailyTrend(dayName: '16:00', count: 6),
            SalesDailyTrend(dayName: '18:00', count: 18),
            SalesDailyTrend(dayName: '20:00', count: 12),
          ],
          menuSales: [
            MenuSalesStat(
              menuName: 'Mie Tarempa Kering',
              portionsSold: 28,
              totalRevenue: 700000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Basah',
              portionsSold: 22,
              totalRevenue: 616000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Lembab',
              portionsSold: 20,
              totalRevenue: 540000,
            ),
          ],
        );

      case SalesPeriod.weekly:
        return SalesReportData(
          period: SalesPeriod.weekly,
          totalRevenueDisplay: 'Rp 19 Jt',
          totalPortions: 482,
          peakSummary: 'Puncak: Jum (94 Porsi)',
          dailyTrends: [
            SalesDailyTrend(dayName: 'Sen', count: 54),
            SalesDailyTrend(dayName: 'Sel', count: 62),
            SalesDailyTrend(dayName: 'Rab', count: 58),
            SalesDailyTrend(dayName: 'Kam', count: 70),
            SalesDailyTrend(dayName: 'Jum', count: 94, isPeak: true),
            SalesDailyTrend(dayName: 'Sab', count: 82),
            SalesDailyTrend(dayName: 'Min', count: 62),
          ],
          menuSales: [
            MenuSalesStat(
              menuName: 'Mie Tarempa Kering',
              portionsSold: 148,
              totalRevenue: 3700000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Basah',
              portionsSold: 132,
              totalRevenue: 3696000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Lembab',
              portionsSold: 112,
              totalRevenue: 3024000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Goreng',
              portionsSold: 90,
              totalRevenue: 2340000,
            ),
          ],
        );

      case SalesPeriod.monthly:
        return SalesReportData(
          period: SalesPeriod.monthly,
          totalRevenueDisplay: 'Rp 78 Jt',
          totalPortions: 1940,
          peakSummary: 'Puncak: Minggu ke-3 (540 Porsi)',
          dailyTrends: [
            SalesDailyTrend(dayName: 'M-1', count: 420),
            SalesDailyTrend(dayName: 'M-2', count: 490),
            SalesDailyTrend(dayName: 'M-3', count: 540, isPeak: true),
            SalesDailyTrend(dayName: 'M-4', count: 490),
          ],
          menuSales: [
            MenuSalesStat(
              menuName: 'Mie Tarempa Kering',
              portionsSold: 610,
              totalRevenue: 15250000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Basah',
              portionsSold: 540,
              totalRevenue: 15120000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Lembab',
              portionsSold: 450,
              totalRevenue: 12150000,
            ),
            MenuSalesStat(
              menuName: 'Mie Tarempa Goreng',
              portionsSold: 340,
              totalRevenue: 8840000,
            ),
          ],
        );
    }
  }

  void _initializeSeedData() {
    // Menus with Variations (SKPPL F016 & F017)
    _menus.addAll([
      MenuModel(
        menuId: 1,
        categoryId: 1,
        name: 'Mie Tarempa Kering',
        description: 'Mie pipih khas Tarempa disajikan kering tanpa kuah, dengan taburan suwiran ikan tongkol gurih, tauge, dan bawang goreng renyah.',
        price: 25000,
        imageUrl: 'assets/menu/mie_tarempa_kering.jpg',
        spiciness: 'Sedang',
        stock: 10,
        slotCapacity: 10,
        minStock: 2,
        variationGroups: [
          MenuVariationGroup(
            groupId: 101,
            menuId: 1,
            name: 'Tingkat Kepedasan',
            isRequired: true,
            options: [
              MenuVariationOption(optionId: 1, groupId: 101, name: 'Tidak Pedas', extraPrice: 0),
              MenuVariationOption(optionId: 2, groupId: 101, name: 'Sedang', extraPrice: 0),
              MenuVariationOption(optionId: 3, groupId: 101, name: 'Pedas Gurih', extraPrice: 0),
              MenuVariationOption(optionId: 4, groupId: 101, name: 'Ekstra Pedas Nampol', extraPrice: 2000),
            ],
          ),
          MenuVariationGroup(
            groupId: 102,
            menuId: 1,
            name: 'Tambahan / Topping',
            isRequired: false,
            options: [
              MenuVariationOption(optionId: 5, groupId: 102, name: 'Telur Dadar Rempah', extraPrice: 4000),
              MenuVariationOption(optionId: 6, groupId: 102, name: 'Kerupuk Kulit Renyah', extraPrice: 3000),
            ],
          ),
        ],
      ),
      MenuModel(
        menuId: 2,
        categoryId: 2,
        name: 'Mie Tarempa Basah',
        description: 'Mie Tarempa dengan kuah merah kental gurih pedas khas Kepri berlimpah bumbu rempah dan suwiran ikan tongkol segar.',
        price: 28000,
        imageUrl: 'assets/menu/mie_tarempa_basah.jpg',
        spiciness: 'Pedas',
        stock: 10,
        slotCapacity: 10,
        minStock: 2,
        variationGroups: [
          MenuVariationGroup(
            groupId: 201,
            menuId: 2,
            name: 'Tingkat Kepedasan',
            isRequired: true,
            options: [
              MenuVariationOption(optionId: 7, groupId: 201, name: 'Sedang', extraPrice: 0),
              MenuVariationOption(optionId: 8, groupId: 201, name: 'Pedas Sambal Ijo', extraPrice: 1000),
              MenuVariationOption(optionId: 9, groupId: 201, name: 'Super Pedas Rawit', extraPrice: 2000),
            ],
          ),
        ],
      ),
      MenuModel(
        menuId: 3,
        categoryId: 3,
        name: 'Mie Tarempa Lembab',
        description: 'Mie Tarempa bertekstur lembab/nyemek dengan sedikit kuah kental gurih, orak-arik telur, dan suwiran ikan tongkol lezat.',
        price: 27000,
        imageUrl: 'assets/menu/mie_tarempa_lembab.jpg',
        spiciness: 'Sedang',
        stock: 10,
        slotCapacity: 10,
        minStock: 2,
        variationGroups: [
          MenuVariationGroup(
            groupId: 301,
            menuId: 3,
            name: 'Tingkat Kepedasan',
            isRequired: true,
            options: [
              MenuVariationOption(optionId: 10, groupId: 301, name: 'Tidak Pedas', extraPrice: 0),
              MenuVariationOption(optionId: 11, groupId: 301, name: 'Sedang', extraPrice: 0),
              MenuVariationOption(optionId: 12, groupId: 301, name: 'Pedas Menggelegar', extraPrice: 2000),
            ],
          ),
        ],
      ),
      MenuModel(
        menuId: 4,
        categoryId: 4,
        name: 'Mie Tarempa Goreng',
        description: 'Mie Tarempa digoreng dengan bumbu spesial kecap gurih wangi wok-hei, disajikan dengan suwiran tongkol, acar mentimun, dan kerupuk.',
        price: 26000,
        imageUrl: 'assets/menu/mie_tarempa_goreng.jpg',
        spiciness: 'Tidak Pedas',
        stock: 10,
        slotCapacity: 10,
        minStock: 2,
        variationGroups: [
          MenuVariationGroup(
            groupId: 401,
            menuId: 4,
            name: 'Pilihan Sambal & Jeruk',
            isRequired: false,
            options: [
              MenuVariationOption(optionId: 13, groupId: 401, name: 'Ekstra Sambal Rawit Hijau', extraPrice: 1500),
              MenuVariationOption(optionId: 14, groupId: 401, name: 'Jeruk Nipis Segar', extraPrice: 1000),
            ],
          ),
        ],
      ),
      MenuModel(
        menuId: 5,
        categoryId: 5,
        name: 'Mie Tarempa Rebus',
        description: 'Mie Tarempa dalam kuah kaldu ikan bening segar nan gurih, disajikan hangat dengan sawi hijau, telur, dan irisan cabai rawit.',
        price: 28000,
        imageUrl: 'assets/menu/mie_tarempa_rebus.jpg',
        spiciness: 'Sedang',
        stock: 10,
        slotCapacity: 10,
        minStock: 2,
        variationGroups: [
          MenuVariationGroup(
            groupId: 501,
            menuId: 5,
            name: 'Tingkat Kepedasan',
            isRequired: true,
            options: [
              MenuVariationOption(optionId: 15, groupId: 501, name: 'Tidak Pedas', extraPrice: 0),
              MenuVariationOption(optionId: 16, groupId: 501, name: 'Sedang', extraPrice: 0),
              MenuVariationOption(optionId: 17, groupId: 501, name: 'Pedas Cabai Rawit', extraPrice: 1500),
            ],
          ),
        ],
      ),
    ]);

    // Initial Restock History (SKPPL F021)
    _restockLogs.addAll([
      RestockLogModel(
        restockLogId: 101,
        menuId: 1,
        menuName: 'Mie Tarempa Kering',
        operatorId: 1,
        operatorName: 'Pak Kemas',
        qtyAdded: 4,
        stockBefore: 6,
        stockAfter: 10,
        note: 'Restock shift pagi tray 1',
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
      ),
      RestockLogModel(
        restockLogId: 102,
        menuId: 2,
        menuName: 'Mie Tarempa Basah',
        operatorId: 1,
        operatorName: 'Pak Kemas',
        qtyAdded: 3,
        stockBefore: 7,
        stockAfter: 10,
        note: 'Pengisian ulang setelah lonjakan makan siang',
        createdAt: DateTime.now().subtract(const Duration(hours: 6)),
      ),
      RestockLogModel(
        restockLogId: 103,
        menuId: 3,
        menuName: 'Mie Tarempa Lembab',
        operatorId: 1,
        operatorName: 'Pak Kemas',
        qtyAdded: 2,
        stockBefore: 8,
        stockAfter: 10,
        note: 'Restock produk baru dari dapur sentral',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 2)),
      ),
      RestockLogModel(
        restockLogId: 104,
        menuId: 4,
        menuName: 'Mie Tarempa Goreng',
        operatorId: 1,
        operatorName: 'Pak Kemas',
        qtyAdded: 5,
        stockBefore: 5,
        stockAfter: 10,
        note: 'Restock harian tray 4',
        createdAt: DateTime.now().subtract(const Duration(days: 1, hours: 8)),
      ),
    ]);

    // Initial Live Orders (SKPPL F015)
    _orders.addAll([
      OrderModel(
        orderId: 1,
        orderCode: 'ORD-20261019-001',
        queueNumber: 'A-01',
        totalAmount: 30000,
        status: 'diproses',
        paidAt: DateTime.now().subtract(const Duration(minutes: 2)),
        items: [
          OrderItemModel(
            orderItemId: 1,
            orderId: 1,
            menuId: 3,
            menuName: 'Mie Tarempa Banjir',
            price: 28000,
            qty: 1,
            subtotal: 30000,
            variations: [
              OrderItemVariationModel(
                orderItemVariationId: 1,
                orderItemId: 1,
                groupName: 'Tingkat Kepedasan',
                optionName: 'Pedas Menggelegar',
                extraPrice: 2000,
              ),
            ],
          ),
        ],
      ),
      OrderModel(
        orderId: 2,
        orderCode: 'ORD-20261019-002',
        queueNumber: 'A-02',
        totalAmount: 40000,
        status: 'siap_diambil',
        paidAt: DateTime.now().subtract(const Duration(minutes: 8)),
        items: [
          OrderItemModel(
            orderItemId: 2,
            orderId: 2,
            menuId: 1,
            menuName: 'Rendang Daging Sapi',
            price: 35000,
            qty: 1,
            subtotal: 40000,
            variations: [
              OrderItemVariationModel(
                orderItemVariationId: 2,
                orderItemId: 2,
                groupName: 'Pilihan Porsi',
                optionName: 'Porsi Jumbo (+ Nasi Tambah)',
                extraPrice: 5000,
              ),
            ],
          ),
        ],
      ),
      OrderModel(
        orderId: 3,
        orderCode: 'ORD-20261019-003',
        queueNumber: 'A-03',
        totalAmount: 70000,
        status: 'selesai',
        paidAt: DateTime.now().subtract(const Duration(minutes: 25)),
        items: [
          OrderItemModel(
            orderItemId: 3,
            orderId: 3,
            menuId: 2,
            menuName: 'Nasi Cumi Hitam',
            price: 35000,
            qty: 2,
            subtotal: 70000,
            variations: [
              OrderItemVariationModel(
                orderItemVariationId: 3,
                orderItemId: 3,
                groupName: 'Tingkat Kepedasan',
                optionName: 'Pedas Sambal Ijo',
                extraPrice: 0,
              ),
            ],
          ),
        ],
      ),
      OrderModel(
        orderId: 4,
        orderCode: 'ORD-20261019-004',
        queueNumber: 'A-04',
        totalAmount: 43500,
        status: 'menunggu_pembayaran',
        paidAt: DateTime.now().subtract(const Duration(minutes: 1)),
        items: [
          OrderItemModel(
            orderItemId: 4,
            orderId: 4,
            menuId: 4,
            menuName: 'Sup Buntut Hangat',
            price: 42000,
            qty: 1,
            subtotal: 43500,
            variations: [
              OrderItemVariationModel(
                orderItemVariationId: 4,
                orderItemId: 4,
                groupName: 'Pilihan Sambal & Jeruk',
                optionName: 'Ekstra Sambal Rawit Hijau',
                extraPrice: 1500,
              ),
            ],
          ),
        ],
      ),
    ]);
  }
}
