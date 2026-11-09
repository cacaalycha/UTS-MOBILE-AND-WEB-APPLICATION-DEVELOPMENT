import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../core/constants/colors.dart';
import '../utils/validasi_auth.dart';

/// Halaman Masuk **dan** Daftar — satu halaman, dua mode.
///
/// Mengikuti pola Form Minggu 7: [Form], [GlobalKey], [TextFormField], dan
/// validator. Variabel `_modeDaftar` menentukan judul, label tombol, serta
/// munculnya kolom "Ulangi password". Tidak ada [Navigator] di sini: perpindahan
/// halaman ditangani `CekStatusLogin` lewat `authStateChanges()`.
class MasukPage extends StatefulWidget {
  const MasukPage({super.key});

  @override
  State<MasukPage> createState() => _MasukPageState();
}

class _MasukPageState extends State<MasukPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _ulangiController = TextEditingController();

  /// false = Masuk, true = Daftar.
  bool _modeDaftar = false;

  /// Menonaktifkan tombol + menampilkan indikator agar tidak terkirim dua kali.
  bool _sedangProses = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _ulangiController.dispose();
    super.dispose();
  }

  void _gantiMode() {
    _formKey.currentState?.reset();
    _ulangiController.clear();
    setState(() => _modeDaftar = !_modeDaftar);
  }

  Future<void> _kirim() async {
    if (!_formKey.currentState!.validate()) return;

    // Ambil ScaffoldMessenger sebelum await supaya tidak memakai BuildContext
    // setelah jeda asynchronous (pola yang ditunjukkan modul).
    final pesan = ScaffoldMessenger.of(context);
    pesan.hideCurrentSnackBar();
    setState(() => _sedangProses = true);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    try {
      if (_modeDaftar) {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      } else {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      // Berhasil: stream authStateChanges() mengganti halaman otomatis.
    } on FirebaseAuthException catch (e) {
      pesan.showSnackBar(
        SnackBar(
          content: Text(pesanKesalahanAuth(e.code)),
          backgroundColor: AppColors.error,
        ),
      );
    } catch (_) {
      pesan.showSnackBar(
        const SnackBar(
          content: Text('Terjadi kesalahan. Silakan coba lagi.'),
        ),
      );
    } finally {
      // Halaman bisa sudah dicopot CekStatusLogin saat proses selesai.
      if (mounted) setState(() => _sedangProses = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tema = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 460),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Icon(
                      Icons.phone_iphone_rounded,
                      size: 56,
                      color: AppColors.primaryDark,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _modeDaftar ? 'Daftar Akun' : 'Masuk',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.headlineSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Case iPhone Caca · Firebase Authentication (Minggu 9)',
                      textAlign: TextAlign.center,
                      style: tema.textTheme.bodyMedium
                          ?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Email',
                        hintText: 'nama@email.com',
                        prefixIcon: Icon(Icons.mail_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: validasiEmail,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _passwordController,
                      // Karakter disembunyikan sesuai butir periksa modul.
                      obscureText: true,
                      textInputAction: TextInputAction.next,
                      onFieldSubmitted: (_) {
                        if (!_modeDaftar) _kirim();
                      },
                      decoration: const InputDecoration(
                        labelText: 'Password',
                        prefixIcon: Icon(Icons.lock_outline),
                        border: OutlineInputBorder(),
                      ),
                      validator: validasiPassword,
                    ),
                    if (_modeDaftar) ...[
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: _ulangiController,
                        obscureText: true,
                        onFieldSubmitted: (_) => _kirim(),
                        decoration: const InputDecoration(
                          labelText: 'Ulangi password',
                          prefixIcon: Icon(Icons.lock_outline),
                          border: OutlineInputBorder(),
                        ),
                        validator: (nilai) => validasiUlangiPassword(
                          nilai,
                          _passwordController.text,
                        ),
                      ),
                    ],
                    const SizedBox(height: 24),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: _sedangProses ? null : _kirim,
                        child: _sedangProses
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(_modeDaftar ? 'Daftar' : 'Masuk'),
                      ),
                    ),
                    const SizedBox(height: 4),
                    TextButton(
                      onPressed: _sedangProses ? null : _gantiMode,
                      child: Text(
                        _modeDaftar
                            ? 'Sudah punya akun? Masuk'
                            : 'Belum punya akun? Daftar',
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.primarySurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Text(
                        'Gunakan email dan password simulasi. '
                        'Jangan memakai password asli Anda.',
                        textAlign: TextAlign.center,
                        style: tema.textTheme.bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
