import 'package:case_iphone_caca/data/mock/mock_cases.dart';
import 'package:case_iphone_caca/data/mock/mock_iphones.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_cart_repo.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_order_repo.dart';
import 'package:case_iphone_caca/models/order_model.dart';
import 'package:case_iphone_caca/providers/cart_provider.dart';
import 'package:case_iphone_caca/providers/order_provider.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CartProvider', () {
    late CartProvider cart;
    final device15 = mockIphones.firstWhere((m) => m.id == 'ip15');
    final device16 = mockIphones.firstWhere((m) => m.id == 'ip16');
    final caseFor15 = mockCases.firstWhere((c) => c.id == 'c016');
    final caseProMax = mockCases.firstWhere((c) => c.id == 'c001');

    setUp(() {
      cart = CartProvider(MockCartRepository());
    });

    test('menambah case kompatibel berhasil', () {
      final error = cart.addCase(caseItem: caseFor15, device: device15);

      expect(error, isNull);
      expect(cart.itemCount, 1);
      expect(cart.subtotal, caseFor15.price);
    });

    test('menolak case yang tidak kompatibel', () {
      final error = cart.addCase(caseItem: caseProMax, device: device16);

      expect(error, isNotNull);
      expect(cart.isEmpty, isTrue);
    });

    test('menolak case dengan stok habis', () {
      final outOfStock = mockCases.firstWhere((c) => c.stock == 0);
      final device = mockIphones.firstWhere(
        (m) => outOfStock.compatibleModelIds.contains(m.id),
      );

      final error = cart.addCase(caseItem: outOfStock, device: device);

      expect(error, isNotNull);
      expect(cart.isEmpty, isTrue);
    });

    test('menolak jumlah melebihi stok', () {
      final error = cart.addCase(
        caseItem: caseFor15,
        device: device15,
        quantity: caseFor15.stock + 1,
      );

      expect(error, isNotNull);
      expect(cart.isEmpty, isTrue);
    });

    test('ongkir flat hanya dihitung saat ada item', () {
      expect(cart.shippingCost, 0);

      cart.addCase(caseItem: caseFor15, device: device15);

      expect(cart.shippingCost, flatShippingCost);
      expect(cart.total, cart.subtotal + flatShippingCost);
    });

    test('menghapus item mengosongkan keranjang', () {
      cart.addCase(caseItem: caseFor15, device: device15);
      final item = cart.items.first;

      cart.removeItem(item);

      expect(cart.isEmpty, isTrue);
    });
  });

  group('OrderProvider', () {
    test('membuat pesanan menghitung total dengan benar', () async {
      final cart = CartProvider(MockCartRepository());
      final orders = OrderProvider(MockOrderRepository());
      await orders.load();

      final device = mockIphones.firstWhere((m) => m.id == 'ip15');
      final caseItem = mockCases.firstWhere((c) => c.id == 'c016');
      cart.addCase(caseItem: caseItem, device: device, quantity: 2);

      final order = await orders.createOrder(
        cartItems: cart.items,
        shippingCost: cart.shippingCost,
        customerName: 'Alysha',
        customerPhone: '081234567890',
        shippingAddress: 'Jl. Melati No. 12, Bandung',
        paymentMethod: 'Transfer Manual',
      );

      expect(order.status, OrderStatus.diproses);
      expect(order.items.single.quantity, 2);
      expect(order.subtotal, caseItem.price * 2);
      expect(order.total, order.subtotal + flatShippingCost);
      expect(orders.orderById(order.id), isNotNull);
    });

    test('pesanan baru muncul di daftar', () async {
      final orders = OrderProvider(MockOrderRepository());
      await orders.load();
      final before = orders.orders.length;

      final cart = CartProvider(MockCartRepository());
      final device = mockIphones.firstWhere((m) => m.id == 'ip15');
      final caseItem = mockCases.firstWhere((c) => c.id == 'c016');
      cart.addCase(caseItem: caseItem, device: device);

      await orders.createOrder(
        cartItems: cart.items,
        shippingCost: cart.shippingCost,
        customerName: 'Alysha',
        customerPhone: '081234567890',
        shippingAddress: 'Bandung',
        paymentMethod: 'COD',
      );

      expect(orders.orders.length, before + 1);
    });

    test('filter status memisahkan pesanan diproses dan selesai', () async {
      final orders = OrderProvider(MockOrderRepository());
      await orders.load();

      final diproses = orders.byStatus(OrderStatus.diproses);
      final selesai = orders.byStatus(OrderStatus.selesai);

      expect(diproses, isNotEmpty);
      expect(selesai, isNotEmpty);
      expect(diproses.every((o) => o.status == OrderStatus.diproses), isTrue);
      expect(selesai.every((o) => o.status == OrderStatus.selesai), isTrue);
    });
  });
}
