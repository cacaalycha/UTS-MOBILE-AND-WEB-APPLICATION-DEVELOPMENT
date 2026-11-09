import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../models/case_model.dart';
import '../../models/iphone_model.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/badges.dart';
import '../../widgets/components/buttons.dart';
import '../../widgets/components/empty_state.dart';
import '../../widgets/components/section_header.dart';

/// Halaman Detail Case (H5).
class DetailCasePage extends StatefulWidget {
  const DetailCasePage({super.key, required this.caseId});

  final String caseId;

  @override
  State<DetailCasePage> createState() => _DetailCasePageState();
}

class _DetailCasePageState extends State<DetailCasePage> {
  int _quantity = 1;

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final caseItem = products.caseById(widget.caseId);

    if (caseItem == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Case')),
        body: const EmptyState(
          title: 'Case tidak ditemukan',
          message: 'Produk mungkin sudah dihapus dari katalog.',
          icon: Icons.inventory_2_outlined,
        ),
      );
    }

    final device = products.selectedDevice;
    final compatible = device == null ? null : caseItem.isCompatibleWith(device);
    final isWide = MediaQuery.sizeOf(context).width >= 900;
    final compatibleDevices = products.iphones
        .where((model) => caseItem.isCompatibleWith(model))
        .toList();

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          caseItem.name,
          style: AppTypography.title.copyWith(fontSize: isWide ? 30 : 26),
        ),
        const SizedBox(height: 4),
        Text(
          '${caseItem.brand} · ${caseItem.material}',
          style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
        ),
        const SizedBox(height: AppSpacing.xs),
        Row(
          children: [
            const Icon(
              Icons.star_rounded,
              size: 20,
              color: AppColors.pending,
            ),
            const SizedBox(width: 4),
            Text(
              caseItem.rating.toStringAsFixed(1),
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            StockBadge(stock: caseItem.stock),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          formatRupiah(caseItem.price),
          style: AppTypography.title.copyWith(
            fontSize: 30,
            color: AppColors.primaryDark,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        if (caseItem.description.isNotEmpty) ...[
          Text(
            caseItem.description,
            style: AppTypography.caption.copyWith(
              color: AppColors.textPrimary,
              height: 1.55,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
        ],

        // ===== Status kompatibilitas =====
        _CompatibilityPanel(
          device: device,
          compatible: compatible,
          caseItem: caseItem,
          onPickDevice: () => context.go('/pilih-model'),
        ),
        const SizedBox(height: AppSpacing.md),

        // ===== Spesifikasi =====
        SectionHeader(title: 'Spesifikasi'),
        const SizedBox(height: AppSpacing.xs),
        _specRow('Material', caseItem.material),
        _specRow('Kategori', caseItem.category),
        _specRow(
          'Cutout kamera',
          caseItem.cameraCutoutType == 'universal'
              ? 'Universal (mengakomodasi berbagai layout)'
              : _cutoutLabel(caseItem.cameraCutoutType),
        ),
        _specRow('Stok', caseItem.stock > 0 ? '${caseItem.stock} unit' : 'Habis'),
        if (caseItem.features.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.xs),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: caseItem.features
                .map((feature) => FeatureChip(label: feature))
                .toList(),
          ),
        ],
        const SizedBox(height: AppSpacing.md),

        // ===== Daftar model kompatibel =====
        SectionHeader(
          title: 'Model yang kompatibel',
          subtitle: '${compatibleDevices.length} model terverifikasi',
        ),
        const SizedBox(height: AppSpacing.xs),
        Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: compatibleDevices
              .map(
                (model) => Chip(
                  label: Text(model.displayName),
                  visualDensity: VisualDensity.compact,
                ),
              )
              .toList(),
        ),
        const SizedBox(height: AppSpacing.md),
      ],
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Case'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Kembali',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: isWide
                  ? Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 4,
                          child: Column(
                            children: [
                              Container(
                                height: 340,
                                decoration: BoxDecoration(
                                  color: AppColors.placeholder,
                                  borderRadius: BorderRadius.circular(
                                    AppSpacing.radiusLg,
                                  ),
                                ),
                                child: const Center(
                                  child: Icon(
                                    Icons.phone_iphone_rounded,
                                    size: 120,
                                    color: AppColors.primaryDark,
                                  ),
                                ),
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Text(
                                'Gambar produk masih placeholder — '
                                'belum memakai Firebase Storage.',
                                textAlign: TextAlign.center,
                                style: AppTypography.caption.copyWith(
                                  fontSize: 13,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: AppSpacing.lg),
                        Expanded(flex: 6, child: content),
                      ],
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 220,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.placeholder,
                            borderRadius: BorderRadius.circular(
                              AppSpacing.radiusLg,
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.phone_iphone_rounded,
                              size: 90,
                              color: AppColors.primaryDark,
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        content,
                      ],
                    ),
            ),
          ),
        ),
      ),
      bottomNavigationBar: _AddToCartBar(
        caseItem: caseItem,
        device: device,
        quantity: _quantity,
        onQuantityChanged: (value) => setState(() => _quantity = value),
      ),
    );
  }

  static String _cutoutLabel(String code) {
    switch (code) {
      case 'single':
        return 'Kamera tunggal';
      case 'dual_vertical':
        return 'Kamera ganda vertikal';
      case 'dual_diagonal':
        return 'Kamera ganda diagonal';
      case 'triple_vertical':
        return 'Kamera tiga vertikal';
      case 'triple_square':
        return 'Kamera tiga kotak (Pro)';
      default:
        return code;
    }
  }

  Widget _specRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.caption.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompatibilityPanel extends StatelessWidget {
  const _CompatibilityPanel({
    required this.device,
    required this.compatible,
    required this.caseItem,
    required this.onPickDevice,
  });

  final IphoneModel? device;
  final bool? compatible;
  final CaseModel caseItem;
  final VoidCallback onPickDevice;

  @override
  Widget build(BuildContext context) {
    final Color background;
    final Color border;
    final IconData icon;
    final String title;
    final String message;

    if (device == null) {
      background = AppColors.surface;
      border = AppColors.border;
      icon = Icons.help_outline_rounded;
      title = 'Belum bisa diverifikasi';
      message =
          'Pilih model iPhone kamu dulu untuk memastikan case ini benar-benar cocok.';
    } else if (compatible == true) {
      background = AppColors.success.withValues(alpha: 0.16);
      border = AppColors.success;
      icon = Icons.verified_rounded;
      title = 'Kompatibel dengan ${device!.displayName}';
      message =
          'Model terdaftar dan layout cutout kamera sesuai '
          '(${device!.cameraLayoutLabel}).';
    } else {
      background = AppColors.error.withValues(alpha: 0.08);
      border = AppColors.error;
      icon = Icons.block_rounded;
      title = 'Tidak kompatibel dengan ${device!.displayName}';
      message = caseItem.compatibleModelIds.contains(device!.id)
          ? 'Model terdaftar, tetapi tipe cutout kamera case tidak sesuai '
                '(${device!.cameraLayoutLabel}).'
          : 'Model ini tidak ada pada daftar kompatibilitas case.';
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: border),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: border == AppColors.border
              ? AppColors.textSecondary
              : border),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  message,
                  style: AppTypography.caption.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
                if (device == null) ...[
                  const SizedBox(height: 4),
                  TextButton(
                    onPressed: onPickDevice,
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: const Size(0, 0),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Pilih model iPhone'),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AddToCartBar extends StatelessWidget {
  const _AddToCartBar({
    required this.caseItem,
    required this.device,
    required this.quantity,
    required this.onQuantityChanged,
  });

  final CaseModel caseItem;
  final IphoneModel? device;
  final int quantity;
  final ValueChanged<int> onQuantityChanged;

  @override
  Widget build(BuildContext context) {
    final canAdd =
        device != null && caseItem.stock > 0 && (caseItem.isCompatibleWith(device!));

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.sm),
        decoration: const BoxDecoration(
          color: AppColors.background,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Center(
          // heightFactor 1 mencegah Center memakan seluruh tinggi layar
          // saat dipakai sebagai bottomNavigationBar.
          heightFactor: 1,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1000),
            child: Row(
              children: [
                _QuantityStepper(
                  value: quantity,
                  max: caseItem.stock == 0 ? 1 : caseItem.stock,
                  onChanged: onQuantityChanged,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: PrimaryButton(
                    label: caseItem.stock == 0
                        ? 'Stok habis'
                        : device == null
                        ? 'Pilih model dulu'
                        : canAdd
                        ? 'Tambah ke Keranjang'
                        : 'Tidak kompatibel',
                    icon: Icons.add_shopping_cart_rounded,
                    onPressed: canAdd
                        ? () {
                            final error = context.read<CartProvider>().addCase(
                              caseItem: caseItem,
                              device: device!,
                              quantity: quantity,
                            );
                            final messenger = ScaffoldMessenger.of(context);
                            if (error != null) {
                              messenger.showSnackBar(
                                SnackBar(content: Text(error)),
                              );
                            } else {
                              messenger.showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${caseItem.name} ditambahkan ke keranjang.',
                                  ),
                                  action: SnackBarAction(
                                    label: 'Lihat',
                                    onPressed: () => context.go('/keranjang'),
                                  ),
                                ),
                              );
                            }
                          }
                        : null,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _QuantityStepper extends StatelessWidget {
  const _QuantityStepper({
    required this.value,
    required this.max,
    required this.onChanged,
  });

  final int value;
  final int max;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            onPressed: value > 1 ? () => onChanged(value - 1) : null,
            icon: const Icon(Icons.remove_rounded, size: 18),
            tooltip: 'Kurangi',
          ),
          SizedBox(
            width: 28,
            child: Text(
              '$value',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
            ),
          ),
          IconButton(
            onPressed: value < max ? () => onChanged(value + 1) : null,
            icon: const Icon(Icons.add_rounded, size: 18),
            tooltip: 'Tambah',
          ),
        ],
      ),
    );
  }
}
