import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/impl/mock_auth_repo.dart';
import 'data/repositories/impl/mock_cart_repo.dart';
import 'data/repositories/impl/mock_order_repo.dart';
import 'data/repositories/impl/mock_product_repo.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'router/app_router.dart';

/// Akar aplikasi Case iPhone Caca.
///
/// CATATAN: seluruh repository masih memakai implementasi `Mock*`.
/// Ketika Firebase siap, ganti binding di [MultiProvider] dengan
/// `FirebaseAuthRepository`, `FirestoreProductRepository`, dst.
class CaseIphoneCacaApp extends StatefulWidget {
  const CaseIphoneCacaApp({super.key});

  @override
  State<CaseIphoneCacaApp> createState() => _CaseIphoneCacaAppState();
}

class _CaseIphoneCacaAppState extends State<CaseIphoneCacaApp> {
  late final MockAuthRepository _authRepo;
  late final MockProductRepository _productRepo;
  late final MockCartRepository _cartRepo;
  late final MockOrderRepository _orderRepo;

  late final AuthProvider _authProvider;
  late final ProductProvider _productProvider;
  late final CartProvider _cartProvider;
  late final OrderProvider _orderProvider;

  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authRepo = MockAuthRepository();
    _productRepo = MockProductRepository();
    _cartRepo = MockCartRepository();
    _orderRepo = MockOrderRepository();

    _authProvider = AuthProvider(_authRepo);
    _productProvider = ProductProvider(_productRepo);
    _cartProvider = CartProvider(_cartRepo);
    _orderProvider = OrderProvider(_orderRepo);

    _router = createRouter(_authProvider);

    // Muat data awal (mock).
    _productProvider.loadInitialData();
    _orderProvider.load();
    _cartProvider.load();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _productProvider),
        ChangeNotifierProvider.value(value: _cartProvider),
        ChangeNotifierProvider.value(value: _orderProvider),
      ],
      child: MaterialApp.router(
        title: 'Case iPhone Caca',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        routerConfig: _router,
      ),
    );
  }
}
