import 'package:flutter_test/flutter_test.dart';
import 'package:case_iphone_caca/utils/validasi_auth.dart';

/// Unit test untuk `lib/utils/validasi_auth.dart`.
///
/// Sengaja tidak mengimpor Firebase sama sekali, mengikuti catatan modul
/// "Widget test gagal karena Firebase". Pesan yang diuji persis sama dengan
/// tabel pada bagian 4 dan 6 modul Minggu 9.
void main() {
  group('validasiEmail', () {
    test('kosong / null → Email wajib diisi', () {
      expect(validasiEmail(''), 'Email wajib diisi');
      expect(validasiEmail('   '), 'Email wajib diisi');
      expect(validasiEmail(null), 'Email wajib diisi');
    });

    test('format salah → Format email belum benar', () {
      expect(validasiEmail('alysha'), 'Format email belum benar');
      expect(validasiEmail('alysha@'), 'Format email belum benar');
      expect(validasiEmail('alysha@gmail'), 'Format email belum benar');
      expect(validasiEmail('alysha @gmail.com'), 'Format email belum benar');
    });

    test('format benar → null (spasi tepi dibuang)', () {
      expect(validasiEmail('alysha@caca.test'), isNull);
      expect(validasiEmail('  alysha@caca.test  '), isNull);
    });
  });

  group('validasiPassword', () {
    test('kosong → Password wajib diisi', () {
      expect(validasiPassword(''), 'Password wajib diisi');
      expect(validasiPassword(null), 'Password wajib diisi');
    });

    test('kurang dari 6 karakter → Password minimal 6 karakter', () {
      expect(validasiPassword('12345'), 'Password minimal 6 karakter');
    });

    test('6 karakter atau lebih → null', () {
      expect(validasiPassword('123456'), isNull);
      expect(validasiPassword('rahasia-panjang'), isNull);
    });
  });

  group('validasiUlangiPassword', () {
    test('kosong → Ulangi password', () {
      expect(validasiUlangiPassword('', '123456'), 'Ulangi password');
      expect(validasiUlangiPassword(null, '123456'), 'Ulangi password');
    });

    test('tidak sama → Password tidak sama', () {
      expect(
        validasiUlangiPassword('654321', '123456'),
        'Password tidak sama',
      );
    });

    test('sama → null', () {
      expect(validasiUlangiPassword('123456', '123456'), isNull);
    });
  });

  group('pesanKesalahanAuth — 7 kode pada tabel modul', () {
    const tabel = <String, String>{
      'invalid-credential': 'Email atau password salah',
      'invalid-email': 'Format email belum benar',
      'email-already-in-use': 'Email sudah terdaftar. Silakan masuk.',
      'weak-password': 'Password terlalu lemah, minimal 6 karakter',
      'too-many-requests': 'Terlalu banyak percobaan. Coba lagi nanti.',
      'network-request-failed':
          'Tidak dapat terhubung. Periksa koneksi internet.',
      'operation-not-allowed':
          'Login email/password belum diaktifkan di Firebase Console',
    };

    tabel.forEach((kode, harapan) {
      test('$kode diterjemahkan dengan benar', () {
        expect(pesanKesalahanAuth(kode), harapan);
      });
    });

    test('kode lama disamakan (perlindungan enumerasi email)', () {
      for (final kode in <String>['wrong-password', 'user-not-found']) {
        expect(
          pesanKesalahanAuth(kode),
          pesanKesalahanAuth('invalid-credential'),
        );
      }
    });

    test('kode tak dikenal → pesan umum, bukan pesan teknis', () {
      expect(
        pesanKesalahanAuth('kode-asing'),
        'Terjadi kesalahan. Silakan coba lagi.',
      );
      expect(pesanKesalahanAuth(''), 'Terjadi kesalahan. Silakan coba lagi.');
    });
  });
}
