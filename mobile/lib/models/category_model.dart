class CategoryModel {
  final int categoryId;
  String name;
  int order;
  bool isActive;

  int get id => categoryId;

  CategoryModel({
    int? id,
    int? categoryId,
    required this.name,
    this.order = 0,
    this.isActive = true,
  }) : categoryId = categoryId ?? id ?? 0;

  CategoryModel copyWith({
    int? categoryId,
    int? id,
    String? name,
    int? order,
    bool? isActive,
  }) {
    return CategoryModel(
      categoryId: categoryId ?? id ?? this.categoryId,
      name: name ?? this.name,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    final parsedId = (json['category_id'] ?? json['id']) as int? ?? 0;
    return CategoryModel(
      categoryId: parsedId,
      name: json['name'] as String? ?? '',
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': categoryId,
      'category_id': categoryId,
      'name': name,
      'order': order,
      'is_active': isActive,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModel &&
          runtimeType == other.runtimeType &&
          categoryId == other.categoryId;

  @override
  int get hashCode => categoryId.hashCode;
}
