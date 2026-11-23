import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../core/utils/validators.dart';
import '../../data/data_simulasi.dart';
import '../../services/layanan_data.dart';
import '../../widgets/components/empty_state.dart';

/// Pesanan Saya — padanan `ReservasiSayaPage` pada modul Minggu 10.
///
/// [StreamBuilder] menangani tiga keadaan: waiting (loading), error
/// (kendala koneksi / Rules), dan data (kosong atau terisi). Query cukup satu
/// `.where('id_pengguna')`, pengurutan dilakukan di sisi Dart.
class PesananSayaFirestorePage extends StatelessWidget {
  const PesananSayaFirestorePage({super.key, this.layanan});

  /// Injeksi `LayananMemori()` untuk widget test.
  final LayananData? layanan;

  @override
  Widget build(BuildContext context) {
    final service = layanan ?? context.read<LayananData>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pesanan Saya · collection orders'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.go('/firestore'),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/firestore/form'),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Pesanan Baru'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 900),
            child: StreamBuilder<List<PesananFirestore>>(
              stream: service.streamPesananSaya(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return const EmptyState(
                    title: 'Gagal memuat pesanan',
                    message:
                        'Periksa Security Rules request.auth != null dan koneksi internet.',
                    icon: Icons.cloud_off_outlined,
                  );
                }

                final daftar =
                    snapshot.data ?? const <PesananFirestore>[];
                if (daftar.isEmpty) {
                  return const EmptyState(
                    title: 'Belum ada pesanan',
                    message:
                        'Buat pesanan pertama lewat Form Pesanan, lalu tekan F5 '
                        'untuk membuktikan data bertahan di Cloud Firestore.',
                    icon: Icons.receipt_long_outlined,
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
                  itemBuilder: (context, index) => _KartuPesanan(
                        pesanan: daftar[index],
                        layanan: service,
                      ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _KartuPesanan extends StatelessWidget {
  const _KartuPesanan({
    required this.pesanan,
    required this.layanan,
  });

  final PesananFirestore pesanan;
  final LayananData layanan;

  /// Mode ubah memakai form yang sama dengan mode tambah (Minggu 11).
  void _bukaUbah(BuildContext context) {
    context.push('/firestore/form', extra: pesanan);
  }

  /// Hapus selalu lewat dialog konfirmasi. Batal/null = tidak ada perubahan.
  Future<void> _konfirmasiHapus(BuildContext context) async {
    final yakin = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Hapus pesanan?'),
        content: Text(
          '${pesanan.namaCase} pada ${pesanan.tanggal} jam ${pesanan.jam} '
          'akan dihapus permanen dari collection orders.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Batal'),
          ),
          FilledButton(
            key: const Key('tombol_konfirmasi_hapus'),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );

    if (yakin != true || !context.mounted) return;

    final pesan = ScaffoldMessenger.of(context);
    try {
      await layanan.hapusPesanan(pesanan.idPesanan);
      if (!context.mounted) return;
      pesan.showSnackBar(
        const SnackBar(content: Text('Pesanan berhasil dihapus.')),
      );
    } on OperasiDitolakException catch (e) {
      if (!context.mounted) return;
      pesan.showSnackBar(
        SnackBar(
          content: Text(e.pesan),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      if (!context.mounted) return;
      pesan.showSnackBar(
        SnackBar(
          content: const Text('Gagal menghapus. Periksa Rules dan koneksi.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  pesanan.namaCase,
                  style: AppTypography.caption
                      .copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              _StatusChip(status: pesanan.status),
              PopupMenuButton<String>(
                key: const Key('menu_aksi_pesanan'),
                tooltip: 'Aksi pesanan',
                onSelected: (nilai) => nilai == 'ubah'
                    ? _bukaUbah(context)
                    : _konfirmasiHapus(context),
                itemBuilder: (context) => <PopupMenuEntry<String>>[
                  PopupMenuItem<String>(
                    value: 'ubah',
                    enabled: pesanan.bisaDiubah,
                    child: const Text('Ubah'),
                  ),
                  PopupMenuItem<String>(
                    value: 'hapus',
                    enabled: pesanan.bisaDiubah,
                    child: const Text('Hapus'),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${pesanan.namaModelIphone} · ${pesanan.jumlah} pcs · '
            '${formatRupiah(pesanan.totalHarga)}',
            style: AppTypography.caption.copyWith(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Pengambilan ${pesanan.tanggal} jam ${pesanan.jam} · '
            'Doc ID ${pesanan.idPesanan}',
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
          if (pesanan.catatan.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              'Catatan: ${pesanan.catatan}',
              style: AppTypography.caption.copyWith(fontSize: 13),
            ),
          ],
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.status});

  final String status;

  @override
  Widget build(BuildContext context) {
    final dibatalkan = status.toLowerCase() == statusDibatalkan.toLowerCase();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: dibatalkan
            ? AppColors.error.withValues(alpha: 0.12)
            : AppColors.success.withValues(alpha: 0.25),
        borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
      ),
      child: Text(
        status,
        style: AppTypography.caption.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: dibatalkan ? AppColors.error : AppColors.textPrimary,
        ),
      ),
    );
  }
}
