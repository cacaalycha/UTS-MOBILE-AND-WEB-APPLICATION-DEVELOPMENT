import 'package:case_iphone_caca/data/data_simulasi.dart';
import 'package:case_iphone_caca/services/layanan_memori.dart';
import 'package:flutter_test/flutter_test.dart';

/// Unit test [LayananMemori] — padanan `LayananFirestore` tanpa koneksi
/// internet. Menguji Create, Read, aturan bisnis cegah bentrok, auto-seed,
/// dan isolasi data per pengguna (kasus uji 1, 2, dan 4 pada modul).
void main() {
  late LayananMemori layanan;

  setUp(() {
    layanan = LayananMemori(uid: 'uid-pertama');
  });

  tearDown(() => layanan.dispose());

  Future<void> seed() async {
    await layanan.simpanPenggunaSaatLogin(
      uid: 'uid-pertama',
      email: 'pertama@caca.test',
      namaLengkap: 'Alysha Syafiya',
    );
    await layanan.isiCaseAwalJikaKosong();
  }

  test('simpanPenggunaSaatLogin idempoten (tidak menimpa profil)', () async {
    await seed();
    await layanan.simpanPenggunaSaatLogin(
      uid: 'uid-pertama',
      email: 'lain@caca.test',
      namaLengkap: 'Nama Lain',
    );

    expect(layanan.penggunaTersimpan, hasLength(1));
    expect(
      layanan.penggunaTersimpan['uid-pertama']!.namaLengkap,
      'Alysha Syafiya',
    );
  });

  test('auto-seed cases hanya sekali, berisi 4 dokumen', () async {
    await seed();
    expect(layanan.casesTersimpan, hasLength(4));

    await layanan.isiCaseAwalJikaKosong();
    expect(layanan.casesTersimpan, hasLength(4));
  });

  test('streamDaftarCase mengirim nilai awal', () async {
    await seed();
    final daftar = await layanan.streamDaftarCase().first;
    expect(daftar, hasLength(4));
  });

  test('kasus uji 1 — pesanan valid tersimpan ke orders', () async {
    await seed();
    final pesanan = await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 2,
      tanggal: '2026-11-16',
      jam: '08.00',
    );

    expect(pesanan.namaCase, daftarCaseAwal.first.namaCase);
    expect(pesanan.totalHarga, 178000);
    expect(layanan.pesananTersimpan, hasLength(1));
    expect((await layanan.streamPesananSaya().first), hasLength(1));
  });

  test('kasus uji 2 — jadwal bentrok ditolak, dokumen tidak bertambah',
      () async {
    await seed();
    await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 1,
      tanggal: '2026-11-16',
      jam: '08.00',
    );

    await expectLater(
      layanan.tambahPesanan(
        caseItem: daftarCaseAwal.first,
        namaModelIphone: 'iPhone 16 Pro Max',
        jumlah: 1,
        tanggal: '2026-11-16',
        jam: '08.00',
      ),
      throwsA(isA<PesananBentrokException>()),
    );
    expect(layanan.pesananTersimpan, hasLength(1));
  });

  test('jam berbeda pada case & tanggal sama tetap boleh', () async {
    await seed();
    await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 1,
      tanggal: '2026-11-16',
      jam: '08.00',
    );
    await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 1,
      tanggal: '2026-11-16',
      jam: '09.00',
    );
    expect(layanan.pesananTersimpan, hasLength(2));
  });

  test('kasus uji 4 — pesanan terisolasi antar akun', () async {
    await seed();
    await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 1,
      tanggal: '2026-11-16',
      jam: '08.00',
    );

    layanan.gantiPengguna('uid-kedua');
    await layanan.simpanPenggunaSaatLogin(
      uid: 'uid-kedua',
      email: 'kedua@caca.test',
      namaLengkap: 'Teman Uji',
    );

    expect(await layanan.streamPesananSaya().first, isEmpty);
    expect(layanan.pesananTersimpan, hasLength(1));
  });

  test('stream bereaksi saat dokumen baru ditambah (real-time)', () async {
    await seed();
    final aliran = layanan.streamPesananSaya().take(2).toList();

    await Future<void>.delayed(Duration.zero);
    await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 1,
      tanggal: '2026-11-16',
      jam: '08.00',
    );

    final snapshot = await aliran.timeout(const Duration(seconds: 3));
    expect(snapshot[0], isEmpty);
    expect(snapshot[1], hasLength(1));
  });

  test('simulasi error diteruskan ke StreamBuilder', () async {
    layanan.simulasiError = true;
    await expectLater(
      layanan.streamPesananSaya().first,
      throwsA(isA<StateError>()),
    );
  });

  test('pesanan terbaru diurutkan di sisi Dart', () async {
    await seed();
    layanan.isiUntukTest(
      pesanan: <PesananFirestore>[
        PesananFirestore(
          idPesanan: 'lama',
          idPengguna: 'uid-pertama',
          idCase: 'c001',
          namaCase: 'Lama',
          namaModelIphone: 'iPhone 15',
          jumlah: 1,
          hargaSatuan: 1000,
          totalHarga: 1000,
          tanggal: '2026-11-01',
          jam: '08.00',
          dibuatPada: DateTime(2026, 11, 1),
        ),
        PesananFirestore(
          idPesanan: 'baru',
          idPengguna: 'uid-pertama',
          idCase: 'c002',
          namaCase: 'Baru',
          namaModelIphone: 'iPhone 16',
          jumlah: 1,
          hargaSatuan: 2000,
          totalHarga: 2000,
          tanggal: '2026-11-16',
          jam: '09.00',
          dibuatPada: DateTime(2026, 11, 16),
        ),
      ],
    );
    final daftar = await layanan.streamPesananSaya().first;
    expect(daftar.first.idPesanan, 'baru');
  });
}
