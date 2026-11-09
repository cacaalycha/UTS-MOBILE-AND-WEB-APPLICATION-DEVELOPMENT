import 'case_model.dart';

/// Satu baris item di keranjang belanja.
class CartItemModel {
  const CartItemModel({
    required this.caseItem,
    required this.quantity,
    required this.forIphoneModelId,
    required this.forIphoneModelName,
  });

  final CaseModel caseItem;
  final int quantity;

  /// Model iPhone yang dipilih pembeli saat menambahkan case.
  final String forIphoneModelId;
  final String forIphoneModelName;

  double get lineTotal => caseItem.price * quantity;

  CartItemModel copyWith({int? quantity}) => CartItemModel(
    caseItem: caseItem,
    quantity: quantity ?? this.quantity,
    forIphoneModelId: forIphoneModelId,
    forIphoneModelName: forIphoneModelName,
  );

  Map<String, dynamic> toMap() => {
    'caseId': caseItem.id,
    'caseName': caseItem.name,
    'price': caseItem.price,
    'quantity': quantity,
    'imageUrl': caseItem.imageUrl,
    'forIphoneModelId': forIphoneModelId,
    'forIphoneModelName': forIphoneModelName,
  };
}
