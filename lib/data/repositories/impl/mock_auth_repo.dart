import '../../mock/mock_users.dart';
import '../../../models/user_model.dart';
import '../auth_repository.dart';

/// Implementasi autentikasi berbasis data mock (tanpa Firebase).
///
/// Semua akun disimpan di memori selama aplikasi berjalan.
class MockAuthRepository implements AuthRepository {
  MockAuthRepository() {
    // Salin akun mock agar registrasi baru tidak mengubah data konstanta.
    _accounts.addAll(mockAccounts);
  }

  final List<MockAccount> _accounts = [];
  UserModel? _currentUser;

  @override
  UserModel? get currentUser => _currentUser;

  @override
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final normalized = email.trim().toLowerCase();
    MockAccount? match;
    for (final account in _accounts) {
      if (account.user.email.toLowerCase() == normalized) {
        match = account;
        break;
      }
    }

    if (match == null) {
      throw AuthException('Email belum terdaftar.');
    }
    if (match.password != password) {
      throw AuthException('Kata sandi salah.');
    }

    _currentUser = match.user;
    return match.user;
  }

  @override
  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 400));

    final normalized = email.trim().toLowerCase();
    final exists = _accounts.any(
      (account) => account.user.email.toLowerCase() == normalized,
    );
    if (exists) {
      throw AuthException('Email sudah digunakan.');
    }

    final user = UserModel(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      name: name.trim(),
      email: normalized,
      role: UserRole.pembeli,
    );

    _accounts.add(MockAccount(user: user, password: password));
    _currentUser = user;
    return user;
  }

  @override
  Future<void> logout() async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    _currentUser = null;
  }
}
