import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'halaman_utama.dart';
import 'masuk_page.dart';

/// Gerbang status login.
///
/// `authStateChanges()` memberi kabar setiap kali status login berubah, sehingga
/// halaman yang tampil selalu mengikuti status terakhir. Kode pada `MasukPage`
/// tidak perlu memanggil [Navigator]. Karena sesi disimpan Firebase, pengguna
/// tetap masuk setelah browser di-refresh.
class CekStatusLogin extends StatelessWidget {
  const CekStatusLogin({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
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
        if (snapshot.hasData) return const HalamanUtama();
        return const MasukPage();
      },
    );
  }
}
