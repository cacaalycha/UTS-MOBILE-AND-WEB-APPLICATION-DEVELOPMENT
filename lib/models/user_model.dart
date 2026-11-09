/// Peran pengguna aplikasi.
enum UserRole {
  pembeli('Pembeli'),
  admin('Admin');

  const UserRole(this.label);

  final String label;
}

/// Akun pengguna (mock — belum terhubung Firebase).
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.address = '',
  });

  final String id;
  final String name;
  final String email;
  final UserRole role;
  final String phone;
  final String address;

  bool get isAdmin => role == UserRole.admin;

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'email': email,
    'role': role.name,
    'phone': phone,
    'address': address,
  };

  factory UserModel.fromMap(Map<String, dynamic> map) => UserModel(
    id: map['id'] as String,
    name: map['name'] as String,
    email: map['email'] as String,
    role: UserRole.values.firstWhere(
      (role) => role.name == map['role'],
      orElse: () => UserRole.pembeli,
    ),
    phone: (map['phone'] as String?) ?? '',
    address: (map['address'] as String?) ?? '',
  );
}
