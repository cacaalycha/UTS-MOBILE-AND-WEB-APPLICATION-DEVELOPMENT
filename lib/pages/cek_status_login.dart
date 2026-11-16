import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../firebase_katalog_app.dart';
import 'halaman_utama.dart';
import 'masuk_page.dart';

/// Setel ke `false` bila dosen ingin melihat Halaman Utama sederhana
/// (email + UID + tombol Keluar) persis seperti contoh modul Minggu 9.
/// Nilai `true` = setelah login langsung masuk katalog **Beranda** UTS.
const bool tampilkanKatalogSetelahLogin = true;

/// Gerbang status login.
///
/// `authStateChanges()` tetap menjadi sumber utama sesuai modul Minggu 9,
/// sehingga tidak ada [Navigator] dan sesi tetap tersimpan setelah refresh.
///
/// Tambahan perbaikan: pada Chrome mode debug, `firebase_auth_web` kadang
/// terlambat (atau gagal) mengirim event setelah `signInWithEmailAndPassword`
/// selesai — akibatnya halaman tidak berpindah walaupun akun sudah terdaftar
/// di Console. Karena itu gerbang juga menyimpan hasil aksi login/daftar/logout
/// sebagai cadangan: begitu `currentUser` terisi, halaman utama langsung
/// ditampilkan; begitu tombol Keluar ditekan, halaman Masuk langsung tampil.
class CekStatusLogin extends StatefulWidget {
  const CekStatusLogin({super.key});

  @override
  State<CekStatusLogin> createState() => _CekStatusLoginState();
}

class _CekStatusLoginState extends State<CekStatusLogin> {
  /// Cadangan bila stream belum sempat mengirim event User.
  User? _penggunaDariAksi;

  /// Penentu eksplisit setelah logout, supaya event lama dari stream tidak
  /// membuat halaman utama tetap tampil.
  bool _baruSajaKeluar = false;

  /// Nama lengkap dari form Daftar (Minggu 10), diteruskan ke `users/{uid}`.
  String? _namaPendaftaran;

  void _sinkronkanPengguna() {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null && mounted) {
      setState(() {
        _penggunaDariAksi = user;
        _baruSajaKeluar = false;
      });
    }
  }

  /// Dipanggil `MasukPage` tepat setelah login/daftar berhasil.
  void _setelahBerhasil(String? namaLengkap) {
    _namaPendaftaran = namaLengkap;
    _baruSajaKeluar = false;
    _sinkronkanPengguna();
    // currentUser pada web bisa terisi satu frame lebih lambat.
    Future<void>.delayed(const Duration(milliseconds: 300), () {
      if (mounted && _penggunaDariAksi == null) _sinkronkanPengguna();
    });
  }

  /// Logout membersihkan cadangan, kalau tidak halaman utama akan selalu
  /// dianggap aktif walaupun stream sudah mengirim null.
  Future<void> _keluar() async {
    if (mounted) {
      setState(() {
        _penggunaDariAksi = null;
        _baruSajaKeluar = true;
      });
    }
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final pengguna = _baruSajaKeluar
            ? null
            : (snapshot.data ?? _penggunaDariAksi);

        if (!_baruSajaKeluar &&
            pengguna == null &&
            snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!_baruSajaKeluar && pengguna == null && snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'Gagal memeriksa status login.\n${snapshot.error}',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        // AsyncSnapshot<User?>.hasData bernilai true hanya saat data != null.
        if (pengguna != null) {
          return tampilkanKatalogSetelahLogin
              ? FirebaseKatalogApp(
                  onKeluar: _keluar,
                  namaPendaftaran: _namaPendaftaran,
                )
              : HalamanUtama(onKeluar: _keluar);
        }
        return MasukPage(onBerhasil: _setelahBerhasil);
      },
    );
  }
}
