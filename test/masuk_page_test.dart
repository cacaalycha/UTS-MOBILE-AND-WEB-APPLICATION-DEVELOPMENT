import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:case_iphone_caca/pages/masuk_page.dart';

/// Widget test untuk halaman Masuk/Daftar.
///
/// Semua kasus di bawah **hanya menguji validasi form** — tombol ditekan saat
/// input tidak valid, sehingga `_kirim()` berhenti sebelum memanggil
/// `FirebaseAuth.instance`. Dengan begitu test tetap hijau tanpa project
/// Firebase (lihat "Masalah umum" pada modul).
Widget _bungkus() => const MaterialApp(home: MasukPage());

void main() {
  testWidgets('kasus 4 — kolom kosong menampilkan dua pesan', (tester) async {
    await tester.pumpWidget(_bungkus());

    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Email wajib diisi'), findsOneWidget);
    expect(find.text('Password wajib diisi'), findsOneWidget);
  });

  testWidgets('kasus 3 — email tidak valid ditolak', (tester) async {
    await tester.pumpWidget(_bungkus());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'bukan-email',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Format email belum benar'), findsOneWidget);
  });

  testWidgets('password kurang dari 6 karakter ditolak', (tester) async {
    await tester.pumpWidget(_bungkus());

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'alysha@caca.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123');
    await tester.tap(find.widgetWithText(FilledButton, 'Masuk'));
    await tester.pumpAndSettle();

    expect(find.text('Password minimal 6 karakter'), findsOneWidget);
  });

  testWidgets('karakter password disembunyikan (obscureText)', (tester) async {
    await tester.pumpWidget(_bungkus());

    final fields =
        tester.widgetList<TextField>(find.byType(TextField)).toList();
    expect(fields, hasLength(2));
    expect(fields[0].obscureText, isFalse); // email
    expect(fields[1].obscureText, isTrue); // password
  });

  testWidgets('satu halaman melayani dua mode', (tester) async {
    await tester.pumpWidget(_bungkus());
    expect(find.text('Masuk'), findsNWidgets(2)); // judul + tombol

    await tester.tap(
      find.widgetWithText(TextButton, 'Belum punya akun? Daftar'),
    );
    await tester.pumpAndSettle();

    expect(find.text('Daftar Akun'), findsOneWidget);
    expect(find.text('Ulangi password'), findsOneWidget);
    expect(find.widgetWithText(FilledButton, 'Daftar'), findsOneWidget);
  });

  testWidgets('mode Daftar — konfirmasi password harus sama', (tester) async {
    await tester.pumpWidget(_bungkus());

    await tester.tap(
      find.widgetWithText(TextButton, 'Belum punya akun? Daftar'),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'alysha@caca.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');
    await tester.enterText(find.byType(TextFormField).at(2), '654321');
    await tester.tap(find.widgetWithText(FilledButton, 'Daftar'));
    await tester.pumpAndSettle();

    expect(find.text('Password tidak sama'), findsOneWidget);
  });
}
