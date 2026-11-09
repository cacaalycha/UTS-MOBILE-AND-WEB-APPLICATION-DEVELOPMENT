import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../models/case_model.dart';
import 'badges.dart';
import 'empty_state.dart';

/// Kartu produk case — dipakai di Beranda dan Katalog.
class CaseCard extends StatelessWidget {
  const CaseCard({
    super.key,
    required this.caseItem,
    this.onTap,
    this.compatible,
    this.compact = false,
  });

  final CaseModel caseItem;
  final VoidCallback? onTap;

  /// null = status kompatibilitas tidak ditampilkan.
  final bool? compatible;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.xs),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CaseImagePlaceholder(size: compact ? 72 : 88),
              const SizedBox(width: AppSpacing.xs),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      caseItem.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: compact ? 16 : 18,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${caseItem.brand} · ${caseItem.material}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTypography.caption.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      formatRupiah(caseItem.price),
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 16 : 18,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: [
                        StockBadge(stock: caseItem.stock),
                        if (compatible != null)
                          _CompatibilityBadge(compatible: compatible!),
                      ],
                    ),
                    if (!compact && caseItem.features.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: caseItem.features
                            .take(3)
                            .map((feature) => FeatureChip(label: feature))
                            .toList(),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CompatibilityBadge extends StatelessWidget {
  const _CompatibilityBadge({required this.compatible});

  final bool compatible;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: compatible
            ? AppColors.success.withValues(alpha: 0.25)
            : AppColors.error.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            compatible ? Icons.verified_outlined : Icons.block_outlined,
            size: 14,
            color: compatible ? AppColors.textPrimary : AppColors.error,
          ),
          const SizedBox(width: 4),
          Text(
            compatible ? 'Kompatibel' : 'Tidak cocok',
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: compatible ? AppColors.textPrimary : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }
}
