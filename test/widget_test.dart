import 'package:case_iphone_caca/data/mock/mock_cases.dart';
import 'package:case_iphone_caca/data/mock/mock_iphones.dart';
import 'package:case_iphone_caca/data/repositories/impl/mock_product_repo.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Compatibility Checker', () {
    test('setiap case memiliki minimal satu model kompatibel', () {
      for (final item in mockCases) {
        expect(
          item.compatibleModelIds,
          isNotEmpty,
          reason: 'Case ${item.name} tidak punya model kompatibel.',
        );
      }
    });

    test('setiap model id pada case benar-benar ada di data iPhone', () {
      final validIds = mockIphones.map((model) => model.id).toSet();
      for (final item in mockCases) {
        for (final id in item.compatibleModelIds) {
          expect(
            validIds.contains(id),
            isTrue,
            reason: 'Case ${item.name} merujuk id tidak dikenal: $id',
          );
        }
      }
    });

    test('cutout kamera case konsisten dengan layout kamera perangkat', () {
      final byId = {for (final model in mockIphones) model.id: model};
      for (final item in mockCases) {
        if (item.cameraCutoutType == 'universal') continue;
        for (final id in item.compatibleModelIds) {
          final device = byId[id]!;
          expect(
            item.cameraCutoutType,
            device.cameraLayout,
            reason:
                'Case ${item.name} (${item.cameraCutoutType}) tidak cocok '
                'dengan ${device.displayName} (${device.cameraLayout}).',
          );
        }
      }
    });

    test('case Pro Max tidak kompatibel dengan iPhone standar', () {
      final proMaxCase = mockCases.firstWhere((item) => item.id == 'c001');
      final standard = mockIphones.firstWhere((model) => model.id == 'ip16');

      expect(proMaxCase.isCompatibleWith(standard), isFalse);
    });

    test('case universal kompatibel dengan semua model terdaftar', () {
      final universal = mockCases.firstWhere((item) => item.id == 'c024');

      for (final device in mockIphones) {
        expect(
          universal.isCompatibleWith(device),
          isTrue,
          reason: 'Case universal seharusnya cocok dengan ${device.displayName}',
        );
      }
    });

    test(
      'repository mengembalikan case yang kompatibel untuk iPhone 15',
      () async {
        final repository = MockProductRepository();
        final device = mockIphones.firstWhere((model) => model.id == 'ip15');

        final compatible = await repository.getCompatibleCases(device);

        expect(compatible, isNotEmpty);
        for (final item in compatible) {
          expect(item.isCompatibleWith(device), isTrue);
        }
      },
    );
  });

  group('Data mock', () {
    test('jumlah model iPhone memadai untuk demo', () {
      expect(mockIphones.length, greaterThanOrEqualTo(15));
    });

    test('id model iPhone unik', () {
      final ids = mockIphones.map((model) => model.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('id case unik', () {
      final ids = mockCases.map((item) => item.id).toList();
      expect(ids.toSet().length, ids.length);
    });
  });
}
