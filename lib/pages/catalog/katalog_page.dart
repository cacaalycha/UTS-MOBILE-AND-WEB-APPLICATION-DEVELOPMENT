import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/case_card.dart';
import '../../widgets/components/empty_state.dart';
import '../../widgets/components/section_header.dart';

/// Halaman Katalog Case / Daftar Case Kompatibel (H4).
class KatalogPage extends StatelessWidget {
  const KatalogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final device = products.selectedDevice;
    final cases = products.visibleCases;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Katalog Case'),
        actions: [
          IconButton(
            onPressed: () => context.go('/pilih-model'),
            icon: const Icon(Icons.phone_iphone_rounded),
            tooltip: device == null ? 'Pilih model' : 'Ganti model',
          ),
          const SizedBox(width: AppSpacing.xs),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 1100),
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.md,
                      AppSpacing.sm,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Ringkasan model terpilih
                        _DeviceBanner(
                          modelName: device?.displayName,
                          count: cases.length,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        SearchField(
                          hintText: 'Cari nama case, brand, atau material',
                          onChanged: products.setSearchQuery,
                          onClear: products.searchQuery.isEmpty
                              ? null
                              : () => products.setSearchQuery(''),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Filter kategori
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final category in caseCategories)
                              ChoiceChip(
                                label: Text(category),
                                selected:
                                    products.selectedCategory == category,
                                onSelected: (_) =>
                                    products.selectCategory(category),
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xs),
                        // Filter fitur
                        Wrap(
                          spacing: AppSpacing.xs,
                          runSpacing: AppSpacing.xs,
                          children: [
                            for (final feature in caseFeatureFilters)
                              FilterChip(
                                label: Text(feature),
                                selected:
                                    products.selectedFeatures.contains(feature),
                                onSelected: (_) =>
                                    products.toggleFeature(feature),
                              ),
                            if (products.selectedCategory != 'Semua' ||
                                products.selectedFeatures.isNotEmpty)
                              ActionChip(
                                avatar: const Icon(
                                  Icons.refresh_rounded,
                                  size: 16,
                                ),
                                label: const Text('Reset'),
                                onPressed: products.resetFilters,
                              ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          '${cases.length} case ditemukan',
                          style: AppTypography.caption.copyWith(
                            fontSize: 15,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (cases.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: EmptyState(
                      title: 'Case tidak ditemukan',
                      message: device == null
                          ? 'Belum ada case yang cocok dengan filter ini.'
                          : 'Tidak ada case kompatibel untuk '
                                '${device.displayName} dengan filter ini. '
                                'Coba hapus filter atau ganti model.',
                      icon: Icons.search_off_rounded,
                      actionLabel: 'Reset filter',
                      onAction: products.resetFilters,
                    ),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.md,
                      0,
                      AppSpacing.md,
                      AppSpacing.md,
                    ),
                    sliver: SliverLayoutBuilder(
                      builder: (context, constraints) {
                        final columns = isWide ? 2 : 1;
                        if (columns == 1) {
                          return SliverList.builder(
                            itemCount: cases.length,
                            itemBuilder: (context, index) {
                              final item = cases[index];
                              return Padding(
                                padding: const EdgeInsets.only(
                                  bottom: AppSpacing.xs,
                                ),
                                child: CaseCard(
                                  caseItem: item,
                                  compatible: device == null
                                      ? null
                                      : item.isCompatibleWith(device),
                                  onTap: () => context.push(
                                    '/katalog/detail/${item.id}',
                                  ),
                                ),
                              );
                            },
                          );
                        }
                        return SliverGrid.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                mainAxisSpacing: AppSpacing.sm,
                                crossAxisSpacing: AppSpacing.sm,
                                mainAxisExtent: 132,
                              ),
                          itemCount: cases.length,
                          itemBuilder: (context, index) {
                            final item = cases[index];
                            return CaseCard(
                              caseItem: item,
                              compact: true,
                              compatible: device == null
                                  ? null
                                  : item.isCompatibleWith(device),
                              onTap: () =>
                                  context.push('/katalog/detail/${item.id}'),
                            );
                          },
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
}

class _DeviceBanner extends StatelessWidget {
  const _DeviceBanner({required this.modelName, required this.count});

  final String? modelName;
  final int count;

  @override
  Widget build(BuildContext context) {
    final hasModel = modelName != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: hasModel ? AppColors.primarySurface : AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            hasModel ? Icons.verified_rounded : Icons.info_outline_rounded,
            color: hasModel ? AppColors.primaryDark : AppColors.textSecondary,
          ),
          const SizedBox(width: AppSpacing.xs),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasModel ? modelName! : 'Model iPhone belum dipilih',
                  style: AppTypography.caption.copyWith(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                  ),
                ),
                Text(
                  hasModel
                      ? 'Menampilkan case yang kompatibel dengan perangkat ini.'
                      : 'Pilih model dulu agar hasil sudah terverifikasi cocok.',
                  style: AppTypography.caption.copyWith(
                    fontSize: 14,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (!hasModel)
            TextButton(
              onPressed: () => context.go('/pilih-model'),
              child: const Text('Pilih'),
            ),
        ],
      ),
    );
  }
}
