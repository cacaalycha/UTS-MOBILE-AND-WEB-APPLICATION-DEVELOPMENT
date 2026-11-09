import '../../models/order_model.dart';

/// Pesanan mock agar halaman "Pesanan Saya" tidak kosong saat demo.
final List<OrderModel> mockOrders = [
  OrderModel(
    id: 'ORD-20261015-001',
    orderDate: DateTime(2026, 10, 15, 10, 24),
    items: const [
      OrderItem(
        caseId: 'c001',
        caseName: 'Caca Clear Shield Pro Max',
        price: 89000,
        quantity: 1,
        forIphoneModelName: 'iPhone 15 Pro Max',
      ),
      OrderItem(
        caseId: 'c013',
        caseName: 'Caca MagSafe Clear 16',
        price: 139000,
        quantity: 1,
        forIphoneModelName: 'iPhone 16',
      ),
    ],
    subtotal: 228000,
    shippingCost: 15000,
    total: 243000,
    status: OrderStatus.selesai,
    customerName: 'Alysha Syafiya',
    customerPhone: '081234567890',
    shippingAddress: 'Jl. Melati No. 12, Bandung, Jawa Barat',
    paymentMethod: 'Transfer Manual',
  ),
  OrderModel(
    id: 'ORD-20261022-002',
    orderDate: DateTime(2026, 10, 22, 15, 5),
    items: const [
      OrderItem(
        caseId: 'c002',
        caseName: 'Caca Armor Shockproof Pro Max',
        price: 129000,
        quantity: 2,
        forIphoneModelName: 'iPhone 14 Pro Max',
      ),
    ],
    subtotal: 258000,
    shippingCost: 15000,
    total: 273000,
    status: OrderStatus.diproses,
    customerName: 'Alysha Syafiya',
    customerPhone: '081234567890',
    shippingAddress: 'Jl. Melati No. 12, Bandung, Jawa Barat',
    paymentMethod: 'COD',
    note: 'Tolong dibungkus bubble wrap tambahan.',
  ),
  OrderModel(
    id: 'ORD-20261028-003',
    orderDate: DateTime(2026, 10, 28, 9, 40),
    items: const [
      OrderItem(
        caseId: 'c024',
        caseName: 'Caca Universal Slim Clear',
        price: 65000,
        quantity: 1,
        forIphoneModelName: 'iPhone 13',
      ),
    ],
    subtotal: 65000,
    shippingCost: 15000,
    total: 80000,
    status: OrderStatus.diproses,
    customerName: 'Alysha Syafiya',
    customerPhone: '081234567890',
    shippingAddress: 'Jl. Melati No. 12, Bandung, Jawa Barat',
    paymentMethod: 'Transfer Manual',
  ),
];
