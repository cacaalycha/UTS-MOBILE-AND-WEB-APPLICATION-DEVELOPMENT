import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../services/firestore_status.dart';
import '../../services/layanan_data.dart';
import '../../widgets/components/sapaan_firestore.dart';

/// Beranda praktikum **Minggu 10 — Cloud Firestore**.
///
/// Menampilkan sapaan real-time dari `users/{uid}`, status aktifasi database,
/// jumlah dokumen pada tiga collection, dan pintasan ke Daftar Case,
/// Form Pesanan, serta Pesanan Saya (padanan BerandaPage pada modul).
class BerandaFirestorePage extends StatelessWidget {
  const BerandaFirestorePage({
    super.key,
    this.layanan,
    this.status,
    this.namaCadangan = 'Pengguna',
    this.tampilkanBannerError = false,
    this.pesanError,
  });

  /// Injeksi untuk widget test (`LayananMemori`). Bila null, diambil dari
  /// Provider yang disediakan `FirebaseKatalogApp`.
  final LayananData? layanan;

  /// Status inisialisasi (banner error bila Firestore belum aktif).
  final FirestoreStatus? status;

  /// Nama cadangan sebelum dokumen `users/{uid}` terbentuk.
  final String namaCadangan;

  /// Widget test dapat menyuntik keadaan error tanpa perlu Provider.
  final bool tampilkanBannerError;
  final String? pesanError;

  @override
  Widget build(BuildContext context) {
    final service = layanan ?? context.read<LayananData>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Firestore · Minggu 10'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          tooltip: 'Kembali ke Beranda',
          onPressed: () => context.go('/beranda'),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1000),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SapaanFirestore(
                    layanan: service,
                    namaCadangan: namaCadangan,
                    fontSize: 30,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Data aplikasi kini tersimpan permanen di Cloud Firestore '
                    'dan diperbarui real-time.',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                  ListenableBuilder(
                    listenable: status ?? ValueNotifier<int>(0),
                    builder: (context, _) {
                      final pesan = tampilkanBannerError
                          ? (pesanError ?? 'Firestore belum aktif.')
                          : status?.error;
                      if (pesan == null) return const SizedBox.shrink();
                      return Padding(
                        padding: const EdgeInsets.only(
                          bottom: AppSpacing.sm,
                        ),
                        child: _BannerError(pesan: pesan),
                      );
                    },
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _RingkasanCollection(layanan: service),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Alur praktikum',
                    style: AppTypography.subtitle.copyWith(fontSize: 20),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  _Pintasan(
                    ikon: Icons.inventory_2_outlined,
                    judul: 'Daftar Case',
                    keterangan:
                        'Baca collection cases real-time (auto-seed 4 case).',
                    rute: '/firestore/case',
                  ),
                  _Pintasan(
                    ikon: Icons.post_add_outlined,
                    judul: 'Form Pesanan',
                    keterangan:
                        'Tambah dokumen orders + penolakan jadwal bentrok.',
                    rute: '/firestore/form',
                  ),
                  _Pintasan(
                    ikon: Icons.receipt_long_outlined,
                    judul: 'Pesanan Saya',
                    keterangan:
                        'StreamBuilder terfilter per uid, bertahan setelah F5.',
                    rute: '/firestore/pesanan',
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _KotakCatatan(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BannerError extends StatelessWidget {
  const _BannerError({required this.pesan});

  final String pesan;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.07),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.4)),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.cloud_off_outlined, color: AppColors.error, size: 20),
              SizedBox(width: AppSpacing.xs),
              Text(
                'Firestore belum dapat diakses',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Aktifkan Build > Firestore Database di Console, lalu Publish Rules '
            'request.auth != null. Detail: $pesan',
            style: AppTypography.caption.copyWith(fontSize: 13),
          ),
        ],
      ),
    );
  }
}

class _RingkasanCollection extends StatelessWidget {
  const _RingkasanCollection({required this.layanan});

  final LayananData layanan;

  @override
  Widget build(BuildContext context) {
    final cases = layanan.streamDaftarCase();
    final pesanan = layanan.streamPesananSaya();
    final profil = layanan.streamProfilSaya();

    return LayoutBuilder(
      builder: (context, constraints) {
        final kolom = constraints.maxWidth >= 760 ? 3 : 1;
        final lebar = kolom == 3
            ? (constraints.maxWidth - 2 * AppSpacing.xs) / 3
            : constraints.maxWidth;
        return Wrap(
          spacing: AppSpacing.xs,
          runSpacing: AppSpacing.xs,
          children: [
            SizedBox(
              width: lebar,
              child: _KartuCollection(
                nama: 'users',
                keterangan: 'Profil · Doc ID = uid',
                ikon: Icons.person_outline_rounded,
                stream: profil.map((p) => p == null ? 0 : 1),
              ),
            ),
            SizedBox(
              width: lebar,
              child: _KartuCollection(
                nama: 'cases',
                keterangan: 'Master case · auto-seed',
                ikon: Icons.phone_iphone_outlined,
                stream: cases.map((list) => list.length),
              ),
            ),
            SizedBox(
              width: lebar,
              child: _KartuCollection(
                nama: 'orders',
                keterangan: 'Pesanan · denormalisasi',
                ikon: Icons.receipt_outlined,
                stream: pesanan.map((list) => list.length),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _KartuCollection extends StatelessWidget {
  const _KartuCollection({
    required this.nama,
    required this.keterangan,
    required this.ikon,
    required this.stream,
  });

  final String nama;
  final String keterangan;
  final IconData ikon;
  final Stream<int> stream;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
      ),
      child: StreamBuilder<int>(
        stream: stream,
        builder: (context, snapshot) {
          final jumlah = snapshot.data ?? 0;
          final gagal = snapshot.hasError;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(ikon, color: AppColors.primaryDark, size: 22),
                  const SizedBox(width: AppSpacing.xs),
                  Expanded(
                    child: Text(
                      nama,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                gagal
                    ? '—'
                    : snapshot.connectionState == ConnectionState.waiting &&
                            !snapshot.hasData
                        ? '…'
                        : '$jumlah dokumen',
                style: AppTypography.subtitle.copyWith(fontSize: 20),
              ),
              const SizedBox(height: 2),
              Text(
                gagal ? 'Periksa Rules / koneksi' : keterangan,
                style: AppTypography.caption.copyWith(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _Pintasan extends StatelessWidget {
  const _Pintasan({
    required this.ikon,
    required this.judul,
    required this.keterangan,
    required this.rute,
  });

  final IconData ikon;
  final String judul;
  final String keterangan;
  final String rute;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.xs),
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
          onTap: () => context.push(rute),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.sm),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.border),
              borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
            ),
            child: Row(
              children: [
                Icon(ikon, color: AppColors.primaryDark),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        judul,
                        style: AppTypography.caption
                            .copyWith(fontWeight: FontWeight.w700),
                      ),
                      Text(
                        keterangan,
                        style: AppTypography.caption.copyWith(
                          fontSize: 13,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _KotakCatatan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.primarySurface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(AppSpacing.radiusSm),
      ),
      child: Text(
        'Pemetaan ERD → Firestore: users/{uid}, cases/{id_case}, orders/{auto-ID}.\n'
        'Denormalisasi: nama_case disalin ke orders karena Firestore tidak '
        'mendukung JOIN. Security Rules: allow read, write: if request.auth != null.\n'
        'Batas Minggu 10: hanya Create & Read; Update/Delete dibahas Minggu 11.',
        style: AppTypography.caption.copyWith(fontSize: 13),
      ),
    );
  }
}
