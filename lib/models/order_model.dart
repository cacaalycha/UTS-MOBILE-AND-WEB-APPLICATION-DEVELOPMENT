/// Status pesanan.
enum OrderStatus {
  diproses('Diproses'),
  selesai('Selesai'),
  dibatalkan('Dibatalkan');

  const OrderStatus(this.label);

  final String label;

  static OrderStatus fromName(String name) {
    return OrderStatus.values.firstWhere(
      (status) => status.name == name,
      orElse: () => OrderStatus.diproses,
    );
  }
}

/// Satu baris item di dalam pesanan.
class OrderItem {
  const OrderItem({
    required this.caseId,
    required this.caseName,
    required this.price,
    required this.quantity,
    required this.forIphoneModelName,
    this.imageUrl,
  });

  final String caseId;
  final String caseName;
  final double price;
  final int quantity;
  final String forIphoneModelName;
  final String? imageUrl;

  double get lineTotal => price * quantity;

  Map<String, dynamic> toMap() => {
    'caseId': caseId,
    'caseName': caseName,
    'price': price,
    'quantity': quantity,
    'forIphoneModelName': forIphoneModelName,
    'imageUrl': imageUrl,
  };

  factory OrderItem.fromMap(Map<String, dynamic> map) => OrderItem(
    caseId: map['caseId'] as String,
    caseName: map['caseName'] as String,
    price: (map['price'] as num).toDouble(),
    quantity: map['quantity'] as int,
    forIphoneModelName: map['forIphoneModelName'] as String,
    imageUrl: map['imageUrl'] as String?,
  );
}

/// Pesanan hasil checkout simulasi.
class OrderModel {
  const OrderModel({
    required this.id,
    required this.orderDate,
    required this.items,
    required this.subtotal,
    required this.shippingCost,
    required this.total,
    required this.status,
    required this.customerName,
    required this.customerPhone,
    required this.shippingAddress,
    required this.paymentMethod,
    this.note = '',
  });

  final String id;
  final DateTime orderDate;
  final List<OrderItem> items;
  final double subtotal;

  /// Tarif pengiriman tetap (flat rate) sesuai batasan proyek Minggu 1.
  final double shippingCost;
  final double total;
  final OrderStatus status;
  final String customerName;
  final String customerPhone;
  final String shippingAddress;

  /// Metode bayar simulasi: "Transfer Manual" / "COD".
  final String paymentMethod;
  final String note;

  int get totalQuantity =>
      items.fold(0, (sum, item) => sum + item.quantity);

  OrderModel copyWith({OrderStatus? status}) => OrderModel(
    id: id,
    orderDate: orderDate,
    items: items,
    subtotal: subtotal,
    shippingCost: shippingCost,
    total: total,
    status: status ?? this.status,
    customerName: customerName,
    customerPhone: customerPhone,
    shippingAddress: shippingAddress,
    paymentMethod: paymentMethod,
    note: note,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'orderDate': orderDate.toIso8601String(),
    'items': items.map((item) => item.toMap()).toList(),
    'subtotal': subtotal,
    'shippingCost': shippingCost,
    'total': total,
    'status': status.name,
    'customerName': customerName,
    'customerPhone': customerPhone,
    'shippingAddress': shippingAddress,
    'paymentMethod': paymentMethod,
    'note': note,
  };

  factory OrderModel.fromMap(Map<String, dynamic> map) => OrderModel(
    id: map['id'] as String,
    orderDate: DateTime.parse(map['orderDate'] as String),
    items: (map['items'] as List)
        .map((item) => OrderItem.fromMap(Map<String, dynamic>.from(item as Map)))
        .toList(),
    subtotal: (map['subtotal'] as num).toDouble(),
    shippingCost: (map['shippingCost'] as num).toDouble(),
    total: (map['total'] as num).toDouble(),
    status: OrderStatus.fromName(map['status'] as String),
    customerName: map['customerName'] as String,
    customerPhone: map['customerPhone'] as String,
    shippingAddress: map['shippingAddress'] as String,
    paymentMethod: map['paymentMethod'] as String,
    note: (map['note'] as String?) ?? '',
  );
}
