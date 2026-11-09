import '../../models/user_model.dart';

/// Kontrak autentikasi.
///
/// Saat Firebase siap, buat `FirebaseAuthRepository` yang mengimplementasikan
/// interface ini — UI dan provider tidak perlu diubah.
abstract class AuthRepository {
  /// Akun yang sedang login, null jika belum login.
  UserModel? get currentUser;

  /// Login dengan email & password.
  /// Melempar [AuthException] jika gagal.
  Future<UserModel> login({required String email, required String password});

  /// Registrasi akun pembeli baru.
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  });

  Future<void> logout();
}

/// Kegagalan autentikasi yang pesannya aman ditampilkan ke pengguna.
class AuthException implements Exception {
  AuthException(this.message);

  final String message;

  @override
  String toString() => message;
}
