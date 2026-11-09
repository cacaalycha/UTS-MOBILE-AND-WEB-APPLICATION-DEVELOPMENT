import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../providers/order_provider.dart';
import '../../widgets/components/badges.dart';
import '../../widgets/components/buttons.dart';
import '../../widgets/components/empty_state.dart';

/// Halaman Konfirmasi Pesanan (H6c).
class KonfirmasiPage extends StatelessWidget {
  const KonfirmasiPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final orderProvider = context.watch<OrderProvider>();
    final order = orderProvider.orderById(orderId) ??
        (orderProvider.lastCreatedOrder?.id == orderId
            ? orderProvider.lastCreatedOrder
            : null);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Konfirmasi Pesanan')),
        body: EmptyState(
          title: 'Pesanan tidak ditemukan',
          message: 'Data pesanan tidak tersedia pada sesi ini.',
          icon: Icons.receipt_long_outlined,
          actionLabel: 'Ke Beranda',
          onAction: () => context.go('/beranda'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Konfirmasi Pesanan'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 640),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.25),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_rounded,
                        size: 56,
                        color: AppColors.textPrimary,
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Pesanan berhasil dibuat',
                    textAlign: TextAlign.center,
                    style: AppTypography.title.copyWith(fontSize: 26),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Simpan nomor pesanan untuk mengecek status.',
                    textAlign: TextAlign.center,
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Nomor pesanan',
                              style: AppTypography.caption.copyWith(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              order.id,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Status',
                              style: AppTypography.caption.copyWith(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            StatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Metode bayar',
                              style: AppTypography.caption.copyWith(
                                fontSize: 15,
                                color: AppColors.textSecondary,
                              ),
                            ),
                            Text(
                              order.paymentMethod,
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w600,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  PriceSummaryCard(
                    subtotal: order.subtotal,
                    shippingCost: order.shippingCost,
                    total: order.total,
                    itemCount: order.totalQuantity,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Dikirim ke',
                          style: AppTypography.caption.copyWith(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.customerName,
                          style: AppTypography.caption.copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          order.customerPhone,
                          style: AppTypography.caption.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          order.shippingAddress,
                          style: AppTypography.caption.copyWith(fontSize: 15),
                        ),
                        if (order.paymentMethod == 'Transfer Manual') ...[
                          const SizedBox(height: AppSpacing.xs),
                          Text(
                            'Instruksi simulasi: transfer ke '
                            'BCA 1234567890 a.n. Caca Store, lalu konfirmasi '
                            'lewat halaman Pesanan Saya.',
                            style: AppTypography.caption.copyWith(
                              fontSize: 14,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  PrimaryButton(
                    label: 'Lihat Pesanan Saya',
                    icon: Icons.receipt_long_rounded,
                    onPressed: () => context.go('/pesanan'),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  SecondaryButton(
                    label: 'Kembali ke Beranda',
                    onPressed: () => context.go('/beranda'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
