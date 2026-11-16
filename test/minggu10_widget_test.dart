import 'package:case_iphone_caca/core/theme/app_theme.dart';
import 'package:case_iphone_caca/data/data_simulasi.dart';
import 'package:case_iphone_caca/pages/minggu10/beranda_firestore_page.dart';
import 'package:case_iphone_caca/pages/minggu10/daftar_case_page.dart';
import 'package:case_iphone_caca/pages/minggu10/form_pesanan_page.dart';
import 'package:case_iphone_caca/pages/minggu10/pesanan_saya_page.dart';
import 'package:case_iphone_caca/services/layanan_memori.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Widget test Minggu 10 memakai injeksi `LayananMemori()` — tidak ada
/// pemanggilan FirebaseFirestore.instance, sesuai catatan "Masalah umum"
/// pada modul. Menutup tiga keadaan StreamBuilder dan penolakan bentrok.
void main() {
  late LayananMemori layanan;

  setUp(() async {
    layanan = LayananMemori(uid: 'uid-uji');
    await layanan.simpanPenggunaSaatLogin(
      uid: 'uid-uji',
      email: 'uji@caca.test',
      namaLengkap: 'Alysha Syafiya',
    );
    await layanan.isiCaseAwalJikaKosong();
  });

  tearDown(() => layanan.dispose());

  Widget bungkus(Widget child) => MaterialApp(
        theme: AppTheme.light,
        home: child,
      );

  /// Form Pesanan lebih panjang dari viewport uji bawaan (800x600),
  /// jadi perbesar layar agar tombol Kirim berada di dalam area ketuk.
  void viewportBesar(WidgetTester tester) {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  testWidgets('Daftar Case menampilkan 4 case dari stream', (tester) async {
    await tester.pumpWidget(bungkus(DaftarCasePage(layanan: layanan)));
    await tester.pumpAndSettle();

    expect(find.text('Caca Clear Shield Pro Max'), findsOneWidget);
    expect(find.text('Caca Armor Shockproof Pro Max'), findsOneWidget);
    expect(find.text('Collection cases masih kosong'), findsNothing);
  });

  testWidgets('Daftar Case — keadaan kosong', (tester) async {
    final kosong = LayananMemori();
    addTearDown(kosong.dispose);
    await tester.pumpWidget(bungkus(DaftarCasePage(layanan: kosong)));
    await tester.pumpAndSettle();

    expect(find.text('Collection cases masih kosong'), findsOneWidget);
  });

  testWidgets('Daftar Case — keadaan error (snapshot.hasError)',
      (tester) async {
    final gagal = LayananMemori()..simulasiError = true;
    addTearDown(gagal.dispose);
    await tester.pumpWidget(bungkus(DaftarCasePage(layanan: gagal)));
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat daftar case'), findsOneWidget);
  });

  testWidgets('Pesanan Saya — keadaan kosong', (tester) async {
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Belum ada pesanan'), findsOneWidget);
  });

  testWidgets('Pesanan Saya — keadaan error', (tester) async {
    final gagal = LayananMemori()..simulasiError = true;
    addTearDown(gagal.dispose);
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: gagal)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Gagal memuat pesanan'), findsOneWidget);
  });

  testWidgets('Pesanan Saya menampilkan nama_case hasil denormalisasi',
      (tester) async {
    layanan.isiUntukTest(
      pesanan: <PesananFirestore>[
        PesananFirestore(
          idPesanan: 'ORD-1',
          idPengguna: 'uid-uji',
          idCase: 'c001',
          namaCase: 'Caca Clear Shield Pro Max',
          namaModelIphone: 'iPhone 16 Pro Max',
          jumlah: 2,
          hargaSatuan: 89000,
          totalHarga: 178000,
          tanggal: '2026-11-16',
          jam: '08.00',
          dibuatPada: DateTime(2026, 11, 16),
        ),
      ],
    );
    await tester.pumpWidget(
      bungkus(PesananSayaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Caca Clear Shield Pro Max'), findsOneWidget);
    expect(find.textContaining('178.000'), findsOneWidget);
  });

  testWidgets('Form Pesanan — dropdown case berasal dari stream cases',
      (tester) async {
    viewportBesar(tester);
    await tester.pumpWidget(bungkus(FormPesananPage(layanan: layanan)));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('dropdown_case')), findsOneWidget);
    expect(find.byKey(const Key('tombol_kirim_pesanan')), findsOneWidget);
    expect(find.text('Case wajib dipilih'), findsNothing);
  });

  testWidgets('Form Pesanan — jumlah tidak valid ditolak', (tester) async {
    viewportBesar(tester);
    await tester.pumpWidget(bungkus(FormPesananPage(layanan: layanan)));
    await tester.pumpAndSettle();

    await tester.enterText(find.byKey(const Key('field_jumlah')), '0');
    await tester.tap(find.byKey(const Key('tombol_kirim_pesanan')));
    await tester.pumpAndSettle();

    expect(find.text('Jumlah minimal 1'), findsOneWidget);
  });

  testWidgets('Form Pesanan — jadwal bentrok memunculkan SnackBar',
      (tester) async {
    // Samakan persis nilai default form: case pertama, tanggal hari ini,
    // dan jam pertama. Tanpa data ini form justru akan berhasil menyimpan.
    await layanan.tambahPesanan(
      caseItem: daftarCaseAwal.first,
      namaModelIphone: 'iPhone 16 Pro Max',
      jumlah: 1,
      tanggal: formatTanggal(DateTime.now()),
      jam: daftarJamPengambilan.first,
    );

    viewportBesar(tester);
    await tester.pumpWidget(bungkus(FormPesananPage(layanan: layanan)));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('tombol_kirim_pesanan')));
    // SnackBar butuh satu frame tambahan setelah aksi async selesai.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.textContaining('sudah dipesan pada tanggal'), findsOneWidget);
    expect(layanan.pesananTersimpan, hasLength(1));
    // Form tidak ditutup saat ditolak.
    expect(find.byKey(const Key('tombol_kirim_pesanan')), findsOneWidget);
  });

  testWidgets('Beranda Firestore menyapa nama lengkap real-time',
      (tester) async {
    await tester.pumpWidget(
      bungkus(BerandaFirestorePage(layanan: layanan)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Halo, Alysha Syafiya 👋'), findsOneWidget);
    expect(find.text('users'), findsOneWidget);
    expect(find.text('cases'), findsOneWidget);
    expect(find.text('orders'), findsOneWidget);
  });

  testWidgets('Beranda Firestore menampilkan banner error', (tester) async {
    await tester.pumpWidget(
      bungkus(
        BerandaFirestorePage(
          layanan: layanan,
          tampilkanBannerError: true,
          pesanError: 'permission-denied',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Firestore belum dapat diakses'), findsOneWidget);
    expect(find.textContaining('permission-denied'), findsOneWidget);
  });
}
