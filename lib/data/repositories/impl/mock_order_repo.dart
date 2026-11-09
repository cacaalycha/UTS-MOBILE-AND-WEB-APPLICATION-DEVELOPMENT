import '../../../models/order_model.dart';
import '../../mock/mock_orders.dart';
import '../order_repository.dart';

/// Penyimpanan pesanan berbasis memori (tanpa Firebase).
class MockOrderRepository implements OrderRepository {
  MockOrderRepository() {
    _orders.addAll(mockOrders);
  }

  final List<OrderModel> _orders = [];

  @override
  Future<List<OrderModel>> getOrders() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    final sorted = List<OrderModel>.from(_orders)
      ..sort((a, b) => b.orderDate.compareTo(a.orderDate));
    return sorted;
  }

  @override
  Future<OrderModel> createOrder(OrderModel order) async {
    _orders.insert(0, order);
    return order;
  }

  @override
  Future<OrderModel?> getOrderById(String id) async {
    for (final order in _orders) {
      if (order.id == id) return order;
    }
    return null;
  }

  @override
  Future<void> updateStatus(String orderId, OrderStatus status) async {
    final index = _orders.indexWhere((order) => order.id == orderId);
    if (index >= 0) {
      _orders[index] = _orders[index].copyWith(status: status);
    }
  }
}
