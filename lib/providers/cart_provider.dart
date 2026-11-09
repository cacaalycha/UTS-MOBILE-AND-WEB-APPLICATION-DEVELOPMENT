import 'package:flutter/foundation.dart';

import '../data/repositories/cart_repository.dart';
import '../models/cart_item_model.dart';
import '../models/case_model.dart';
import '../models/iphone_model.dart';

/// Tarif pengiriman tetap sesuai batasan proyek (flat rate).
const double flatShippingCost = 15000;

/// State keranjang belanja.
class CartProvider extends ChangeNotifier {
  CartProvider(this._repository);

  final CartRepository _repository;

  List<CartItemModel> _items = [];

  List<CartItemModel> get items => List.unmodifiable(_items);

  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => _items.isEmpty;

  double get subtotal =>
      _items.fold(0.0, (sum, item) => sum + item.lineTotal);

  double get shippingCost => _items.isEmpty ? 0 : flatShippingCost;

  double get total => subtotal + shippingCost;

  Future<void> load() async {
    _items = await _repository.getItems();
    notifyListeners();
  }

  /// Tambah case ke keranjang untuk model iPhone tertentu.
  ///
  /// Mengembalikan pesan kesalahan, atau null jika berhasil.
  String? addCase({
    required CaseModel caseItem,
    required IphoneModel device,
    int quantity = 1,
  }) {
    if (!caseItem.isCompatibleWith(device)) {
      return 'Case ini tidak kompatibel dengan ${device.displayName}.';
    }
    if (caseItem.stock <= 0) {
      return 'Stok case ini sedang habis.';
    }

    final index = _items.indexWhere(
      (item) =>
          item.caseItem.id == caseItem.id &&
          item.forIphoneModelId == device.id,
    );

    if (index >= 0) {
      final existing = _items[index];
      final newQuantity = existing.quantity + quantity;
      if (newQuantity > caseItem.stock) {
        return 'Jumlah melebihi stok tersedia (${caseItem.stock}).';
      }
      _items[index] = existing.copyWith(quantity: newQuantity);
    } else {
      if (quantity > caseItem.stock) {
        return 'Jumlah melebihi stok tersedia (${caseItem.stock}).';
      }
      _items.add(
        CartItemModel(
          caseItem: caseItem,
          quantity: quantity,
          forIphoneModelId: device.id,
          forIphoneModelName: device.displayName,
        ),
      );
    }

    _persist();
    return null;
  }

  /// Ubah jumlah item. Mengembalikan pesan kesalahan bila melebihi stok.
  String? updateQuantity(CartItemModel item, int quantity) {
    if (quantity <= 0) {
      return removeItem(item);
    }
    if (quantity > item.caseItem.stock) {
      return 'Jumlah melebihi stok tersedia (${item.caseItem.stock}).';
    }

    final index = _items.indexWhere(
      (existing) =>
          existing.caseItem.id == item.caseItem.id &&
          existing.forIphoneModelId == item.forIphoneModelId,
    );
    if (index >= 0) {
      _items[index] = _items[index].copyWith(quantity: quantity);
      _persist();
    }
    return null;
  }

  String? removeItem(CartItemModel item) {
    _items.removeWhere(
      (existing) =>
          existing.caseItem.id == item.caseItem.id &&
          existing.forIphoneModelId == item.forIphoneModelId,
    );
    _persist();
    return null;
  }

  Future<void> clear() async {
    _items = [];
    await _repository.clear();
    notifyListeners();
  }

  void _persist() {
    _repository.saveItems(_items);
    notifyListeners();
  }
}
