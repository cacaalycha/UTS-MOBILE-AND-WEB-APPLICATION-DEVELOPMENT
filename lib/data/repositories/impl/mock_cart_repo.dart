import '../../../models/cart_item_model.dart';
import '../cart_repository.dart';

/// Keranjang berbasis memori (tanpa Firebase / local storage).
class MockCartRepository implements CartRepository {
  List<CartItemModel> _items = [];

  @override
  Future<List<CartItemModel>> getItems() async {
    return List<CartItemModel>.from(_items);
  }

  @override
  Future<void> saveItems(List<CartItemModel> items) async {
    _items = List<CartItemModel>.from(items);
  }

  @override
  Future<void> clear() async {
    _items = [];
  }
}
