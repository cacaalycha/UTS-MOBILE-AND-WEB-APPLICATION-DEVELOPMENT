import 'package:flutter/material.dart';

import 'core/constants/colors.dart';
import 'pages/cek_status_login.dart';

/// Akar aplikasi **praktikum Minggu 9**: Firebase Authentication.
///
/// Sengaja terpisah dari `CaseIphoneCacaApp` (prototipe UTS berbasis mock)
/// supaya 26 test lama dan demo GitHub Pages tidak bergantung pada Firebase.
/// `home` memakai [CekStatusLogin], bukan halaman langsung, sehingga halaman
/// utama hanya terbuka setelah login.
class FirebaseLoginApp extends StatelessWidget {
  const FirebaseLoginApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Case iPhone Caca — Firebase Login',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primary),
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const CekStatusLogin(),
    );
  }
}
