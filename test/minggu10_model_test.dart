import 'package:case_iphone_caca/data/data_simulasi.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit test model 3 collection Minggu 10: toMap/fromMap, denormalisasi,
/// dan pembacaan Timestamp tanpa mengimpor Firebase.
void main() {
  group('PenggunaFirestore (users/{uid})', () {
    test('toMap/fromMap bolak-balik tanpa kehilangan field', () {
      const profil = PenggunaFirestore(
        idPengguna: 'uid-123',
        namaLengkap: 'Alysha Syafiya',
        email: 'alysha@caca.test',
        nomorTelepon: '08123456789',
        peran: 'mahasiswa',
      );
      final hasil = PenggunaFirestore.fromMap(profil.toMap());

      expect(hasil.idPengguna, 'uid-123');
      expect(hasil.namaLengkap, 'Alysha Syafiya');
      expect(hasil.email, 'alysha@caca.test');
      expect(hasil.nomorTelepon, '08123456789');
      expect(hasil.namaTampil, 'Alysha Syafiya');
    });

    test('docId dipakai sebagai fallback id_pengguna', () {
      final hasil = PenggunaFirestore.fromMap(
        <String, dynamic>{'email': 'x@caca.test'},
        docId: 'uid-fallback',
      );
      expect(hasil.idPengguna, 'uid-fallback');
      expect(hasil.namaTampil, 'x');
    });
  });

  group('CaseKatalog (cases/{id_case})', () {
    test('toMap/fromMap menjaga tipe angka dan array', () {
      final item = daftarCaseAwal[0];
      final hasil = CaseKatalog.fromMap(item.toMap());

      expect(hasil.idCase, 'c001');
      expect(hasil.harga, 89000);
      expect(hasil.stok, 24);
      expect(hasil.fitur, <String>['Slim', 'Anti-Yellowing']);
      expect(hasil.modelKompatibel, isNotEmpty);
      expect(hasil.tersedia, isTrue);
    });

    test('auto-seed berisi 4 case dengan id unik', () {
      expect(daftarCaseAwal, hasLength(4));
      expect(
        daftarCaseAwal.map((item) => item.idCase).toSet(),
        hasLength(4),
      );
    });
  });

  group('PesananFirestore (orders/{auto-ID})', () {
    test('nama_case tersimpan (denormalisasi) agar tanpa JOIN', () {
      const pesanan = PesananFirestore(
        idPesanan: 'ORD-1',
        idPengguna: 'uid-1',
        idCase: 'c001',
        namaCase: 'Caca Clear Shield Pro Max',
        namaModelIphone: 'iPhone 16 Pro Max',
        jumlah: 2,
        hargaSatuan: 89000,
        totalHarga: 178000,
        tanggal: '2026-11-16',
        jam: '08.00',
      );

      final map = pesanan.toMap();
      expect(map['nama_case'], 'Caca Clear Shield Pro Max');
      expect(map['id_case'], 'c001');

      final hasil = PesananFirestore.fromMap(map);
      expect(hasil.namaCase, 'Caca Clear Shield Pro Max');
      expect(hasil.totalHarga, 178000);
      expect(hasil.status, statusMenunggu);
    });
  });

  group('bacaWaktu & formatTanggal', () {
    test('Timestamp-like (duck typing) tetap terbaca', () {
      final hasil = bacaWaktu(_TimestampPalsu(DateTime(2026, 11, 16)));
      expect(hasil, DateTime(2026, 11, 16));
    });

    test('String ISO, DateTime, dan null', () {
      expect(bacaWaktu('2026-11-16T10:00:00'), isA<DateTime>());
      expect(bacaWaktu(DateTime(2026)), DateTime(2026));
      expect(bacaWaktu(null), isNull);
      expect(bacaWaktu(12345), isNull);
    });

    test('formatTanggal selalu yyyy-MM-dd', () {
      expect(formatTanggal(DateTime(2026, 1, 5)), '2026-01-05');
      expect(formatTanggal(DateTime(2026, 11, 16)), '2026-11-16');
    });
  });
}

class _TimestampPalsu {
  const _TimestampPalsu(this._waktu);
  final DateTime _waktu;
  DateTime toDate() => _waktu;
}
