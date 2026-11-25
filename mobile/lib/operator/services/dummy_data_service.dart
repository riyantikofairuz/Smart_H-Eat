import 'package:flutter/foundation.dart';
import '../models/category_model.dart';
import '../models/menu_model.dart';

/// ============================================================================
/// DUMMY DATA LOKAL - OPERATOR SMART H-EAT
/// ============================================================================
/// PERHATIAN:
/// File ini menyediakan data lokal dan state in-memory sementara untuk frontend
/// aplikasi Operator Smart H-EAT.
/// TIDAK MENGUBAH / MENGAKSES DATABASE BACKEND LARAVEL.
/// Siap diganti atau dihubungkan ke REST API Laravel oleh tim backend nanti.
/// ============================================================================
class DummyDataService extends ChangeNotifier {
  static final DummyDataService _instance = DummyDataService._internal();
  factory DummyDataService() => _instance;
  DummyDataService._internal() {
    _initDefaultData();
  }

  final List<CategoryModel> _categories = [];
  final List<MenuModel> _menus = [];

  // Vending Machine telemetry data & Dashboard operational summary
  final String _machineId = 'VEND-01 (Lobi Utama)';
  final double _temperature = 60.0; // Suhu pemanas optimal dalam °C (Screenshot: 60°C)
  final String _systemStatus = 'Optimal';
  String _operatorGreeting = 'Pak Kemas';
  final String _dailyRevenue = 'Rp 4,25 Jt';
  final int _portionsSold = 6;
  final int _vendingTemperature = 60;
  final String _temperatureStatus = 'Suhu Optimal';
  final bool _needsRestock = true;

  List<CategoryModel> get categories => List.unmodifiable(_categories);
  List<MenuModel> get menus => List.unmodifiable(_menus);

  String get machineId => _machineId;
  double get temperature => _temperature;
  String get systemStatus => _systemStatus;
  String get operatorGreeting => _operatorGreeting;
  String get dailyRevenue => _dailyRevenue;
  int get portionsSold => _portionsSold;
  int get vendingTemperature => _vendingTemperature;
  String get temperatureStatus => _temperatureStatus;
  bool get needsRestock => _needsRestock;

  int get totalMenus => _menus.length;
  int get activeMenus => _menus.where((m) => m.isActive).length;
  int get totalStock => _menus.fold(0, (sum, item) => sum + item.stock);
  int get lowStockCount => _menus.where((m) => m.isLowStock).length;
  int get outOfStockCount => _menus.where((m) => m.isOutOfStock).length;
  int get safeStockCount => _menus.where((m) => m.isStockSafe).length;

  int getCategoryCount(int categoryId) {
    if (categoryId == 0) return _menus.length;
    return _menus.where((m) => m.categoryId == categoryId).length;
  }

  void _initDefaultData() {
    _categories.addAll([
      CategoryModel(id: 1, name: 'Nasi'),
      CategoryModel(id: 2, name: 'Sup & Kuah'),
      CategoryModel(id: 3, name: 'Mie & Pasta'),
    ]);

    _menus.addAll([
      // Kategori 1: Nasi (6 items)
      MenuModel(
        id: 1,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Nasi Cumi Hitam',
        characteristic: 'Kering',
        description: 'Nasi hangat disajikan dengan olahan cumi tinta hitam gurih kaya rempah.',
        price: 28000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 2,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Nasi Ayam Bakar Madu',
        characteristic: 'Kering',
        description: 'Ayam bakar saus madu manis gurih dengan lalapan segar dan sambal.',
        price: 25000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 3,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Nasi Uduk Komplit Telur Balado',
        characteristic: 'Kering',
        description: 'Nasi uduk harum santan dengan orek tempe, bihun, dan telur balado.',
        price: 18000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 4,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Nasi Rendang Sapi Hangat',
        characteristic: 'Kering',
        description: 'Daging sapi rendang empuk bumbu rempah autentik Padang.',
        price: 28000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 5,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Nasi Kuning Gurih Ayam Suwir',
        characteristic: 'Kering',
        description: 'Nasi kuning wangi kunyit alami disajikan dengan serundeng dan ayam.',
        price: 20000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 6,
        categoryId: 1,
        categoryName: 'Nasi',
        name: 'Bento Nasi Ayam Teriyaki',
        characteristic: 'Kering',
        description: 'Ayam teriyaki saus manis gurih dengan nasi pulen hangat dan salad.',
        price: 26000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),

      // Kategori 2: Sup & Kuah (2 items)
      MenuModel(
        id: 7,
        categoryId: 2,
        categoryName: 'Sup & Kuah',
        name: 'Sup Ayam Jamur Panas',
        characteristic: 'Berkuah',
        description: 'Sup kaldu ayam bening kaya rempah dengan irisan jamur dan wortel.',
        price: 16000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 8,
        categoryId: 2,
        categoryName: 'Sup & Kuah',
        name: 'Soto Ayam Lamongan Hangat',
        characteristic: 'Berkuah',
        description: 'Soto kuah kuning koya gurih dengan suwiran ayam dan soun lembut.',
        price: 18000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),

      // Kategori 3: Mie & Pasta (4 items)
      MenuModel(
        id: 9,
        categoryId: 3,
        categoryName: 'Mie & Pasta',
        name: 'Mie Tarempa Lembab Seafood',
        characteristic: 'Lembab',
        description: 'Mie Tarempa pipih khas Kepulauan Riau dengan olahan seafood gurih dan kuah sedikit (lembab).',
        price: 25000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 10,
        categoryId: 3,
        categoryName: 'Mie & Pasta',
        name: 'Mie Tarempa Banjir',
        characteristic: 'Banjir',
        description: 'Mie Tarempa berkuah melimpah (banjir) kaya kaldu rempah hangat gurih nikmat.',
        price: 25000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 11,
        categoryId: 3,
        categoryName: 'Mie & Pasta',
        name: 'Spaghetti Bolognese Hangat',
        characteristic: 'Lembab',
        description: 'Pasta spaghetti saus daging sapi cincang tomat khas Italia.',
        price: 24000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
      MenuModel(
        id: 12,
        categoryId: 3,
        categoryName: 'Mie & Pasta',
        name: 'Kwetiau Goreng Seafood Hangat',
        characteristic: 'Kering',
        description: 'Kwetiau kenyal digoreng harum dengan telur, udang, dan sayuran.',
        price: 22000,
        stock: 6,
        maxSlot: 6,
        minStockThreshold: 2,
        isActive: true,
      ),
    ]);
  }

  /// Tambah kategori baru secara lokal
  bool addCategory(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return false;

    // Check duplicate
    final exists = _categories.any(
      (c) => c.name.toLowerCase() == trimmed.toLowerCase(),
    );
    if (exists) return false;

    final newId = _categories.isEmpty
        ? 1
        : _categories.map((c) => c.id).reduce((a, b) => a > b ? a : b) + 1;

    _categories.add(CategoryModel(id: newId, name: trimmed));
    notifyListeners();
    return true;
  }

  /// Tambah menu baru secara lokal
  bool addMenu({
    required int categoryId,
    required String name,
    String? description,
    String? characteristic,
    required int price,
    required int initialStock,
    int maxSlot = 6,
    int minStockThreshold = 5,
    String? imageUrl,
  }) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty || price <= 0 || initialStock < 0) return false;

