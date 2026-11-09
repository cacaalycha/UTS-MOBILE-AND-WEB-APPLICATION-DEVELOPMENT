import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../models/order_model.dart';

/// Badge status dengan warna dari visual system Minggu 4.
class StatusBadge extends StatelessWidget {
  const StatusBadge({super.key, required this.status});

  final OrderStatus status;

  Color get _background {
    switch (status) {
      case OrderStatus.selesai:
        return AppColors.success;
      case OrderStatus.diproses:
        return AppColors.pending;
      case OrderStatus.dibatalkan:
        return AppColors.error;
    }
  }

  Color get _foreground {
    switch (status) {
      case OrderStatus.selesai:
      case OrderStatus.diproses:
        return AppColors.textPrimary;
      case OrderStatus.dibatalkan:
        return AppColors.textOnPrimary;
    }
  }

  IconData get _icon {
    switch (status) {
      case OrderStatus.selesai:
        return Icons.check_circle_outline;
      case OrderStatus.diproses:
        return Icons.schedule_outlined;
      case OrderStatus.dibatalkan:
        return Icons.cancel_outlined;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: _background,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ikon dipakai agar status tidak hanya dibedakan lewat warna
          // (checklist aksesibilitas Minggu 4).
          Icon(_icon, size: 16, color: _foreground),
          const SizedBox(width: 4),
          Text(
            status.label,
            style: AppTypography.caption.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: _foreground,
            ),
          ),
        ],
      ),
    );
  }
}

/// Badge kecil untuk label fitur case (Shockproof, Slim, MagSafe).
class FeatureChip extends StatelessWidget {
  const FeatureChip({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 13,
          color: AppColors.primaryDark,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

/// Badge stok: habis / menipis / tersedia.
class StockBadge extends StatelessWidget {
  const StockBadge({super.key, required this.stock});

  final int stock;

  @override
  Widget build(BuildContext context) {
    final String label;
    final Color color;
    if (stock == 0) {
      label = 'Stok habis';
      color = AppColors.error;
    } else if (stock <= 5) {
      label = 'Stok menipis ($stock)';
      color = AppColors.pending;
    } else {
      label = 'Stok $stock';
      color = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text(
        label,
        style: AppTypography.caption.copyWith(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: stock == 0 ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }
}
