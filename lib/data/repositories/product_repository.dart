import '../../models/case_model.dart';
import '../../models/iphone_model.dart';

/// Kontrak akses data produk (model iPhone + case).
abstract class ProductRepository {
  Future<List<IphoneModel>> getIphones();

  Future<List<CaseModel>> getCases();

  Future<CaseModel?> getCaseById(String id);

  Future<IphoneModel?> getIphoneById(String id);

  /// Case yang kompatibel dengan perangkat tertentu (inti Compatibility Checker).
  Future<List<CaseModel>> getCompatibleCases(IphoneModel device);

  /// Simpan perubahan produk (dipakai halaman admin).
  Future<void> saveCase(CaseModel caseItem);

  Future<void> deleteCase(String id);
}
