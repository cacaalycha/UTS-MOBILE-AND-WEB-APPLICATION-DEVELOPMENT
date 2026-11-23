import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'data/repositories/impl/firebase_auth_repo.dart';
import 'data/repositories/impl/mock_cart_repo.dart';
import 'data/repositories/impl/mock_order_repo.dart';
import 'data/repositories/impl/mock_product_repo.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/order_provider.dart';
import 'providers/product_provider.dart';
import 'router/app_router.dart';
import 'services/firestore_status.dart';
import 'services/layanan_data.dart';
import 'services/layanan_firestore.dart';

/// Aplikasi katalog UTS yang dibuka **setelah login Firebase berhasil**.
///
/// Mulai Minggu 10 aplikasi ini juga menyediakan [LayananData] (implementasi
/// [LayananFirestore]) ke seluruh halaman lewat Provider. Saat `initState`,
/// dokumen `users/{uid}` dibuat bila belum ada dan collection `cases` diisi
/// otomatis bila masih kosong (auto-seed). Kegagalan — misalnya database
/// Firestore belum dibuat di Console — ditangkap dan ditampilkan sebagai
/// banner, bukan crash.
class FirebaseKatalogApp extends StatefulWidget {
  const FirebaseKatalogApp({
    super.key,
    this.onKeluar,
    this.namaPendaftaran,
  });

  final Future<void> Function()? onKeluar;

  /// Nama lengkap dari form Daftar; dipakai untuk dokumen `users/{uid}`.
  final String? namaPendaftaran;

  @override
  State<FirebaseKatalogApp> createState() => _FirebaseKatalogAppState();
}

class _FirebaseKatalogAppState extends State<FirebaseKatalogApp> {
  late final FirebaseAuthRepository _authRepo;
  late final MockProductRepository _productRepo;
  late final MockCartRepository _cartRepo;
  late final MockOrderRepository _orderRepo;

  late final AuthProvider _authProvider;
  late final ProductProvider _productProvider;
  late final CartProvider _cartProvider;
  late final OrderProvider _orderProvider;

  late final LayananData _layananMinggu10;
  late final FirestoreStatus _statusFirestore;
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();

    _authRepo = FirebaseAuthRepository(onKeluar: widget.onKeluar);
    _productRepo = MockProductRepository();
    _cartRepo = MockCartRepository();
    _orderRepo = MockOrderRepository();

    _authProvider = AuthProvider(_authRepo);
    _productProvider = ProductProvider(_productRepo);
    _cartProvider = CartProvider(_cartRepo);
    _orderProvider = OrderProvider(_orderRepo);

    _layananMinggu10 = LayananFirestore();
    _statusFirestore = FirestoreStatus();

    _router = createRouter(
      _authProvider,
      // Admin (FIREBASE_ADMIN_EMAILS) langsung ke panel admin;
      // pembeli tetap ke Beranda katalog.
      initialLocation: _authProvider.isAdmin ? '/admin' : '/beranda',
      firebaseMode: true,
      layananMinggu10: _layananMinggu10,
      statusMinggu10: _statusFirestore,
    );

    _productProvider.loadInitialData();
    _orderProvider.load();
    _cartProvider.load();
    _siapkanFirestore();
  }

  /// Latihan 2A + 2B: profil pengguna & auto-seed master case.
  Future<void> _siapkanFirestore() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    _statusFirestore.mulai();
    try {
      final nama = (widget.namaPendaftaran ?? '').trim().isNotEmpty
          ? widget.namaPendaftaran!.trim()
          : user.displayName;
      await _layananMinggu10.simpanPenggunaSaatLogin(
        uid: user.uid,
        email: user.email ?? '',
        namaLengkap: nama,
      );
      await _layananMinggu10.isiCaseAwalJikaKosong();
      _statusFirestore.berhasil();
    } catch (kesalahan) {
      _statusFirestore.gagal(kesalahan);
    }
  }

  @override
  void dispose() {
    _layananMinggu10.dispose();
    _statusFirestore.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _productProvider),
        ChangeNotifierProvider.value(value: _cartProvider),
        ChangeNotifierProvider.value(value: _orderProvider),
        Provider<LayananData>.value(value: _layananMinggu10),
        ChangeNotifierProvider<FirestoreStatus>.value(
          value: _statusFirestore,
        ),
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
