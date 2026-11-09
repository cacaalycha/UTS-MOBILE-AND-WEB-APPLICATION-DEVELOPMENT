import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../providers/auth_provider.dart';
import '../../providers/order_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/buttons.dart';
import '../../widgets/components/section_header.dart';

/// Halaman Dashboard Admin.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final orders = context.watch<OrderProvider>();
    final auth = context.watch<AuthProvider>();
    final isWide = MediaQuery.sizeOf(context).width >= 700;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Admin'),
        actions: [
          IconButton(
            onPressed: () => _confirmLogout(context),
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Keluar',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Halo, ${auth.user?.name ?? 'Admin'}',
                    style: AppTypography.title.copyWith(fontSize: 28),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Ringkasan katalog dan pesanan toko.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 900
                          ? 4
                          : constraints.maxWidth >= 560
                          ? 2
                          : 1;
                      final cards = [
                        _StatCard(
                          label: 'Total produk',
                          value: '${products.totalProducts}',
                          icon: Icons.inventory_2_outlined,
                          color: AppColors.primaryDark,
                        ),
                        _StatCard(
                          label: 'Total stok',
                          value: '${products.totalStock}',
                          icon: Icons.warehouse_outlined,
                          color: AppColors.success,
                        ),
                        _StatCard(
                          label: 'Stok menipis',
                          value: '${products.lowStockCount}',
                          icon: Icons.warning_amber_rounded,
                          color: AppColors.pending,
                        ),
                        _StatCard(
                          label: 'Stok habis',
                          value: '${products.outOfStockCount}',
                          icon: Icons.remove_shopping_cart_outlined,
                          color: AppColors.error,
                        ),
                      ];
                      final width = columns == 1
                          ? constraints.maxWidth
                          : (constraints.maxWidth -
                                    AppSpacing.sm * (columns - 1)) /
                                columns;
                      return Wrap(
                        spacing: AppSpacing.sm,
                        runSpacing: AppSpacing.sm,
                        children: [
                          for (final card in cards)
                            SizedBox(width: width, child: card),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SectionHeader(
                    title: 'Pesanan terbaru',
                    subtitle: '${orders.orders.length} pesanan tercatat',
                    actionLabel: 'Kelola produk',
                    onAction: () => context.go('/admin/produk'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  if (orders.orders.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(
                          AppSpacing.radiusMd,
                        ),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Belum ada pesanan masuk.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    )
                  else
                    for (final order in orders.orders.take(5))
                      Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          decoration: BoxDecoration(
                            color: AppColors.surface,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusMd,
                            ),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      order.id,
                                      style: AppTypography.caption.copyWith(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Text(
                                      '${order.customerName} · '
                                      '${order.totalQuantity} item',
                                      style: AppTypography.caption.copyWith(
                                        fontSize: 14,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (isWide)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    right: AppSpacing.sm,
                                  ),
                                  child: Text(
                                    order.status.label,
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              IconButton(
                                onPressed: () =>
                                    context.push('/pesanan/${order.id}'),
                                icon: const Icon(
                                  Icons.visibility_outlined,
                                  size: 20,
                                ),
                                tooltip: 'Lihat detail',
                              ),
                            ],
                          ),
                        ),
                      ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Tambah Produk Baru',
                    icon: Icons.add_rounded,
                    onPressed: () => context.push('/admin/produk/form'),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Panel admin ini memakai data mock. Setelah Firebase aktif, '
                    'CRUD produk akan menulis ke koleksi Firestore.',
                    style: AppTypography.caption.copyWith(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Keluar akun?'),
        content: const Text('Kamu akan kembali ke halaman login.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
      if (context.mounted) context.go('/login');
    }
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: AppTypography.title.copyWith(fontSize: 28),
          ),
          Text(
            label,
            style: AppTypography.caption.copyWith(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
