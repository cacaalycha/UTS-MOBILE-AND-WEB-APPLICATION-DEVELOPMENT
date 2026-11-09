import 'package:case_iphone_caca/core/theme/app_theme.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_cart_repo.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_product_repo.dart';
import 'package:case_iphone_caca/pages/catalog/detail_case_page.dart';
import 'package:case_iphone_caca/providers/cart_provider.dart';
import 'package:case_iphone_caca/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

void main() {
  testWidgets('halaman detail case menampilkan produk dan status kompatibel',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final products = ProductProvider(MockProductRepository());
    final cart = CartProvider(MockCartRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: products),
          ChangeNotifierProvider.value(value: cart),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DetailCasePage(caseId: 'c016'),
        ),
      ),
    );

    // Muat data di dalam zona fake-async test (bukan await di luar pump).
    products.loadInitialData();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    products.selectDevice(products.iphoneById('ip15'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text('Caca Clear Shield 15'), findsOneWidget);
    expect(find.textContaining('Kompatibel dengan'), findsOneWidget);
    expect(find.text('Tambah ke Keranjang'), findsOneWidget);
    expect(find.text('Model yang kompatibel'), findsOneWidget);
  });

  testWidgets('case tidak kompatibel menonaktifkan tombol keranjang',
      (tester) async {
    tester.view.physicalSize = const Size(1400, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final products = ProductProvider(MockProductRepository());
    final cart = CartProvider(MockCartRepository());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: products),
          ChangeNotifierProvider.value(value: cart),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          home: const DetailCasePage(caseId: 'c001'),
        ),
      ),
    );

    products.loadInitialData();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    // iPhone 15 tidak kompatibel dengan case Pro Max (c001).
    products.selectDevice(products.iphoneById('ip15'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.textContaining('Tidak kompatibel dengan'), findsOneWidget);
    expect(find.text('Tidak kompatibel'), findsOneWidget);
  });
}
