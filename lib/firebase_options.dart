import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Konfigurasi project Firebase untuk praktikum Minggu 9.
///
/// Modul menyediakan dua jalur:
///  * **Jalur utama** — `flutterfire configure --platforms=web` membuat file ini
///    secara otomatis.
///  * **Jalur cadangan** — salin `firebaseConfig` dari *Project settings* ke
///    file ini secara manual.
///
/// Repositori ini mendukung keduanya **tanpa menyimpan nilai project di Git**:
/// nilai dibaca dari `--dart-define` saat build. Lihat
/// `docs/PANDUAN_FIREBASE_MINGGU_09.md` untuk daftar nilainya.
///
/// Catatan keamanan sesuai modul: isi `firebaseConfig` adalah **pengenal
/// project**, bukan password, jadi aman untuk di-commit. Yang tidak boleh
/// pernah ditulis di kode/README adalah password akun.
class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  // ── JALUR CADANGAN (salin manual dari Firebase Console) ────────────────
  // Bila tidak ingin memakai --dart-define, ganti kelima baris
  // String.fromEnvironment(...) di bawah dengan literal dari Console, mis.:
  //   static const String _apiKey = 'AIzaSy............';
  // Lalu jalankan cukup dengan: flutter run -d chrome
  // ────────────────────────────────────────────────────────────────────────
  static const String _apiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const String _appId = String.fromEnvironment('FIREBASE_APP_ID');
  static const String _messagingSenderId =
      String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const String _projectId =
      String.fromEnvironment('FIREBASE_PROJECT_ID');
  static const String _authDomain =
      String.fromEnvironment('FIREBASE_AUTH_DOMAIN');
  static const String _storageBucket =
      String.fromEnvironment('FIREBASE_STORAGE_BUCKET');
  static const String _measurementId =
      String.fromEnvironment('FIREBASE_MEASUREMENT_ID');

  /// `true` hanya jika kelima nilai wajib sudah diberikan lewat
  /// `--dart-define` (atau sudah ditempel manual).
  ///
  /// Ketika `false`, `main.dart` menjalankan prototipe UTS berbasis mock.
  /// Ini menyiasati masalah "Widget test gagal karena Firebase" pada modul:
  /// 26 test lama dan demo GitHub Pages tetap berjalan tanpa project Firebase.
  static bool get isConfigured =>
      _apiKey.isNotEmpty &&
      _appId.isNotEmpty &&
      _messagingSenderId.isNotEmpty &&
      _projectId.isNotEmpty &&
      _authDomain.isNotEmpty;

  /// Daftar `dart-define` yang masih kosong, untuk pesan error yang jelas.
  static List<String> get yangKosong => <String>[
        if (_apiKey.isEmpty) 'FIREBASE_API_KEY',
        if (_appId.isEmpty) 'FIREBASE_APP_ID',
        if (_messagingSenderId.isEmpty) 'FIREBASE_MESSAGING_SENDER_ID',
        if (_projectId.isEmpty) 'FIREBASE_PROJECT_ID',
        if (_authDomain.isEmpty) 'FIREBASE_AUTH_DOMAIN',
      ];

  /// Batas pertemuan ini: **target wajib Chrome**, jadi hanya opsi web yang
  /// disediakan. Platform lain sengaja ditolak agar tidak memakai konfigurasi
  /// web secara keliru.
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    throw UnsupportedError(
      'Praktikum Minggu 9 menargetkan Chrome. '
      'Jalankan: flutter run -d chrome',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: _apiKey,
    appId: _appId,
    messagingSenderId: _messagingSenderId,
    projectId: _projectId,
    authDomain: _authDomain,
    storageBucket: _storageBucket,
    measurementId: _measurementId,
  );
}
