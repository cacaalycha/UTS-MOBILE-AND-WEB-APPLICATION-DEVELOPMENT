import 'package:flutter/foundation.dart';

import '../data/repositories/order_repository.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

/// State pesanan pengguna.
class OrderProvider extends ChangeNotifier {
  OrderProvider(this._repository);

  final OrderRepository _repository;

  List<OrderModel> _orders = [];
  bool _isLoading = false;
  OrderModel? _lastCreatedOrder;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  bool get isLoading => _isLoading;
  OrderModel? get lastCreatedOrder => _lastCreatedOrder;

  Future<void> load() async {
    _isLoading = true;
    notifyListeners();

    _orders = await _repository.getOrders();

    _isLoading = false;
    notifyListeners();
  }

  List<OrderModel> byStatus(OrderStatus? status) {
    if (status == null) return orders;
    return _orders.where((order) => order.status == status).toList();
  }

  /// Membuat pesanan baru dari isi keranjang.
  Future<OrderModel> createOrder({
    required List<CartItemModel> cartItems,
    required double shippingCost,
    required String customerName,
    required String customerPhone,
    required String shippingAddress,
    required String paymentMethod,
    String note = '',
  }) async {
    final items = cartItems
        .map(
          (item) => OrderItem(
            caseId: item.caseItem.id,
            caseName: item.caseItem.name,
            price: item.caseItem.price,
            quantity: item.quantity,
            forIphoneModelName: item.forIphoneModelName,
            imageUrl: item.caseItem.imageUrl,
          ),
        )
        .toList();

    final subtotal = items.fold(0.0, (sum, item) => sum + item.lineTotal);
    final now = DateTime.now();

    final order = OrderModel(
      id: _generateOrderId(now),
      orderDate: now,
      items: items,
      subtotal: subtotal,
      shippingCost: shippingCost,
      total: subtotal + shippingCost,
      status: OrderStatus.diproses,
      customerName: customerName,
      customerPhone: customerPhone,
      shippingAddress: shippingAddress,
      paymentMethod: paymentMethod,
      note: note,
    );

    final saved = await _repository.createOrder(order);
    _orders = await _repository.getOrders();
    _lastCreatedOrder = saved;
    notifyListeners();
    return saved;
  }

  OrderModel? orderById(String id) {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  Future<void> updateStatus(String orderId, OrderStatus status) async {
    await _repository.updateStatus(orderId, status);
    _orders = await _repository.getOrders();
    notifyListeners();
  }

  String _generateOrderId(DateTime now) {
    String two(int value) => value.toString().padLeft(2, '0');
    final date =
        '${now.year}${two(now.month)}${two(now.day)}';
    final sequence = (_orders.length + 1).toString().padLeft(3, '0');
    return 'ORD-$date-$sequence';
  }
}
