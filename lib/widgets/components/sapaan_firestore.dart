import 'package:flutter/material.dart';

import '../../core/constants/colors.dart';
import '../../core/constants/spacing.dart';
import '../../core/constants/typography.dart';
import '../../data/data_simulasi.dart';
import '../../services/layanan_data.dart';

/// Sapaan nama pengguna yang dibaca **real-time** dari `users/{uid}`.
///
/// Padanan "Beranda menyapa pengguna dengan nama lengkapnya secara real-time"
/// pada modul Minggu 10. Menangani tiga keadaan stream: menunggu, gagal,
/// dan data (dokumen belum ada / sudah ada).
class SapaanFirestore extends StatelessWidget {
  const SapaanFirestore({
    super.key,
    required this.layanan,
    required this.namaCadangan,
    this.fontSize = 26,
  });

  final LayananData layanan;
  final String namaCadangan;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<PenggunaFirestore?>(
      stream: layanan.streamProfilSaya(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return Row(
            children: const [
              SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: AppSpacing.xs),
              Text('Memuat profil…'),
            ],
          );
        }

        if (snapshot.hasError) {
          return _SapaanTeks(
            teks: 'Halo, $namaCadangan 👋',
            fontSize: fontSize,
            keterangan: 'Profil belum dapat dimuat dari Firestore.',
          );
        }

        final profil = snapshot.data;
        if (profil == null) {
          return _SapaanTeks(
            teks: 'Halo, $namaCadangan 👋',
            fontSize: fontSize,
            keterangan:
                'Dokumen users belum terbentuk — keluar lalu masuk kembali.',
          );
        }

        return _SapaanTeks(
          teks: 'Halo, ${profil.namaTampil} 👋',
          fontSize: fontSize,
        );
      },
    );
  }
}

class _SapaanTeks extends StatelessWidget {
  const _SapaanTeks({
    required this.teks,
    required this.fontSize,
    this.keterangan,
  });

  final String teks;
  final double fontSize;
  final String? keterangan;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          teks,
          style: AppTypography.title.copyWith(fontSize: fontSize),
        ),
        if (keterangan != null) ...[
          const SizedBox(height: 4),
          Text(
            keterangan!,
            style: AppTypography.caption.copyWith(
              fontSize: 13,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
