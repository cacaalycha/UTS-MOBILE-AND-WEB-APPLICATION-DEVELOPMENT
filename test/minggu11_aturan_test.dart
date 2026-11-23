import 'package:case_iphone_caca/data/data_simulasi.dart';
import 'package:flutter_test/flutter_test.dart';

PesananFirestore _pesanan({
  String id = 'o1',
  String uid = 'uid-a',
  String idCase = 'c001',
  String tanggal = '2026-12-01',
  String jam = '09.00',
  String status = statusMenunggu,
}) =>
    PesananFirestore(
      idPesanan: id,
      idPengguna: uid,
      idCase: idCase,
      namaCase: 'Caca Clear Shield Pro Max',
      namaModelIphone: 'iPhone 15 Pro Max',
      jumlah: 1,
      hargaSatuan: 89000,
      totalHarga: 89000,
      tanggal: tanggal,
      jam: jam,
      status: status,
    );

void main() {
  group('pastikanBolehDiubah — aturan bisnis Minggu 11', () {
    test('pemilik + status Menunggu diizinkan', () {
      expect(
        () => pastikanBolehDiubah(
          data: _pesanan().toMap(),
          uidAktif: 'uid-a',
          aksi: 'ubah',
        ),
        returnsNormally,
      );
    });

    test('bukan pemilik ditolak dengan pesan jelas', () {
      expect(
        () => pastikanBolehDiubah(
          data: _pesanan().toMap(),
          uidAktif: 'uid-b',
          aksi: 'hapus',
        ),
        throwsA(
          isA<OperasiDitolakException>().having(
            (e) => e.pesan,
            'pesan',
            contains('pemilik'),
          ),
        ),
      );
    });

    test('status bukan Menunggu ditolak', () {
      expect(
        () => pastikanBolehDiubah(
          data: _pesanan(status: statusDibatalkan).toMap(),
          uidAktif: 'uid-a',
          aksi: 'ubah',
        ),
        throwsA(isA<OperasiDitolakException>()),
      );
    });

    test('properti bisaDiubah mengikuti status', () {
      expect(_pesanan().bisaDiubah, isTrue);
      expect(_pesanan(status: statusDibatalkan).bisaDiubah, isFalse);
    });
  });

  group('adaBentrokPesanan', () {
    final lama = _pesanan(id: 'o1');

    test('tanpa abaikanId, dokumen sendiri terhitung bentrok', () {
      expect(
        adaBentrokPesanan(
          daftar: <PesananFirestore>[lama],
          idCase: 'c001',
          tanggal: '2026-12-01',
          jam: '09.00',
        ),
        isTrue,
      );
    });

    test('dengan abaikanId, dokumen sendiri tidak ditolak saat diubah', () {
      expect(
        adaBentrokPesanan(
          daftar: <PesananFirestore>[lama],
          idCase: 'c001',
          tanggal: '2026-12-01',
          jam: '09.00',
          abaikanId: 'o1',
        ),
        isFalse,
      );
    });

    test('pesanan Dibatalkan tidak menghalangi', () {
      expect(
        adaBentrokPesanan(
          daftar: <PesananFirestore>[
            _pesanan(id: 'o2', status: statusDibatalkan),
          ],
          idCase: 'c001',
          tanggal: '2026-12-01',
          jam: '09.00',
        ),
        isFalse,
      );
    });
  });

  test('field audit diubah_pada ikut tersimpan di toMap/fromMap', () {
    final waktu = DateTime(2026, 11, 23, 10, 30);
    final pesanan = PesananFirestore(
      idPesanan: 'o1',
      idPengguna: 'uid-a',
      idCase: 'c001',
      namaCase: 'Caca Clear Shield Pro Max',
      namaModelIphone: 'iPhone 15 Pro Max',
      jumlah: 1,
      hargaSatuan: 89000,
      totalHarga: 89000,
      tanggal: '2026-12-01',
      jam: '09.00',
      dibuatPada: DateTime(2026, 11, 22),
      diubahPada: waktu,
    );

    final hasil = PesananFirestore.fromMap(pesanan.toMap());
    expect(hasil.diubahPada, waktu);
    expect(hasil.dibuatPada, DateTime(2026, 11, 22));
  });
}
