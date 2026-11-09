import '../../../models/case_model.dart';
import '../../../models/iphone_model.dart';
import '../../mock/mock_cases.dart';
import '../../mock/mock_iphones.dart';
import '../product_repository.dart';

/// Implementasi katalog berbasis data mock (tanpa Firebase).
///
/// Perubahan dari halaman admin disimpan di memori selama sesi berjalan.
class MockProductRepository implements ProductRepository {
  MockProductRepository() {
    _cases.addAll(mockCases);
    _iphones.addAll(mockIphones);
  }

  final List<CaseModel> _cases = [];
  final List<IphoneModel> _iphones = [];

  @override
  Future<List<IphoneModel>> getIphones() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<IphoneModel>.unmodifiable(_iphones);
  }

  @override
  Future<List<CaseModel>> getCases() async {
    await Future<void>.delayed(const Duration(milliseconds: 120));
    return List<CaseModel>.unmodifiable(_cases);
  }

  @override
  Future<CaseModel?> getCaseById(String id) async {
    for (final item in _cases) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<IphoneModel?> getIphoneById(String id) async {
    for (final item in _iphones) {
      if (item.id == id) return item;
    }
    return null;
  }

  @override
  Future<List<CaseModel>> getCompatibleCases(IphoneModel device) async {
    await Future<void>.delayed(const Duration(milliseconds: 150));
    return _cases.where((item) => item.isCompatibleWith(device)).toList();
  }

  @override
  Future<void> saveCase(CaseModel caseItem) async {
    final index = _cases.indexWhere((item) => item.id == caseItem.id);
    if (index >= 0) {
      _cases[index] = caseItem;
    } else {
      _cases.insert(0, caseItem);
    }
  }

  @override
  Future<void> deleteCase(String id) async {
    _cases.removeWhere((item) => item.id == id);
  }
}
