import 'package:flutter/foundation.dart';

import '../data/repositories/product_repository.dart';
import '../models/case_model.dart';
import '../models/iphone_model.dart';

/// Daftar kategori filter katalog.
const List<String> caseCategories = [
  'Semua',
  'Trending',
  'Terbaru',
  'Terlaris',
];

/// Daftar filter fitur/bahan pada katalog.
const List<String> caseFeatureFilters = [
  'Shockproof',
  'Slim',
  'MagSafe',
];

/// State katalog produk + Compatibility Checker.
class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repository);

  final ProductRepository _repository;

  List<IphoneModel> _iphones = [];
  List<CaseModel> _allCases = [];
  List<CaseModel> _compatibleCases = [];

  IphoneModel? _selectedDevice;
  String _selectedCategory = 'Semua';
  final Set<String> _selectedFeatures = {};
  String _searchQuery = '';
  bool _isLoading = false;

  List<IphoneModel> get iphones => _iphones;
  List<CaseModel> get allCases => _allCases;
  IphoneModel? get selectedDevice => _selectedDevice;
  String get selectedCategory => _selectedCategory;
  Set<String> get selectedFeatures => Set.unmodifiable(_selectedFeatures);
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;

  /// Case yang tampil setelah filter kategori, fitur, dan pencarian.
  List<CaseModel> get visibleCases {
    var result = _selectedDevice == null
        ? List<CaseModel>.from(_allCases)
        : List<CaseModel>.from(_compatibleCases);

    if (_selectedCategory != 'Semua') {
      result = result
          .where((item) => item.category == _selectedCategory)
          .toList();
    }

    if (_selectedFeatures.isNotEmpty) {
      result = result
          .where(
            (item) => _selectedFeatures.every(item.features.contains),
          )
          .toList();
    }

    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      result = result
          .where(
            (item) =>
                item.name.toLowerCase().contains(query) ||
                item.brand.toLowerCase().contains(query) ||
                item.material.toLowerCase().contains(query),
          )
          .toList();
    }

    return result;
  }

  /// Produk untuk rekomendasi di Beranda (maksimal 6 item).
  ///
  /// Jika model iPhone sudah dipilih, hanya case kompatibel yang
  /// direkomendasikan agar pengguna tidak melihat produk yang salah.
  List<CaseModel> get popularCases {
    final device = _selectedDevice;
    final pool = device == null
        ? List<CaseModel>.from(_allCases)
        : _allCases.where((item) => item.isCompatibleWith(device)).toList();

    // Fallback: jangan tampilkan bagian kosong jika tidak ada yang cocok.
    final source = pool.isEmpty ? List<CaseModel>.from(_allCases) : pool;
    source.sort((a, b) => b.rating.compareTo(a.rating));
    return source.take(6).toList();
  }

  Future<void> loadInitialData() async {
    _isLoading = true;
    notifyListeners();

    _iphones = await _repository.getIphones();
    _allCases = await _repository.getCases();

    _isLoading = false;
    notifyListeners();
  }

  Future<void> selectDevice(IphoneModel? device) async {
    _selectedDevice = device;
    if (device == null) {
      _compatibleCases = [];
    } else {
      _compatibleCases = await _repository.getCompatibleCases(device);
    }
    notifyListeners();
  }

  void selectCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void toggleFeature(String feature) {
    if (_selectedFeatures.contains(feature)) {
      _selectedFeatures.remove(feature);
    } else {
      _selectedFeatures.add(feature);
    }
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void resetFilters() {
    _selectedCategory = 'Semua';
    _selectedFeatures.clear();
    _searchQuery = '';
    notifyListeners();
  }

  /// Cek apakah suatu case kompatibel dengan model yang sedang dipilih.
  bool isCompatible(CaseModel caseItem) {
    final device = _selectedDevice;
    if (device == null) return true;
    return caseItem.isCompatibleWith(device);
  }

  CaseModel? caseById(String id) {
    for (final item in _allCases) {
      if (item.id == id) return item;
    }
    return null;
  }

  IphoneModel? iphoneById(String id) {
    for (final item in _iphones) {
      if (item.id == id) return item;
    }
    return null;
  }

  /// Simpan produk (tambah/ubah) dari halaman admin.
  Future<void> saveCase(CaseModel caseItem) async {
    await _repository.saveCase(caseItem);
    _allCases = await _repository.getCases();
    if (_selectedDevice != null) {
      _compatibleCases = await _repository.getCompatibleCases(_selectedDevice!);
    }
    notifyListeners();
  }

  Future<void> deleteCase(String id) async {
    await _repository.deleteCase(id);
    _allCases = await _repository.getCases();
    if (_selectedDevice != null) {
      _compatibleCases = await _repository.getCompatibleCases(_selectedDevice!);
    }
    notifyListeners();
  }

  /// Ringkasan stok untuk dashboard admin.
  int get totalProducts => _allCases.length;
  int get totalStock => _allCases.fold(0, (sum, item) => sum + item.stock);
  int get outOfStockCount =>
      _allCases.where((item) => item.stock == 0).length;
  int get lowStockCount =>
      _allCases.where((item) => item.stock > 0 && item.stock <= 5).length;
}
