class MenuVariationOption {
  final int optionId;
  final int groupId;
  String name;
  double extraPrice;

  MenuVariationOption({
    required this.optionId,
    required this.groupId,
    required this.name,
    this.extraPrice = 0.0,
  });

  MenuVariationOption copyWith({
    int? optionId,
    int? groupId,
    String? name,
    double? extraPrice,
  }) {
    return MenuVariationOption(
      optionId: optionId ?? this.optionId,
      groupId: groupId ?? this.groupId,
      name: name ?? this.name,
      extraPrice: extraPrice ?? this.extraPrice,
    );
  }
}

class MenuVariationGroup {
  final int groupId;
  final int menuId;
  String name;
  bool isRequired;
  List<MenuVariationOption> options;

  MenuVariationGroup({
    required this.groupId,
    required this.menuId,
    required this.name,
    this.isRequired = false,
    List<MenuVariationOption>? options,
  }) : options = options ?? [];

  MenuVariationGroup copyWith({
    int? groupId,
    int? menuId,
    String? name,
    bool? isRequired,
    List<MenuVariationOption>? options,
  }) {
    return MenuVariationGroup(
      groupId: groupId ?? this.groupId,
      menuId: menuId ?? this.menuId,
      name: name ?? this.name,
      isRequired: isRequired ?? this.isRequired,
      options: options ?? this.options.map((o) => o.copyWith()).toList(),
    );
  }
}
