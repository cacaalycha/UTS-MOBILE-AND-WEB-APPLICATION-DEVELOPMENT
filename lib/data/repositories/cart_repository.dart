import '../../models/cart_item_model.dart';

/// Kontrak keranjang belanja.
abstract class CartRepository {
  Future<List<CartItemModel>> getItems();

  Future<void> saveItems(List<CartItemModel> items);

  Future<void> clear();
}
