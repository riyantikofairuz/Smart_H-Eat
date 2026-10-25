import 'variation_model.dart';

class MenuModel {
  final int menuId;
  int categoryId;
  String name;
  String description;
  double price;
  String? imageUrl;
  String spiciness; // 'Tidak Pedas', 'Sedang', 'Pedas'
  int stock;
  int slotCapacity;
  int minStock;
  bool isActive;
  List<MenuVariationGroup> variationGroups;

  MenuModel({
    required this.menuId,
    required this.categoryId,
    required this.name,
    this.description = '',
    required this.price,
    this.imageUrl,
    this.spiciness = 'Tidak Pedas',
    this.stock = 10,
    this.slotCapacity = 10,
    this.minStock = 2,
    this.isActive = true,
    List<MenuVariationGroup>? variationGroups,
  }) : variationGroups = variationGroups ?? [];

  MenuModel copyWith({
    int? menuId,
    int? categoryId,
    String? name,
    String? description,
    double? price,
    String? imageUrl,
    String? spiciness,
    int? stock,
    int? slotCapacity,
    int? minStock,
    bool? isActive,
    List<MenuVariationGroup>? variationGroups,
  }) {
    return MenuModel(
      menuId: menuId ?? this.menuId,
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      imageUrl: imageUrl ?? this.imageUrl,
      spiciness: spiciness ?? this.spiciness,
      stock: stock ?? this.stock,
      slotCapacity: slotCapacity ?? this.slotCapacity,
      minStock: minStock ?? this.minStock,
      isActive: isActive ?? this.isActive,
      variationGroups: variationGroups ?? this.variationGroups.map((g) => g.copyWith()).toList(),
    );
  }
}
