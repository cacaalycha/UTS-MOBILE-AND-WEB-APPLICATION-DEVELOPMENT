import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../models/iphone_model.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/empty_state.dart';
import '../../widgets/components/section_header.dart';

/// Halaman Pilih Model iPhone (H3) — langkah inti Compatibility Checker.
class PilihModelPage extends StatefulWidget {
  const PilihModelPage({super.key});

  @override
  State<PilihModelPage> createState() => _PilihModelPageState();
}

class _PilihModelPageState extends State<PilihModelPage> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<IphoneModel> _filter(List<IphoneModel> models) {
    if (_query.trim().isEmpty) return models;
    final q = _query.trim().toLowerCase();
    return models
        .where(
          (model) =>
              model.displayName.toLowerCase().contains(q) ||
              model.series.toLowerCase().contains(q) ||
              model.variant.toLowerCase().contains(q),
        )
        .toList();
  }

  Future<void> _choose(IphoneModel model) async {
    final products = context.read<ProductProvider>();
    await products.selectDevice(model);
    if (!mounted) return;
    context.go('/katalog');
  }

  @override
  Widget build(BuildContext context) {
    final products = context.watch<ProductProvider>();
    final models = _filter(products.iphones);
    final grouped = <String, List<IphoneModel>>{};
    for (final model in models) {
      grouped.putIfAbsent(model.series, () => []).add(model);
    }
    final seriesKeys = grouped.keys.toList()
      ..sort((a, b) => b.compareTo(a));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Model iPhone'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/beranda'),
          tooltip: 'Kembali',
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.sm,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'iPhone mana yang kamu pakai?',
                        style: AppTypography.subtitle.copyWith(fontSize: 24),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Kami hanya menampilkan case yang cutout kameranya '
                        'cocok dengan model pilihanmu.',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      SearchField(
                        hintText: 'Cari model, mis. iPhone 15 Pro',
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        onClear: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: models.isEmpty
                      ? const EmptyState(
                          title: 'Model tidak ditemukan',
                          message:
                              'Coba kata kunci lain, misalnya "iPhone 15" atau "Pro Max".',
                          icon: Icons.search_off_rounded,
                        )
                      : ListView(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          children: [
                            for (final series in seriesKeys) ...[
                              SectionHeader(title: series),
                              const SizedBox(height: AppSpacing.xs),
                              for (final model in grouped[series]!)
                                Padding(
                                  padding: const EdgeInsets.only(
                                    bottom: AppSpacing.xs,
                                  ),
                                  child: _ModelTile(
                                    model: model,
                                    selected:
                                        products.selectedDevice?.id ==
                                        model.id,
                                    onTap: () => _choose(model),
                                  ),
                                ),
                              const SizedBox(height: AppSpacing.sm),
                            ],
                          ],
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

class _ModelTile extends StatelessWidget {
  const _ModelTile({
    required this.model,
    required this.selected,
    required this.onTap,
  });

  final IphoneModel model;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primarySurface : AppColors.surface,
      borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.sm),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            border: Border.all(
              color: selected ? AppColors.primary : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.placeholder,
                  borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
                ),
                child: const Icon(
                  Icons.phone_iphone_rounded,
                  color: AppColors.primaryDark,
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.displayName,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 17,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${model.cameraLayoutLabel} · '
                      '${model.screenWidthMm.toStringAsFixed(1)} × '
                      '${model.screenHeightMm.toStringAsFixed(1)} mm · '
                      '${model.releaseYear}',
                      style: AppTypography.caption.copyWith(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              if (selected)
                const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.primaryDark,
                )
              else
                const Icon(
                  Icons.chevron_right_rounded,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
