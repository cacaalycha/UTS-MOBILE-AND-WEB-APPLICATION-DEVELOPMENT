import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../models/iphone_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/product_provider.dart';
import '../../widgets/components/buttons.dart';
import '../../widgets/components/case_card.dart';
import '../../widgets/components/empty_state.dart';
import '../../widgets/components/section_header.dart';

/// Halaman Beranda (H2).
class BerandaPage extends StatelessWidget {
  const BerandaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final products = context.watch<ProductProvider>();
    final device = products.selectedDevice;
    final isWide = MediaQuery.sizeOf(context).width >= 900;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda'),
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
                    'Halo, ${auth.user?.name ?? 'Pengguna'} 👋',
                    style: AppTypography.title.copyWith(
                      fontSize: isWide ? 32 : 26,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Pilih model iPhone kamu, lalu temukan case yang pas.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // ==== Kartu pemilihan model iPhone ====
                  _DeviceCard(device: device),
                  const SizedBox(height: AppSpacing.md),

                  SectionHeader(
                    title: 'Case populer',
                    subtitle: 'Rekomendasi awal berdasarkan rating tertinggi',
                    actionLabel: 'Lihat katalog',
                    onAction: () => context.go('/katalog'),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (products.isLoading)
                    const Padding(
                      padding: EdgeInsets.all(AppSpacing.lg),
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (products.popularCases.isEmpty)
                    const EmptyState(
                      title: 'Belum ada produk',
                      message: 'Data case belum tersedia saat ini.',
                      icon: Icons.inventory_2_outlined,
                    )
                  else
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final columns = constraints.maxWidth >= 900 ? 2 : 1;
                        final items = products.popularCases;
                        if (columns == 1) {
                          return Column(
                            children: [
                              for (final item in items)
                                Padding(
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
                                ),
                            ],
                          );
                        }
                        return Wrap(
                          spacing: AppSpacing.sm,
                          runSpacing: AppSpacing.sm,
                          children: [
                            for (final item in items)
                              SizedBox(
                                width: (constraints.maxWidth -
                                        AppSpacing.sm) /
                                    2,
                                child: CaseCard(
                                  caseItem: item,
                                  compatible: device == null
                                      ? null
                                      : item.isCompatibleWith(device),
                                  onTap: () => context.push(
                                    '/katalog/detail/${item.id}',
                                  ),
                                ),
                              ),
                          ],
                        );
                      },
                    ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Proyek praktik Mobile and Web Application Development · '
                    'Data masih simulasi (belum terhubung Firebase).',
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
        content: const Text('Kamu perlu masuk kembali untuk memesan case.'),
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
      if (context.mounted) {
        context.read<ProductProvider>().resetFilters();
        context.go('/login');
      }
    }
  }
}

class _DeviceCard extends StatelessWidget {
  const _DeviceCard({required this.device});

  final IphoneModel? device;

  @override
  Widget build(BuildContext context) {
    final products = context.read<ProductProvider>();
    final selected = device;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.phone_iphone_rounded,
                color: AppColors.primaryDark,
              ),
              const SizedBox(width: AppSpacing.xs),
              Text(
                'Model iPhone saya',
                style: AppTypography.caption.copyWith(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            selected != null
                ? selected.fullName
                : 'Belum dipilih — pilih model agar case yang tampil sudah terverifikasi cocok.',
            style: AppTypography.subtitle.copyWith(
              fontSize: selected != null ? 24 : 18,
              fontWeight: selected != null
                  ? FontWeight.w700
                  : FontWeight.w400,
              color: selected != null
                  ? AppColors.textPrimary
                  : AppColors.textSecondary,
            ),
          ),
          if (selected != null) ...[
            const SizedBox(height: 4),
            Text(
              '${selected.cameraLayoutLabel} · '
              'layar ${selected.screenWidthMm.toStringAsFixed(1)} mm',
              style: AppTypography.caption.copyWith(
                fontSize: 15,
                color: AppColors.textSecondary,
              ),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: AppSpacing.xs,
            runSpacing: AppSpacing.xs,
            children: [
              PrimaryButton(
                label: selected != null
                    ? 'Pilih case sekarang'
                    : 'Pilih model iPhone',
                icon: Icons.search_rounded,
                expanded: false,
                onPressed: () => context.go('/pilih-model'),
              ),
              if (selected != null)
                SecondaryButton(
                  label: 'Ganti model',
                  icon: Icons.swap_horiz_rounded,
                  expanded: false,
                  onPressed: () {
                    products.selectDevice(null);
                    context.go('/pilih-model');
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }
}
