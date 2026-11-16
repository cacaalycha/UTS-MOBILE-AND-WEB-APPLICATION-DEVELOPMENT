import 'package:firebase_auth/firebase_auth.dart';

import '../../../models/user_model.dart';
import '../auth_repository.dart';

/// Jembatan antara Firebase Authentication dan `AuthProvider` prototipe UTS.
///
/// Dipakai hanya setelah `CekStatusLogin` memastikan pengguna sudah login,
/// sehingga halaman katalog Beranda bisa memakai `AuthProvider`, `AppShell`,
/// dan GoRouter yang sama dengan aplikasi UTS — tanpa mengubah UI-nya.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({this.onKeluar});

  /// Aksi logout dari gerbang login. Bila ada, dipakai supaya status login
  /// cadangan ikut dibersihkan (lihat `CekStatusLogin`).
  final Future<void> Function()? onKeluar;

  UserModel? _dariUserFirebase(User? user) {
    if (user == null) return null;
    final email = user.email ?? '';
    final nama = user.displayName?.trim();
    return UserModel(
      id: user.uid,
      name: (nama == null || nama.isEmpty)
          ? (email.isEmpty ? 'Pengguna' : email.split('@').first)
          : nama,
      email: email,
      // Praktikum Minggu 9 belum memakai Firestore/role, jadi semua akun
      // Firebase diperlakukan sebagai pembeli.
      role: UserRole.pembeli,
    );
  }

  @override
  UserModel? get currentUser => _dariUserFirebase(FirebaseAuth.instance.currentUser);

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    // Normalnya tidak dipanggil: login sudah ditangani `MasukPage`.
    await FirebaseAuth.instance.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return currentUser!;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    // Normalnya tidak dipanggil: pendaftaran sudah ditangani `MasukPage`.
    await FirebaseAuth.instance.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    return currentUser!;
  }

  @override
  Future<void> logout() async {
    final aksi = onKeluar;
    if (aksi != null) {
      await aksi();
    } else {
      await FirebaseAuth.instance.signOut();
    }
  }
}
