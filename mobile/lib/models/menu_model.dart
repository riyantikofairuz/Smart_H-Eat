class MenuModel {
  final int id;
  final int categoryId;
  final String categoryName;
  final String name;
  final String? description;
  final String? characteristic;
  final int price;
  final String? imageUrl;
  final int stock;
  final int maxSlot;
  final int minStockThreshold;
  final bool isActive;

  const MenuModel({
    required this.id,
    required this.categoryId,
    required this.categoryName,
    required this.name,
    this.description,
    this.characteristic,
    required this.price,
    this.imageUrl,
    required this.stock,
    this.maxSlot = 6,
    this.minStockThreshold = 5,
    this.isActive = true,
  });

  bool get isOutOfStock => stock <= 0;
  bool get isLowStock => stock > 0 && stock <= minStockThreshold;
  bool get isStockSafe => stock > minStockThreshold;

  String get formattedPrice {
    final valueStr = price.toString();
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

  MenuModel copyWith({
    int? id,
    int? categoryId,
    String? categoryName,
    String? name,
    String? description,
    String? characteristic,
    int? price,
    String? imageUrl,
    int? stock,
    int? maxSlot,
    int? minStockThreshold,
    bool? isActive,
  }) {
    return MenuModel(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      name: name ?? this.name,
      description: description ?? this.description,
      characteristic: characteristic ?? this.characteristic,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      stock: stock ?? this.stock,
      maxSlot: maxSlot ?? this.maxSlot,
      minStockThreshold: minStockThreshold ?? this.minStockThreshold,
      isActive: isActive ?? this.isActive,
    );
  }

  factory MenuModel.fromJson(Map<String, dynamic> json) {
    return MenuModel(
      id: json['id'] as int? ?? 0,
      categoryId: json['category_id'] as int? ?? 0,
      categoryName: json['category_name'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      characteristic: json['characteristic'] as String?,
      price: json['price'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
      stock: json['stock'] as int? ?? 0,
      maxSlot: json['max_slot'] as int? ?? 6,
      minStockThreshold: json['min_stock_threshold'] as int? ?? 5,
      isActive: json['is_active'] == null ? true : (json['is_active'] as bool),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'category_id': categoryId,
      'category_name': categoryName,
      'name': name,
      'description': description,
      'characteristic': characteristic,
      'price': price,
      'image_url': imageUrl,
      'stock': stock,
      'max_slot': maxSlot,
      'min_stock_threshold': minStockThreshold,
      'is_active': isActive,
    };
  }
}
