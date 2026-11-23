import 'package:case_iphone_caca/core/theme/app_theme.dart';
import 'package:case_iphone_caca/data/data_simulasi.dart';
import 'package:case_iphone_caca/pages/minggu10/form_pesanan_page.dart';
import 'package:case_iphone_caca/pages/minggu10/pesanan_saya_page.dart';
import 'package:case_iphone_caca/services/layanan_memori.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

/// Untuk menguji penolakan "bukan pemilik" lewat UI: stream tetap menampilkan
/// semua dokumen, tetapi `hapusPesanan()` dari `LayananMemori` tetap mengecek
/// uid aktif dan menolak. Tanpa ini, dokumen akun lain tidak akan terlihat.
class LayananTampilSemua extends LayananMemori {
  @override
  Stream<List<PesananFirestore>> streamPesananSaya() =>
      Stream<List<PesananFirestore>>.value(
        List<PesananFirestore>.unmodifiable(pesananTersimpan),
      );
}

/// Widget test Minggu 11: mode ubah, menu aksi, dialog konfirmasi, dan
/// penolakan. Tetap memakai `LayananMemori()` — tidak ada Firebase di sini.
void main() {
  late LayananMemori layanan;

  setUp(() async {
    layanan = LayananMemori(uid: 'uid-uji');
    await layanan.isiCaseAwalJikaKosong();
  });

  tearDown(() => layanan.dispose());

  Widget bungkus(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: child,
      );

  /// Form memanggil `context.go()` setelah sukses, jadi test yang mengejar
  /// SnackBar sukses membutuhkan GoRouter sungguhan.
  Widget bungkusDenganRouter(Widget child) => MaterialApp.router(
        theme: AppTheme.light,
        routerConfig: GoRouter(
          initialLocation: '/',
          routes: [
            GoRoute(path: '/', builder: (_, _) => child),
            GoRoute(
              path: '/firestore/pesanan',
              builder: (_, _) => const Scaffold(
                body: Center(child: Text('Daftar pesanan')),
              ),
            ),
          ],
        ),
      );

  void viewportBesar(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  PesananFirestore pesanan({
    String id = 'o1',
    String uid = 'uid-uji',
    int jumlah = 1,
    String tanggal = '2026-12-01',
    String jam = '09.00',
    String status = statusMenunggu,
  }) =>
      PesananFirestore(
        idPesanan: id,
        idPengguna: uid,
        idCase: 'c001',
        namaCase: 'Caca Clear Shield Pro Max',
        namaModelIphone: 'iPhone 15 Pro Max',
        jumlah: jumlah,
        hargaSatuan: 89000,
        totalHarga: (89000 * jumlah).toDouble(),
        tanggal: tanggal,
        jam: jam,
        status: status,
        catatan: 'catatan lama',
        dibuatPada: DateTime(2026, 11, 20),
      );

  Future<void> bukaMenuHapus(WidgetTester tester) async {
    await tester.tap(find.byKey(const Key('menu_aksi_pesanan')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Hapus'));
    await tester.pumpAndSettle();
  }

  testWidgets('Mode ubah: isian terisi data lama dan tombol Simpan Perubahan',
      (tester) async {
    final awal = pesanan();
    layanan.isiUntukTest(pesanan: <PesananFirestore>[awal]);
    viewportBesar(tester);

    await tester.pumpWidget(
      bungkus(FormPesananPage(layanan: layanan, pesananAwal: awal)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ubah data pemesanan'), findsOneWidget);
    expect(find.text('Simpan Perubahan'), findsOneWidget);
    expect(
      tester
          .widget<EditableText>(
            find.descendant(
              of: find.byKey(const Key('field_jumlah')),
              matching: find.byType(EditableText),
            ),
          )
          .controller
          .text,
      '1',
    );
    expect(find.text('09.00'), findsWidgets);
  });

  testWidgets('Mode ubah: perubahan valid tersimpan, field audit utuh',
      (tester) async {
    final awal = pesanan();
    layanan.isiUntukTest(pesanan: <PesananFirestore>[awal]);
    viewportBesar(tester);

    await tester.pumpWidget(
      bungkusDenganRouter(
        FormPesananPage(layanan: layanan, pesananAwal: awal),
      ),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_jumlah')), '3');
    await tester.tap(find.byKey(const Key('tombol_kirim_pesanan')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('Perubahan pesanan berhasil'), findsOneWidget);
    final hasil = layanan.pesananTersimpan.single;
    expect(hasil.jumlah, 3);
    expect(hasil.dibuatPada, awal.dibuatPada);
    expect(hasil.idPengguna, awal.idPengguna);
    expect(hasil.diubahPada, isNotNull);
  });

  testWidgets('Mode ubah: bentrok dengan pesanan lain ditolak',
      (tester) async {
    final awal = pesanan(id: 'o1');
    final lain = pesanan(id: 'o2');
    layanan.isiUntukTest(
      pesanan: <PesananFirestore>[awal, lain],
    );
    viewportBesar(tester);

    await tester.pumpWidget(
      bungkus(
        FormPesananPage(layanan: layanan, pesananAwal: awal),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tombol_kirim_pesanan')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('sudah dipesan pada tanggal'), findsOneWidget);
    expect(layanan.pesananTersimpan.first.jumlah, 1);
  });

  testWidgets('Menu aksi aktif hanya untuk status Menunggu', (tester) async {
    layanan.isiUntukTest(pesanan: <PesananFirestore>[pesanan()]);
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('menu_aksi_pesanan')));
    await tester.pumpAndSettle();

    final ubah = tester.widget<PopupMenuItem<String>>(
      find.ancestor(
        of: find.text('Ubah'),
        matching: find.byType(PopupMenuItem<String>),
      ),
    );
    final hapus = tester.widget<PopupMenuItem<String>>(
      find.ancestor(
        of: find.text('Hapus'),
        matching: find.byType(PopupMenuItem<String>),
      ),
    );
    expect(ubah.enabled, isTrue);
    expect(hapus.enabled, isTrue);
  });

  testWidgets('Menu aksi nonaktif saat status bukan Menunggu', (tester) async {
    layanan.isiUntukTest(
      pesanan: <PesananFirestore>[
        pesanan(status: statusDibatalkan),
      ],
    );
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('menu_aksi_pesanan')));
    await tester.pumpAndSettle();

    final hapus = tester.widget<PopupMenuItem<String>>(
      find.ancestor(
        of: find.text('Hapus'),
        matching: find.byType(PopupMenuItem<String>),
      ),
    );
    expect(hapus.enabled, isFalse);
  });

  testWidgets('Hapus lalu Batal: dialog tertutup, data tetap ada',
      (tester) async {
    layanan.isiUntukTest(pesanan: <PesananFirestore>[pesanan()]);
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    await bukaMenuHapus(tester);
    expect(find.text('Hapus pesanan?'), findsOneWidget);
    expect(
      find.textContaining('akan dihapus permanen'),
      findsOneWidget,
    );

    await tester.tap(find.text('Batal'));
    await tester.pumpAndSettle();

    expect(layanan.pesananTersimpan, hasLength(1));
    expect(find.text('Hapus pesanan?'), findsNothing);
  });

  testWidgets('Hapus lalu setujui: pesanan hilang dan SnackBar muncul',
      (tester) async {
    layanan.isiUntukTest(pesanan: <PesananFirestore>[pesanan()]);
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    await bukaMenuHapus(tester);
    await tester.tap(find.byKey(const Key('tombol_konfirmasi_hapus')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(layanan.pesananTersimpan, isEmpty);
    expect(find.text('Pesanan berhasil dihapus.'), findsOneWidget);
  });

  testWidgets('Hapus dokumen akun lain ditolak dengan pesan pemilik',
      (tester) async {
    final tampilSemua = LayananTampilSemua();
    addTearDown(tampilSemua.dispose);
    await tampilSemua.isiCaseAwalJikaKosong();
    tampilSemua.isiUntukTest(
      pesanan: <PesananFirestore>[pesanan(uid: 'uid-orang-lain')],
    );
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: tampilSemua)),
    );
    await tester.pumpAndSettle();

    await bukaMenuHapus(tester);
    await tester.tap(find.byKey(const Key('tombol_konfirmasi_hapus')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(tampilSemua.pesananTersimpan, hasLength(1));
    expect(find.textContaining('Hanya pemilik pesanan'), findsOneWidget);
  });
}
