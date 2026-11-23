// ============================================================================
// Penentuan peran (role) pada MODE FIREBASE.
//
// Firebase Authentication hanya menyimpan uid, email, dan password — tidak ada
// field "role". Karena Minggu 9/10 belum membahas Custom Claims / Admin SDK,
// peran admin ditentukan dari daftar email yang diberikan lewat --dart-define.
//
//   --dart-define-from-file=firebase-config.json
//   { ..., "FIREBASE_ADMIN_EMAILS": "adminf@gmail.com,owner@toko.com" }
//
// Bila nilainya kosong, semua akun Firebase menjadi pembeli (perilaku lama).
// File ini sengaja TIDAK mengimpor Firebase supaya tetap bisa di-unit-test.
// ============================================================================

/// Nilai dari `--dart-define=FIREBASE_ADMIN_EMAILS=...`.
/// Boleh lebih dari satu email, dipisah koma.
const String daftarEmailAdminMentah =
    String.fromEnvironment('FIREBASE_ADMIN_EMAILS');

/// Memecah daftar email menjadi bentuk yang seragam (trim + huruf kecil).
/// Dipisah agar bisa diuji tanpa bergantung pada nilai `--dart-define`.
List<String> pecahEmailAdmin(String mentah) => mentah
    .split(',')
    .map((email) => email.trim().toLowerCase())
    .where((email) => email.isNotEmpty)
    .toList(growable: false);

List<String> daftarEmailAdmin() => pecahEmailAdmin(daftarEmailAdminMentah);

/// `true` bila [email] termasuk daftar admin mode Firebase.
bool apakahAdminFirebase(String email) {
  final bersih = email.trim().toLowerCase();
  if (bersih.isEmpty) return false;
  return daftarEmailAdmin().any((admin) => admin == bersih);
}
