import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/badges.dart';
import '../../widgets/components/empty_state.dart';
import '../../widgets/components/section_header.dart';

/// Halaman daftar produk untuk admin (CRUD).
class AdminProductsPage extends StatefulWidget {
  const AdminProductsPage({super.key});

  @override
  State<AdminProductsPage> createState() => _AdminProductsPageState();
}

class _AdminProductsPageState extends State<AdminProductsPage> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final q = _query.trim().toLowerCase();
    final items = q.isEmpty
        ? products.allCases
        : products.allCases
              .where(
                (item) =>
                    item.name.toLowerCase().contains(q) ||
                    item.brand.toLowerCase().contains(q),
              )
              .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Kelola Produk'),
        actions: [
          IconButton(
            onPressed: () => context.push('/admin/produk/form'),
            icon: const Icon(Icons.add_rounded),
            tooltip: 'Tambah produk',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: SearchField(
                    hintText: 'Cari produk atau brand',
                    onChanged: (value) => setState(() => _query = value),
                    onClear: _query.isEmpty
                        ? null
                        : () => setState(() => _query = ''),
                  ),
                ),
                Expanded(
                  child: items.isEmpty
                      ? const EmptyState(
                          title: 'Produk tidak ditemukan',
                          message: 'Coba kata kunci lain atau tambah produk baru.',
                          icon: Icons.inventory_2_outlined,
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.fromLTRB(
                            AppSpacing.md,
                            0,
                            AppSpacing.md,
                            AppSpacing.md,
                          ),
                          itemCount: items.length + 1,
                          separatorBuilder: (_, _) =>
                              const SizedBox(height: AppSpacing.xs),
                          itemBuilder: (context, index) {
                            if (index == items.length) {
                              return Padding(
                                padding: const EdgeInsets.only(
                                  top: AppSpacing.sm,
                                ),
                                child: Text(
                                  '${items.length} produk · '
                                  'total stok ${products.totalStock} unit',
                                  style: AppTypography.caption.copyWith(
                                    fontSize: 14,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              );
                            }
                            final item = items[index];
                            return Container(
                              padding: const EdgeInsets.all(AppSpacing.xs),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(
                                  AppSpacing.radiusMd,
                                ),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 60,
                                    height: 60,
                                    decoration: BoxDecoration(
                                      color: AppColors.placeholder,
                                      borderRadius: BorderRadius.circular(
                                        AppSpacing.radiusSm,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.phone_iphone_rounded,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.xs),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.name,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption.copyWith(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 16,
                                          ),
                                        ),
                                        Text(
                                          '${item.brand} · ${item.material} · '
                                          '${item.compatibleModelIds.length} model',
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: AppTypography.caption.copyWith(
                                            fontSize: 14,
                                            color: AppColors.textSecondary,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Wrap(
                                          spacing: 6,
                                          runSpacing: 4,
                                          children: [
                                            StockBadge(stock: item.stock),
                                            FeatureChip(
                                              label: formatRupiah(item.price),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => context.push(
                                      '/admin/produk/form?id=${item.id}',
                                    ),
                                    icon: const Icon(Icons.edit_outlined),
                                    tooltip: 'Ubah',
                                  ),
                                  IconButton(
                                    onPressed: () => _confirmDelete(
                                      context,
                                      item.id,
                                      item.name,
                                    ),
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                    ),
                                    color: AppColors.error,
                                    tooltip: 'Hapus',
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    String id,
    String name,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus produk?'),
        content: Text('"$name" akan dihapus dari katalog.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<ProductProvider>().deleteCase(id);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$name dihapus.')),
        );
      }
    }
  }
}
