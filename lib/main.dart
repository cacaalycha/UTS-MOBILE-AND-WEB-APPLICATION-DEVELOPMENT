import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'app.dart';
import 'firebase_login_app.dart';
import 'firebase_options.dart';

/// Titik masuk aplikasi.
///
/// Dua mode:
///  * **Ada konfigurasi Firebase** (lima `--dart-define=FIREBASE_*`) →
///    praktikum Minggu 9: inisialisasi Firebase lalu [FirebaseLoginApp] dengan
///    gerbang `CekStatusLogin`.
///  * **Tanpa konfigurasi** → prototipe UTS (repository mock) lewat
///    [CaseIphoneCacaApp]. Ini menjaga `flutter test` dan demo GitHub Pages
///    tetap berjalan tanpa project Firebase, sesuai catatan modul bagian
///    "Masalah umum → Widget test gagal karena Firebase".
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final pakaiFirebase = DefaultFirebaseOptions.isConfigured;

  if (pakaiFirebase) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  runApp(
    pakaiFirebase ? const FirebaseLoginApp() : const CaseIphoneCacaApp(),
  );
}
