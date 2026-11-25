class OrderItemVariationModel {
  final int orderItemVariationId;
  final int orderItemId;
  final String groupName;
  final String optionName;
  final double extraPrice;

  OrderItemVariationModel({
    required this.orderItemVariationId,
    required this.orderItemId,
    required this.groupName,
    required this.optionName,
    this.extraPrice = 0.0,
  });
}

class OrderItemModel {
  final int orderItemId;
  final int orderId;
  final int menuId;
  final String menuName;
  final double price;
  final int qty;
  final double subtotal;
  final List<OrderItemVariationModel> variations;

  OrderItemModel({
    required this.orderItemId,
    required this.orderId,
    required this.menuId,
    required this.menuName,
    required this.price,
    required this.qty,
    required this.subtotal,
    List<OrderItemVariationModel>? variations,
  }) : variations = variations ?? [];
}

class OrderModel {
  final int orderId;
  final String orderCode;
  final String queueNumber;
  final double totalAmount;
  String status; // 'menunggu_pembayaran', 'dibayar', 'diproses', 'siap_diambil', 'selesai', 'dibatalkan', 'kedaluwarsa'
  final DateTime paidAt;
  final DateTime? expiredAt;
  final List<OrderItemModel> items;

  OrderModel({
    required this.orderId,
    required this.orderCode,
    required this.queueNumber,
    required this.totalAmount,
    required this.status,
    required this.paidAt,
    this.expiredAt,
    List<OrderItemModel>? items,
  }) : items = items ?? [];

  OrderModel copyWith({
    int? orderId,
    String? orderCode,
    String? queueNumber,
    double? totalAmount,
    String? status,
    DateTime? paidAt,
    DateTime? expiredAt,
    List<OrderItemModel>? items,
  }) {
    return OrderModel(
      orderId: orderId ?? this.orderId,
      orderCode: orderCode ?? this.orderCode,
      queueNumber: queueNumber ?? this.queueNumber,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      paidAt: paidAt ?? this.paidAt,
      expiredAt: expiredAt ?? this.expiredAt,
      items: items ?? this.items,
    );
  }
}
