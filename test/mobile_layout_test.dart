import 'package:case_iphone_caca/core/theme/app_theme.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_cart_repo.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_product_repo.dart';
import 'package:case_iphone_caca/pages/catalog/detail_case_page.dart';
import 'package:case_iphone_caca/pages/catalog/katalog_page.dart';
import 'package:case_iphone_caca/pages/model/pilih_model_page.dart';
import 'package:case_iphone_caca/providers/cart_provider.dart';
import 'package:case_iphone_caca/providers/product_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

/// Memastikan tidak ada overflow pada lebar layar ponsel.
void main() {
  Future<ProductProvider> buildProviders(WidgetTester tester) async {
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
          home: Consumer<ProductProvider>(
            builder: (context, value, _) => const KatalogPage(),
          ),
        ),
      ),
    );

    products.loadInitialData();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    products.selectDevice(products.iphoneById('ip15'));
    await tester.pumpAndSettle(const Duration(seconds: 2));
    return products;
  }

  setUp(() {
    // Lebar khas ponsel.
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  testWidgets('Katalog tidak overflow di layar 390px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await buildProviders(tester);

    expect(tester.takeException(), isNull);
    expect(find.text('Katalog Case'), findsOneWidget);
  });

  testWidgets('Pilih Model tidak overflow di layar 390px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
          home: const PilihModelPage(),
        ),
      ),
    );

    products.loadInitialData();
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text('iPhone mana yang kamu pakai?'), findsOneWidget);
  });

  testWidgets('Detail Case tidak overflow di layar 390px', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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

    products.loadInitialData();
    await tester.pumpAndSettle(const Duration(seconds: 2));
    products.selectDevice(products.iphoneById('ip15'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(tester.takeException(), isNull);
    expect(find.text('Caca Clear Shield 15'), findsOneWidget);
  });
}
