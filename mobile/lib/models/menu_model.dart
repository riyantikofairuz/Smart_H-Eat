import 'variation_model.dart';

class MenuModel {
  final int menuId;
  int categoryId;
  String categoryName;
  String name;
  String description;
  String characteristic;
  double price;
  String? imageUrl;
  String spiciness; // 'Tidak Pedas', 'Sedang', 'Pedas'
  int stock;
  int slotCapacity;
  int minStock;
  bool isActive;
  List<MenuVariationGroup> variationGroups;

  // Compatibility getters for teman's code
  int get id => menuId;
  int get maxSlot => slotCapacity;
  int get minStockThreshold => minStock;

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= minStock;
  bool get isStockSafe => stock > minStock;

  String get formattedPrice {
    final intVal = price.round();
    final valueStr = intVal.toString();
    final buffer = StringBuffer();
    int count = 0;
    for (int i = valueStr.length - 1; i >= 0; i--) {
      buffer.write(valueStr[i]);
      count++;
      if (count % 3 == 0 && i > 0) {
        buffer.write('.');
      }
    }
    final formatted = buffer.toString().split('').reversed.join('');
    return 'Rp $formatted';
  }

  MenuModel({
    int? id,
    int? menuId,
    required this.categoryId,
    this.categoryName = '',
    required this.name,
    this.description = '',
    this.characteristic = '',
    required dynamic price,
    this.imageUrl,
    this.spiciness = 'Tidak Pedas',
    this.stock = 10,
    int? slotCapacity,
    int? maxSlot,
    int? minStock,
    int? minStockThreshold,
    this.isActive = true,
    List<MenuVariationGroup>? variationGroups,
  })  : menuId = menuId ?? id ?? 0,
        price = (price is num) ? price.toDouble() : 0.0,
        slotCapacity = slotCapacity ?? maxSlot ?? 10,
        minStock = minStock ?? minStockThreshold ?? 2,
        variationGroups = variationGroups ?? [];

  MenuModel copyWith({
    int? id,
    int? menuId,
    int? categoryId,
    String? categoryName,
    String? name,
    String? description,
    String? characteristic,
    dynamic price,
    String? imageUrl,
    String? spiciness,
    int? stock,
    int? slotCapacity,
    int? maxSlot,
    int? minStock,
    int? minStockThreshold,
    bool? isActive,
    List<MenuVariationGroup>? variationGroups,
  }) {
    return MenuModel(
      menuId: menuId ?? id ?? this.menuId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      characteristic: characteristic ?? this.characteristic,
      price: price != null ? ((price is num) ? price.toDouble() : this.price) : this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      spiciness: spiciness ?? this.spiciness,
      stock: stock ?? this.stock,
      slotCapacity: slotCapacity ?? maxSlot ?? this.slotCapacity,
      minStock: minStock ?? minStockThreshold ?? this.minStock,
      isActive: isActive ?? this.isActive,
      variationGroups: variationGroups ?? this.variationGroups.map((g) => g.copyWith()).toList(),
    );
  }

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    final parsedId = (json['menu_id'] ?? json['id']) as int? ?? 0;
    final parsedCategoryId = (json['category_id'] ?? json['categoryId']) as int? ?? 0;
    final parsedPrice = json['price'];
    final doublePrice = (parsedPrice is num) ? parsedPrice.toDouble() : 0.0;

    return MenuModel(
      menuId: parsedId,
      categoryId: parsedCategoryId,
      categoryName: json['category_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      characteristic: json['characteristic'] as String? ?? '',
      price: doublePrice,
      imageUrl: json['image_url'] as String?,
      spiciness: json['spiciness'] as String? ?? 'Tidak Pedas',
      stock: (json['stock'] as int?) ?? 0,
      slotCapacity: (json['max_slot'] ?? json['slot_capacity']) as int? ?? 10,
      minStock: (json['min_stock_threshold'] ?? json['min_stock']) as int? ?? 2,
      isActive: json['is_active'] == null ? true : (json['is_active'] as bool),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': menuId,
      'menu_id': menuId,
      'category_id': categoryId,
      'category_name': categoryName,
      'name': name,
      'description': description,
      'characteristic': characteristic,
      'price': price,
      'image_url': imageUrl,
      'spiciness': spiciness,
      'stock': stock,
      'max_slot': slotCapacity,
      'slot_capacity': slotCapacity,
      'min_stock_threshold': minStock,
      'min_stock': minStock,
      'is_active': isActive,
    };
  }
}
