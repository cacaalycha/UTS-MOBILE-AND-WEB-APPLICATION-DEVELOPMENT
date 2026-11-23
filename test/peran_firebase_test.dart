import 'package:case_iphone_caca/utils/peran_firebase.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('pecahEmailAdmin', () {
    test('nilai kosong menghasilkan daftar kosong', () {
      expect(pecahEmailAdmin(''), isEmpty);
      expect(pecahEmailAdmin('   ,  , '), isEmpty);
    });

    test('memangkas spasi dan menyamakan huruf', () {
      expect(
        pecahEmailAdmin(' AdminF@Gmail.com , owner@toko.com '),
        <String>['adminf@gmail.com', 'owner@toko.com'],
      );
    });

    test('perilaku default saat --dart-define tidak diberikan', () {
      // Bila test dijalankan dengan --dart-define=FIREBASE_ADMIN_EMAILS=...,
      // daftar tidak kosong, jadi pengecean ini hanya berlaku pada default.
      if (daftarEmailAdminMentah.isNotEmpty) return;
      expect(daftarEmailAdmin(), isEmpty);
      expect(apakahAdminFirebase('adminf@gmail.com'), isFalse);
      expect(apakahAdminFirebase(''), isFalse);
    });
  });
}
