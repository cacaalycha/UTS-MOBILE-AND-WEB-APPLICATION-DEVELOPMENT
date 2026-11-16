import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../data/data_simulasi.dart';
import '../../services/layanan_data.dart';
import '../../widgets/components/badges.dart';
import '../../widgets/components/empty_state.dart';

/// Daftar Case — padanan `DaftarRuangPage` pada modul Minggu 10.
///
/// Membaca `collection('cases').snapshots()` lewat [StreamBuilder] dan
/// menangani tiga keadaan: waiting (loading), error (Rules / koneksi), dan
/// data (kosong atau terisi).
class DaftarCasePage extends StatelessWidget {
  const DaftarCasePage({super.key, this.layanan});

  /// Injeksi `LayananMemori()` untuk widget test.
  final LayananData? layanan;

  @override
  Widget build(BuildContext context) {
    final service = layanan ?? context.read<LayananData>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Case · collection cases'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/firestore'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/firestore/form'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Buat Pesanan'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: StreamBuilder<List<CaseKatalog>>(
              stream: service.streamDaftarCase(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const EmptyState(
                    title: 'Gagal memuat daftar case',
                    message:
                        'Periksa Security Rules dan koneksi internet, lalu muat ulang halaman.',
                    icon: Icons.cloud_off_outlined,
                  );
                }

                final daftar = snapshot.data ?? const <CaseKatalog>[];
                if (daftar.isEmpty) {
                  return const EmptyState(
                    title: 'Collection cases masih kosong',
                    message:
                        'Muat ulang halaman agar auto-seed 4 case dijalankan.',
                    icon: Icons.inventory_2_outlined,
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.md,
                    AppSpacing.md,
                    AppSpacing.md,
                    88,
                  ),
                  itemCount: daftar.length,
                  separatorBuilder: (_, _) =>
                      const SizedBox(height: AppSpacing.xs),
                  itemBuilder: (context, index) =>
                      _KartuCase(caseItem: daftar[index]),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuCase extends StatelessWidget {
  const _KartuCase({required this.caseItem});

  final CaseKatalog caseItem;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CaseImagePlaceholder(size: 64),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  caseItem.namaCase,
                  style: AppTypography.caption
                      .copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 2),
                Text(
                  '${caseItem.brand} · ${caseItem.material} · '
                  '${caseItem.modelKompatibel.length} model kompatibel',
                  style: AppTypography.caption.copyWith(
                    fontSize: 13,
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    Text(
                      formatRupiah(caseItem.harga),
                      style: AppTypography.caption.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryDark,
                      ),
                    ),
                    StockBadge(stock: caseItem.stok),
                    FeatureChip(label: caseItem.kategori),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
