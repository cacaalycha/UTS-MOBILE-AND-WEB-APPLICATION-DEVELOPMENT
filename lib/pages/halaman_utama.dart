import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants/colors.dart';

/// Halaman utama yang hanya terbuka setelah login.
///
/// Tombol **Keluar** ada di app bar (sesuai modul) dan juga disediakan di badan
/// halaman supaya mudah diuji teman. `signOut()` memicu `authStateChanges()`
/// sehingga `CekStatusLogin` langsung menampilkan `MasukPage` — tanpa
/// pemanggilan navigasi manual.
class HalamanUtama extends StatelessWidget {
  const HalamanUtama({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final tema = Theme.of(context);
    final penyedia = user == null || user.providerData.isEmpty
        ? 'Email/Password'
        : user.providerData.first.providerId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Case iPhone Caca'),
        backgroundColor: AppColors.primarySurface,
        actions: [
          IconButton(
            tooltip: 'Keluar',
            icon: const Icon(Icons.logout),
            onPressed: () => FirebaseAuth.instance.signOut(),
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.check_circle_outline_rounded,
                  size: 56,
                  color: AppColors.success,
                ),
                const SizedBox(height: 12),
                Text(
                  'Berhasil masuk',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.headlineSmall
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text(
                  'Halaman ini hanya dapat dibuka oleh pengguna yang '
                  'sudah terautentikasi.',
                  textAlign: TextAlign.center,
                  style: tema.textTheme.bodyMedium
                      ?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 24),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Akun aktif',
                          style: tema.textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        _BarisInfo(
                          label: 'Email',
                          nilai: user?.email ?? '(tidak tersedia)',
                        ),
                        _BarisInfo(
                          label: 'UID',
                          nilai: user?.uid ?? '(tidak tersedia)',
                        ),
                        _BarisInfo(label: 'Penyedia', nilai: penyedia),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primarySurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    'Coba refresh browser: sesi login tetap tersimpan oleh '
                    'Firebase Authentication. Data katalog dan keranjang '
                    'masih hilang karena belum memakai Firestore — itulah '
                    'pekerjaan Minggu 10.',
                    style: tema.textTheme.bodyMedium
                        ?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 24),
                OutlinedButton.icon(
                  onPressed: () => FirebaseAuth.instance.signOut(),
                  icon: const Icon(Icons.logout),
                  label: const Text('Keluar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _BarisInfo extends StatelessWidget {
  const _BarisInfo({required this.label, required this.nilai});

  final String label;
  final String nilai;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 84,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(child: Text(nilai)),
        ],
      ),
    );
  }
}
