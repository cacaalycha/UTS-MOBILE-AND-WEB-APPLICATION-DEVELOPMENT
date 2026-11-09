import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../providers/order_provider.dart';
import '../../widgets/components/badges.dart';
import '../../widgets/components/buttons.dart';
import '../../widgets/components/empty_state.dart';

/// Halaman Detail Pesanan (H7b).
class DetailPesananPage extends StatelessWidget {
  const DetailPesananPage({super.key, required this.orderId});

  final String orderId;

  @override
  Widget build(BuildContext context) {
    final order = context.watch<OrderProvider>().orderById(orderId);

    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Detail Pesanan')),
        body: EmptyState(
          title: 'Pesanan tidak ditemukan',
          message: 'Pesanan mungkin sudah tidak tersedia.',
          icon: Icons.receipt_long_outlined,
          actionLabel: 'Kembali',
          onAction: () => context.pop(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Pesanan'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
          tooltip: 'Kembali',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(AppSpacing.md),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm),
                    decoration: BoxDecoration(
                      color: AppColors.primarySurface,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                order.id,
                                style: AppTypography.subtitle.copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            ),
                            StatusBadge(status: order.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Dibuat ${_formatDate(order.orderDate)}',
                          style: AppTypography.caption.copyWith(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Item pesanan',
                    style: AppTypography.subtitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  for (final item in order.items)
                    Padding(
                      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                      child: Container(
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
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.caseName,
                                    style: AppTypography.caption.copyWith(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Untuk ${item.forIphoneModelName}',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    '${formatRupiah(item.price)} × ${item.quantity}',
                                    style: AppTypography.caption.copyWith(
                                      fontSize: 14,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              formatRupiah(item.lineTotal),
                              style: AppTypography.caption.copyWith(
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  const SizedBox(height: AppSpacing.sm),
                  PriceSummaryCard(
                    subtotal: order.subtotal,
                    shippingCost: order.shippingCost,
                    total: order.total,
                    itemCount: order.totalQuantity,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Informasi pengiriman',
                    style: AppTypography.subtitle.copyWith(fontSize: 22),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _infoRow('Nama', order.customerName),
                  _infoRow('Telepon', order.customerPhone),
                  _infoRow('Alamat', order.shippingAddress),
                  _infoRow('Metode bayar', order.paymentMethod),
                  if (order.note.isNotEmpty) _infoRow('Catatan', order.note),
                  const SizedBox(height: AppSpacing.md),
                  SecondaryButton(
                    label: 'Kembali ke daftar pesanan',
                    onPressed: () => context.pop(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
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

  String _formatDate(DateTime date) {
    const months = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    return '${date.day} ${months[date.month - 1]} ${date.year}, $hour:$minute';
  }
}
