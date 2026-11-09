import 'package:go_router/go_router.dart';

import '../pages/admin/admin_dashboard_page.dart';
import '../pages/admin/admin_product_form_page.dart';
import '../pages/admin/admin_products_page.dart';
import '../pages/auth/login_page.dart';
import '../pages/auth/register_page.dart';
import '../pages/cart/checkout_page.dart';
import '../pages/cart/keranjang_page.dart';
import '../pages/catalog/detail_case_page.dart';
import '../pages/catalog/katalog_page.dart';
import '../pages/home/beranda_page.dart';
import '../pages/model/pilih_model_page.dart';
import '../pages/order/detail_pesanan_page.dart';
import '../pages/order/konfirmasi_page.dart';
import '../pages/order/pesanan_saya_page.dart';
import '../providers/auth_provider.dart';
import '../widgets/layouts/app_shell.dart';

/// Membuat konfigurasi routing aplikasi.
///
/// [auth] dipakai sebagai `refreshListenable` agar redirect otomatis
/// dijalankan ulang saat status login berubah.
GoRouter createRouter(
  AuthProvider auth, {
  String initialLocation = '/login',
}) {
  return GoRouter(
    initialLocation: initialLocation,
    refreshListenable: auth,
    redirect: (context, state) {
      final location = state.matchedLocation;
      final isAuthPage = location == '/login' || location == '/register';

      // Belum login → hanya boleh di halaman auth.
      if (!auth.isLoggedIn) {
        return isAuthPage ? null : '/login';
      }

      // Sudah login tapi masih di halaman auth → arahkan ke beranda peran.
      if (isAuthPage) {
        return auth.isAdmin ? '/admin' : '/beranda';
      }

      // Penjaga peran: admin tidak masuk halaman pembeli utama.
      const buyerRoots = ['/beranda', '/katalog', '/keranjang', '/pesanan'];
      if (auth.isAdmin) {
        final isBuyerRoot = buyerRoots.any(
          (root) => location == root || location.startsWith('$root/detail'),
        );
        if (isBuyerRoot || location == '/pilih-model' || location == '/checkout') {
          return '/admin';
        }
        return null;
      }

      // Pembeli tidak boleh masuk area admin.
      if (location.startsWith('/admin')) {
        return '/beranda';
      }

      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterPage(),
      ),

      // ===== Shell pembeli =====
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/beranda',
                builder: (context, state) => const BerandaPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/katalog',
                builder: (context, state) => const KatalogPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/keranjang',
                builder: (context, state) => const KeranjangPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/pesanan',
                builder: (context, state) => const PesananSayaPage(),
              ),
            ],
          ),
        ],
      ),

      // ===== Shell admin =====
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin',
                builder: (context, state) => const AdminDashboardPage(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/admin/produk',
                builder: (context, state) => const AdminProductsPage(),
              ),
            ],
          ),
        ],
      ),

      // ===== Halaman di luar shell =====
      GoRoute(
        path: '/pilih-model',
        builder: (context, state) => const PilihModelPage(),
      ),
      GoRoute(
        path: '/katalog/detail/:id',
        builder: (context, state) =>
            DetailCasePage(caseId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/checkout',
        builder: (context, state) => const CheckoutPage(),
      ),
      GoRoute(
        path: '/konfirmasi/:orderId',
        builder: (context, state) =>
            KonfirmasiPage(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/pesanan/:orderId',
        builder: (context, state) =>
            DetailPesananPage(orderId: state.pathParameters['orderId']!),
      ),
      GoRoute(
        path: '/admin/produk/form',
        builder: (context, state) =>
            AdminProductFormPage(caseId: state.uri.queryParameters['id']),
      ),
    ],
  );
}
