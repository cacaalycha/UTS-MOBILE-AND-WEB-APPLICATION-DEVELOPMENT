import 'package:flutter/material.dart';

import 'app.dart';

/// Titik masuk khusus **prototipe UTS**, tanpa ketergantungan Firebase.
///
/// Dipakai untuk membangun demo GitHub Pages agar demo tidak menjalankan
/// `Firebase.initializeApp()` dan tetap menampilkan prototipe UTS. SDK JS
/// Firebase hanya disuntikkan saat inisialisasi, jadi tidak pernah dimuat di
/// demo ini:
///
/// ```
/// MSYS_NO_PATHCONV=1 flutter build web --release -t lib/main_uts.dart \
///   --base-href "/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/"
/// ```
///
/// `flutter run` / `flutter test` tanpa flag tetap memakai `lib/main.dart`,
/// yang otomatis jatuh ke mode mock bila konfigurasi Firebase belum diisi.
void main() {
  runApp(const CaseIphoneCacaApp());
}
