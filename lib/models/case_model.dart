import 'iphone_model.dart';

/// Produk case iPhone.
class CaseModel {
  const CaseModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.price,
    required this.stock,
    required this.material,
    required this.features,
    required this.compatibleModelIds,
    required this.cameraCutoutType,
    required this.category,
    this.imageUrl,
    this.description = '',
    this.rating = 0,
  });

  final String id;
  final String name;
  final String brand;
  final double price;
  final int stock;

  /// Contoh: "TPU", "Silicone", "Leather", "Polycarbonate".
  final String material;

  /// Contoh: ["Shockproof", "Slim", "MagSafe"].
  final List<String> features;

  /// Relasi ke [IphoneModel.id] yang kompatibel.
  final List<String> compatibleModelIds;

  /// Jenis cutout kamera case, harus cocok dengan layout kamera perangkat.
  /// `single`, `dual_diagonal`, `triple_square`, `triple_vertical`, `universal`.
  final String cameraCutoutType;

  /// Kategori katalog: "Trending", "Terbaru", "Terlaris", "Semua".
  final String category;

  final String? imageUrl;
  final String description;
  final double rating;

  bool get isAvailable => stock > 0;

  /// Case dianggap kompatibel jika model id ada di daftar dan
  /// tipe cutout kamera cocok atau bersifat universal.
  bool isCompatibleWith(IphoneModel device) {
    if (!compatibleModelIds.contains(device.id)) {
      return false;
    }
    if (cameraCutoutType == 'universal') {
      return true;
    }
    return cameraCutoutType == device.cameraLayout;
  }

  CaseModel copyWith({
    String? name,
    String? brand,
    double? price,
    int? stock,
    String? material,
    List<String>? features,
    List<String>? compatibleModelIds,
    String? cameraCutoutType,
    String? category,
    String? imageUrl,
    String? description,
    double? rating,
  }) {
    return CaseModel(
      id: id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      material: material ?? this.material,
      features: features ?? this.features,
      compatibleModelIds: compatibleModelIds ?? this.compatibleModelIds,
      cameraCutoutType: cameraCutoutType ?? this.cameraCutoutType,
      category: category ?? this.category,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      rating: rating ?? this.rating,
    );
  }

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'brand': brand,
    'price': price,
    'stock': stock,
    'material': material,
    'features': features,
    'compatibleModelIds': compatibleModelIds,
    'cameraCutoutType': cameraCutoutType,
    'category': category,
    'imageUrl': imageUrl,
    'description': description,
    'rating': rating,
  };

  factory CaseModel.fromMap(Map<String, dynamic> map) => CaseModel(
    id: map['id'] as String,
    name: map['name'] as String,
    brand: map['brand'] as String,
    price: (map['price'] as num).toDouble(),
    stock: map['stock'] as int,
    material: map['material'] as String,
    features: List<String>.from(map['features'] as List),
    compatibleModelIds: List<String>.from(map['compatibleModelIds'] as List),
    cameraCutoutType: map['cameraCutoutType'] as String,
    category: map['category'] as String,
    imageUrl: map['imageUrl'] as String?,
    description: (map['description'] as String?) ?? '',
    rating: ((map['rating'] as num?) ?? 0).toDouble(),
  );
}
