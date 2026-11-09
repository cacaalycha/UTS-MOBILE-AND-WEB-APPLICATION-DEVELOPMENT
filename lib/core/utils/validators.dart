/// Validator form yang dipakai lintas halaman.
class Validators {
  Validators._();

  static final RegExp _emailRegex = RegExp(
    r'^[\w\.\-+]+@[\w\-]+\.[\w\.\-]+$',
  );

  /// Mengembalikan pesan error atau null jika valid.
  static String? email(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Email wajib diisi.';
    }
    if (!_emailRegex.hasMatch(text)) {
      return 'Format email tidak valid.';
    }
    return null;
  }

  static String? password(String? value) {
    final text = value ?? '';
    if (text.isEmpty) {
      return 'Kata sandi wajib diisi.';
    }
    if (text.length < 6) {
      return 'Kata sandi minimal 6 karakter.';
    }
    return null;
  }

  static String? confirmPassword(String? value, String original) {
    if ((value ?? '').isEmpty) {
      return 'Konfirmasi kata sandi wajib diisi.';
    }
    if (value != original) {
      return 'Konfirmasi kata sandi tidak sama.';
    }
    return null;
  }

  static String? required(String? value, {String label = 'Kolom'}) {
    if ((value?.trim() ?? '').isEmpty) {
      return '$label wajib diisi.';
    }
    return null;
  }

  static String? name(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Nama wajib diisi.';
    }
    if (text.length < 3) {
      return 'Nama minimal 3 karakter.';
    }
    return null;
  }

  static String? phone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Nomor telepon wajib diisi.';
    }
    if (!RegExp(r'^[0-9+\-\s]{8,20}$').hasMatch(text)) {
      return 'Nomor telepon tidak valid.';
    }
    return null;
  }
}

/// Format rupiah sederhana tanpa dependency tambahan.
String formatRupiah(num value) {
  final isNegative = value < 0;
  final digits = value.abs().round().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write('.');
    }
    buffer.write(digits[i]);
  }
  return '${isNegative ? '-' : ''}Rp$buffer';
}
