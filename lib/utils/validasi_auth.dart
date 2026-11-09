/// Validator form dan penerjemah kode error untuk praktikum Minggu 9.
///
/// Sengaja dipisah dari `core/utils/validators.dart` milik prototipe UTS karena
/// modul meminta **pesan teks persis** sesuai tabel pada bagian 4 dan 6.
/// File ini murni fungsi (tidak mengimpor Firebase) sehingga dapat diuji unit
/// tanpa inisialisasi Firebase — mengikuti catatan "Widget test gagal karena
/// Firebase" pada bagian Masalah umum.
library;

const _emailRegex = r'^[^@\s]+@[^@\s]+\.[^@\s]+$';

/// Email: wajib diisi dan harus berformat email.
String? validasiEmail(String? nilai) {
  final email = nilai?.trim() ?? '';
  if (email.isEmpty) return 'Email wajib diisi';
  if (!RegExp(_emailRegex).hasMatch(email)) {
    return 'Format email belum benar';
  }
  return null;
}

/// Password: wajib diisi, minimal 6 karakter.
String? validasiPassword(String? nilai) {
  final password = nilai ?? '';
  if (password.isEmpty) return 'Password wajib diisi';
  if (password.length < 6) return 'Password minimal 6 karakter';
  return null;
}

/// Ulangi password (hanya pada mode Daftar): wajib dan harus sama.
String? validasiUlangiPassword(String? nilai, String asli) {
  final ulangi = nilai ?? '';
  if (ulangi.isEmpty) return 'Ulangi password';
  if (ulangi != asli) return 'Password tidak sama';
  return null;
}

/// Menerjemahkan `FirebaseAuthException.code` menjadi pesan yang dipahami
/// pengguna (tabel bagian 6 modul).
///
/// `invalid-credential`, `wrong-password`, dan `user-not-found` sengaja
/// **disamakan**: project Firebase baru mengaktifkan perlindungan enumerasi
/// email, sehingga orang lain tidak dapat menebak email mana yang terdaftar.
String pesanKesalahanAuth(String kode) {
  switch (kode) {
    case 'invalid-credential':
    case 'wrong-password':
    case 'user-not-found':
      return 'Email atau password salah';
    case 'invalid-email':
      return 'Format email belum benar';
    case 'email-already-in-use':
      return 'Email sudah terdaftar. Silakan masuk.';
    case 'weak-password':
      return 'Password terlalu lemah, minimal 6 karakter';
    case 'too-many-requests':
      return 'Terlalu banyak percobaan. Coba lagi nanti.';
    case 'network-request-failed':
      return 'Tidak dapat terhubung. Periksa koneksi internet.';
    case 'operation-not-allowed':
      return 'Login email/password belum diaktifkan di Firebase Console';
    default:
      return 'Terjadi kesalahan. Silakan coba lagi.';
  }
}