    final category = _categories.firstWhere(
      (c) => c.id == categoryId,
      orElse: () => CategoryModel(id: categoryId, name: 'Umum'),
    );

    final newId = _menus.isEmpty
        ? 1
        : _menus.map((m) => m.id).reduce((a, b) => a > b ? a : b) + 1;

    final newMenu = MenuModel(
      id: newId,
      categoryId: category.id,
      categoryName: category.name,
      name: trimmedName,
      description: description?.trim(),
      characteristic: characteristic?.trim(),
      price: price,
      stock: initialStock,
      maxSlot: maxSlot,
      minStockThreshold: minStockThreshold,
      imageUrl: imageUrl,
      isActive: true,
    );

    _menus.insert(0, newMenu);
    notifyListeners();
    return true;
  }

  /// Update data menu secara lokal
  bool updateMenu({
    required int id,
    required String name,
    required int categoryId,
    required int stock,
    int maxSlot = 6,
    int? price,
    String? description,
    String? characteristic,
    String? imageUrl,
  }) {
    final index = _menus.indexWhere((m) => m.id == id);
    if (index != -1) {
      final category = _categories.firstWhere(
        (c) => c.id == categoryId,
        orElse: () => CategoryModel(id: categoryId, name: _menus[index].categoryName),
      );
      _menus[index] = _menus[index].copyWith(
        name: name.trim(),
        categoryId: category.id,
        categoryName: category.name,
        stock: stock,
        maxSlot: maxSlot,
        price: price ?? _menus[index].price,
        description: description ?? _menus[index].description,
        characteristic: characteristic ?? _menus[index].characteristic,
        imageUrl: imageUrl ?? _menus[index].imageUrl,
      );
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Hapus menu secara lokal
  bool deleteMenu(int menuId) {
    final index = _menus.indexWhere((m) => m.id == menuId);
    if (index != -1) {
      _menus.removeAt(index);
      notifyListeners();
      return true;
    }
    return false;
  }

  /// Update stok menu secara lokal (misalnya aksi restock / kurangi)
  void updateStock(int menuId, int delta) {
    final index = _menus.indexWhere((m) => m.id == menuId);
    if (index != -1) {
      final current = _menus[index];
      final newStock = (current.stock + delta).clamp(0, 999);
      _menus[index] = current.copyWith(stock: newStock);
      notifyListeners();
    }
  }

  /// Toggle status aktif menu secara lokal
  void toggleMenuActive(int menuId) {
    final index = _menus.indexWhere((m) => m.id == menuId);
    if (index != -1) {
      final current = _menus[index];
      _menus[index] = current.copyWith(isActive: !current.isActive);
      notifyListeners();
    }
  }

  /// Update nama sapaan operator sesuai sesi login yang aktif
  void updateOperatorGreeting(String name) {
    if (name.trim().isNotEmpty) {
      _operatorGreeting = name.trim();
      notifyListeners();
    }
  }

  /// Reset data dummy ke nilai awal jika diperlukan
  void resetToDefault() {
    _operatorGreeting = 'Pak Kemas';
    _categories.clear();
    _menus.clear();
    _initDefaultData();
    notifyListeners();
  }
}
