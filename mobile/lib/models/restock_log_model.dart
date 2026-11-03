class RestockLogModel {
  final int restockLogId;
  final int menuId;
  final String menuName;
  final int operatorId;
  final String operatorName;
  final int qtyAdded;
  final int stockBefore;
  final int stockAfter;
  final String note;
  final DateTime createdAt;

  RestockLogModel({
    required this.restockLogId,
    required this.menuId,
    required this.menuName,
    required this.operatorId,
    required this.operatorName,
    required this.qtyAdded,
    required this.stockBefore,
    required this.stockAfter,
    this.note = 'Restock rutin',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();
}
