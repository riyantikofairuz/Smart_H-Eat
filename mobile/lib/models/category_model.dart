class CategoryModel {
  final int categoryId;
  String name;
  int order;
  bool isActive;

  CategoryModel({
    required this.categoryId,
    required this.name,
    this.order = 0,
    this.isActive = true,
  });

  CategoryModel copyWith({
    int? categoryId,
    String? name,
    int? order,
    bool? isActive,
  }) {
    return CategoryModel(
      categoryId: categoryId ?? this.categoryId,
      name: name ?? this.name,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }
}
