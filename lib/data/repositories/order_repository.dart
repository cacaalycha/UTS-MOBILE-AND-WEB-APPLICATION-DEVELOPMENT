import '../../models/order_model.dart';

/// Kontrak penyimpanan pesanan.
abstract class OrderRepository {
  Future<List<OrderModel>> getOrders();

  Future<OrderModel> createOrder(OrderModel order);

  Future<OrderModel?> getOrderById(String id);

  Future<void> updateStatus(String orderId, OrderStatus status);
}
