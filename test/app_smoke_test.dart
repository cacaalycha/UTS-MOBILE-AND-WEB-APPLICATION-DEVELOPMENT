import 'package:case_iphone_caca/app.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('aplikasi boot ke halaman login', (tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CaseIphoneCacaApp());
    // Tunggu timer mock repository selesai agar tidak ada timer menggantung.
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Masuk'), findsOneWidget);
  });

  testWidgets('login pembeli membuka Beranda', (tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CaseIphoneCacaApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(
      find.byType(TextFormField).at(0),
      'pembeli@caca.test',
    );
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.textContaining('Halo,'), findsOneWidget);
  });

  testWidgets('login admin membuka Dashboard Admin', (tester) async {
    tester.view.physicalSize = const Size(1400, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const CaseIphoneCacaApp());
    await tester.pumpAndSettle(const Duration(seconds: 2));

    await tester.enterText(find.byType(TextFormField).at(0), 'admin@caca.test');
    await tester.enterText(find.byType(TextFormField).at(1), '123456');

    await tester.tap(find.widgetWithText(ElevatedButton, 'Masuk'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    expect(find.text('Dashboard Admin'), findsOneWidget);
  });
}
