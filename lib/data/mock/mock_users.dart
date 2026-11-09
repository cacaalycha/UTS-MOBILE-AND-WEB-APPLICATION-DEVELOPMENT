import '../../models/user_model.dart';

/// Akun mock untuk login simulasi.
///
/// Kredensial demo:
/// - Pembeli : pembeli@caca.test  / 123456
/// - Admin   : admin@caca.test    / 123456
class MockAccount {
  const MockAccount({required this.user, required this.password});

  final UserModel user;
  final String password;
}

const List<MockAccount> mockAccounts = [
  MockAccount(
    user: UserModel(
      id: 'u001',
      name: 'Alysha Syafiya',
      email: 'pembeli@caca.test',
      role: UserRole.pembeli,
      phone: '081234567890',
      address: 'Jl. Melati No. 12, Bandung, Jawa Barat',
    ),
    password: '123456',
  ),
  MockAccount(
    user: UserModel(
      id: 'u002',
      name: 'Admin Caca',
      email: 'admin@caca.test',
      role: UserRole.admin,
      phone: '089876543210',
      address: 'Toko Case Caca, Jl. Cihampelas No. 88, Bandung',
    ),
    password: '123456',
  ),
];
