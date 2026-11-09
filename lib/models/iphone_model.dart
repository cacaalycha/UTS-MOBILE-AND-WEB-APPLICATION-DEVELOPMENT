/// Model perangkat iPhone yang menjadi acuan Compatibility Checker.
///
/// Catatan: data dimensi & layout kamera dipakai untuk mencocokkan case.
/// Nilai di sini adalah data mock yang realistis untuk keperluan praktik.
class IphoneModel {
  const IphoneModel({
    required this.id,
    required this.series,
    required this.variant,
    required this.displayName,
    required this.screenWidthMm,
    required this.screenHeightMm,
    required this.cameraLayout,
    required this.cameraModuleWidthMm,
    required this.releaseYear,
  });

  final String id;

  /// Contoh: "iPhone 15".
  final String series;

  /// Contoh: "Pro Max", "Pro", "Plus", "standar".
  final String variant;

  /// Contoh: "iPhone 15 Pro Max".
  final String displayName;

  final double screenWidthMm;
  final double screenHeightMm;

  /// Kode layout kamera belakang:
  /// `dual_diagonal`, `triple_square`, `triple_vertical`, `dual_vertical`, `single`.
  final String cameraLayout;

  /// Lebar modul kamera (mm) — dipakai untuk validasi cutout case.
  final double cameraModuleWidthMm;

  final int releaseYear;

  /// Label layout kamera dalam bahasa manusia.
  String get cameraLayoutLabel {
    switch (cameraLayout) {
      case 'single':
        return 'Kamera tunggal';
      case 'dual_vertical':
        return 'Kamera ganda vertikal';
      case 'dual_diagonal':
        return 'Kamera ganda diagonal';
      case 'triple_vertical':
        return 'Kamera tiga vertikal';
      case 'triple_square':
        return 'Kamera tiga kotak (Pro)';
      default:
        return cameraLayout;
    }
  }

  /// Nama lengkap untuk ditampilkan di dropdown/list.
  String get fullName => displayName;

  Map<String, dynamic> toMap() => {
    'id': id,
    'series': series,
    'variant': variant,
    'displayName': displayName,
    'screenWidthMm': screenWidthMm,
    'screenHeightMm': screenHeightMm,
    'cameraLayout': cameraLayout,
    'cameraModuleWidthMm': cameraModuleWidthMm,
    'releaseYear': releaseYear,
  };

  factory IphoneModel.fromMap(Map<String, dynamic> map) => IphoneModel(
    id: map['id'] as String,
    series: map['series'] as String,
    variant: map['variant'] as String,
    displayName: map['displayName'] as String,
    screenWidthMm: (map['screenWidthMm'] as num).toDouble(),
    screenHeightMm: (map['screenHeightMm'] as num).toDouble(),
    cameraLayout: map['cameraLayout'] as String,
    cameraModuleWidthMm: (map['cameraModuleWidthMm'] as num).toDouble(),
    releaseYear: map['releaseYear'] as int,
  );

  @override
  String toString() => displayName;
}
