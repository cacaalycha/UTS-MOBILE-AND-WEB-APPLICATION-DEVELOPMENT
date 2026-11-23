import 'package:case_iphone_caca/data/data_simulasi.dart';
import 'package:case_iphone_caca/services/layanan_memori.dart';
import 'package:flutter_test/flutter_test.dart';

PesananFirestore _pesanan({
  String id = 'o1',
  String uid = 'uid-uji',
  String idCase = 'c001',
  String tanggal = '2026-12-01',
  String jam = '09.00',
  String status = statusMenunggu,
  DateTime? dibuatPada,
}) =>
    PesananFirestore(
      idPesanan: id,
      idPengguna: uid,
      idCase: idCase,
      namaCase: idCase == 'c001'
          ? 'Caca Clear Shield Pro Max'
          : 'Caca Armor Shockproof Pro Max',
      namaModelIphone: 'iPhone 15 Pro Max',
      jumlah: 1,
      hargaSatuan: 89000,
      totalHarga: 89000,
      tanggal: tanggal,
      jam: jam,
      status: status,
      dibuatPada: dibuatPada ?? DateTime(2026, 11, 20),
    );

void main() {
  late LayananMemori layanan;
  final caseItem = daftarCaseAwal.first;

  setUp(() {
    layanan = LayananMemori();
    layanan.isiUntukTest(cases: daftarCaseAwal);
  });

  group('ubahPesanan', () {
    test('perubahan valid menjaga field audit', () async {
      final awal = _pesanan();
      layanan.isiUntukTest(pesanan: <PesananFirestore>[awal]);

      final hasil = await layanan.ubahPesanan(
        idPesanan: 'o1',
        caseItem: caseItem,
        namaModelIphone: 'iPhone 14 Pro Max',
        jumlah: 2,
        tanggal: '2026-12-02',
        jam: '10.00',
        catatan: 'diubah',
      );

      expect(hasil.idPesanan, 'o1');
      expect(hasil.idPengguna, 'uid-uji');
      expect(hasil.dibuatPada, awal.dibuatPada);
      expect(hasil.status, statusMenunggu);
      expect(hasil.diubahPada, isNotNull);
      expect(hasil.jumlah, 2);
      expect(hasil.totalHarga, caseItem.harga * 2);
      expect(layanan.pesananTersimpan, hasLength(1));
      expect(layanan.pesananTersimpan.first.tanggal, '2026-12-02');
    });

    test('mengubah jam yang sama dengan dirinya sendiri tidak ditolak', () async {
      layanan.isiUntukTest(pesanan: <PesananFirestore>[_pesanan()]);

      final hasil = await layanan.ubahPesanan(
        idPesanan: 'o1',
        caseItem: caseItem,
        namaModelIphone: 'iPhone 15 Pro Max',
        jumlah: 3,
        tanggal: '2026-12-01',
        jam: '09.00',
      );
      expect(hasil.jumlah, 3);
    });

    test('bentrok dengan pesanan lain ditolak dan data lama utuh', () async {
      layanan.isiUntukTest(
        pesanan: <PesananFirestore>[
          _pesanan(id: 'o1'),
          _pesanan(id: 'o2'),
        ],
      );

      await expectLater(
        layanan.ubahPesanan(
          idPesanan: 'o1',
          caseItem: caseItem,
          namaModelIphone: 'iPhone 15 Pro Max',
          jumlah: 2,
          tanggal: '2026-12-01',
          jam: '09.00',
        ),
        throwsA(isA<PesananBentrokException>()),
      );
      expect(layanan.pesananTersimpan.first.jumlah, 1);
    });

    test('bukan pemilik ditolak', () async {
      layanan.isiUntukTest(
        pesanan: <PesananFirestore>[_pesanan(uid: 'uid-orang-lain')],
      );

      await expectLater(
        layanan.ubahPesanan(
          idPesanan: 'o1',
          caseItem: caseItem,
          namaModelIphone: 'iPhone 15 Pro Max',
          jumlah: 2,
          tanggal: '2026-12-02',
          jam: '10.00',
        ),
        throwsA(isA<OperasiDitolakException>()),
      );
    });

    test('status bukan Menunggu ditolak', () async {
      layanan.isiUntukTest(
        pesanan: <PesananFirestore>[
          _pesanan(status: statusDibatalkan),
        ],
      );

      await expectLater(
        layanan.ubahPesanan(
          idPesanan: 'o1',
          caseItem: caseItem,
          namaModelIphone: 'iPhone 15 Pro Max',
          jumlah: 2,
          tanggal: '2026-12-02',
          jam: '10.00',
        ),
        throwsA(isA<OperasiDitolakException>()),
      );
    });
  });

  group('hapusPesanan', () {
    test('pemilik menghapus dokumen sendiri', () async {
      layanan.isiUntukTest(pesanan: <PesananFirestore>[_pesanan()]);

      await layanan.hapusPesanan('o1');
      expect(layanan.pesananTersimpan, isEmpty);
    });

    test('bukan pemilik ditolak, data tetap ada', () async {
      layanan.isiUntukTest(
        pesanan: <PesananFirestore>[_pesanan(uid: 'uid-orang-lain')],
      );

      await expectLater(
        layanan.hapusPesanan('o1'),
        throwsA(isA<OperasiDitolakException>()),
      );
      expect(layanan.pesananTersimpan, hasLength(1));
    });

    test('status bukan Menunggu ditolak', () async {
      layanan.isiUntukTest(
        pesanan: <PesananFirestore>[
          _pesanan(status: statusDibatalkan),
        ],
      );

      await expectLater(
        layanan.hapusPesanan('o1'),
        throwsA(isA<OperasiDitolakException>()),
      );
      expect(layanan.pesananTersimpan, hasLength(1));
    });
  });
}
