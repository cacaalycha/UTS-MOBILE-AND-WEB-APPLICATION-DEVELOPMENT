import '../../models/case_model.dart';

/// Data mock produk case.
///
/// Setiap case punya `compatibleModelIds` dan `cameraCutoutType` yang
/// konsisten dengan layout kamera perangkat pada [mockIphones].
///
/// Pengelompokan layout kamera:
/// - `triple_square`  : Pro / Pro Max (16/15/14/13/12 Pro Max, 11 Pro Max)
/// - `dual_vertical`  : iPhone 16, 16 Plus, 11
/// - `dual_diagonal`  : iPhone 15, 15 Plus, 14, 14 Plus, 13, 13 mini, 12
const List<CaseModel> mockCases = [
  // ============================================================
  // Grup 1 — Pro Max (triple_square)
  // ============================================================
  CaseModel(
    id: 'c001',
    name: 'Caca Clear Shield Pro Max',
    brand: 'Caca',
    price: 89000,
    stock: 24,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Yellowing'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm'],
    cameraCutoutType: 'triple_square',
    category: 'Terlaris',
    description:
        'Case transparan dengan lapisan anti-kuning. Melindungi bodi tanpa menutupi warna asli iPhone Pro Max.',
    rating: 4.8,
  ),
  CaseModel(
    id: 'c002',
    name: 'Caca Armor Shockproof Pro Max',
    brand: 'Caca',
    price: 129000,
    stock: 15,
    material: 'TPU',
    features: ['Shockproof', 'Anti-Slip'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm', 'ip13pm'],
    cameraCutoutType: 'triple_square',
    category: 'Trending',
    description:
        'Bodi tebal dengan bantalan sudut untuk menahan benturan. Cocok untuk pemakaian harian intensif.',
    rating: 4.7,
  ),
  CaseModel(
    id: 'c003',
    name: 'Caca Leather Classic Pro Max',
    brand: 'Caca',
    price: 185000,
    stock: 8,
    material: 'Leather',
    features: ['Premium', 'MagSafe'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm', 'ip13pm', 'ip12pm'],
    cameraCutoutType: 'triple_square',
    category: 'Terbaru',
    description:
        'Kulit sintetis bertekstur dengan magnet MagSafe terintegrasi. Tampilan formal untuk penggunaan kerja.',
    rating: 4.9,
  ),
  CaseModel(
    id: 'c004',
    name: 'Caca MagSafe Ring Pro Max',
    brand: 'Caca',
    price: 145000,
    stock: 0,
    material: 'TPU',
    features: ['MagSafe', 'Shockproof'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm'],
    cameraCutoutType: 'triple_square',
    category: 'Trending',
    description:
        'Cincin magnetik presisi untuk aksesori MagSafe. Bantalan sudut menyerap guncangan ringan.',
    rating: 4.6,
  ),
  CaseModel(
    id: 'c005',
    name: 'Caca Frosted Matte Pro Max',
    brand: 'Caca',
    price: 99000,
    stock: 31,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Fingerprint'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm', 'ip13pm', 'ip12pm', 'ip11pm'],
    cameraCutoutType: 'triple_square',
    category: 'Terlaris',
    description:
        'Permukaan doff yang tidak mudah berbekas sidik jari. Tipis namun tetap melindungi modul kamera.',
    rating: 4.5,
  ),
  CaseModel(
    id: 'c006',
    name: 'Caca Rugged Belt Pro Max',
    brand: 'Caca',
    price: 159000,
    stock: 6,
    material: 'Hybrid',
    features: ['Shockproof', 'Kickstand'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm', 'ip13pm'],
    cameraCutoutType: 'triple_square',
    category: 'Terbaru',
    description:
        'Kombinasi hard shell dan lapisan TPU dengan penyangga lipat untuk menonton video.',
    rating: 4.4,
  ),

  // ============================================================
  // Grup 2 — Pro (triple_square, ukuran lebih kecil)
  // ============================================================
  CaseModel(
    id: 'c007',
    name: 'Caca Clear Shield Pro',
    brand: 'Caca',
    price: 85000,
    stock: 27,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Yellowing'],
    compatibleModelIds: ['ip16p', 'ip15p', 'ip14p', 'ip13p'],
    cameraCutoutType: 'triple_square',
    category: 'Terlaris',
    description:
        'Versi ringkas untuk iPhone Pro. Transparan dengan pelindung modul kamera bertepi tinggi.',
    rating: 4.8,
  ),
  CaseModel(
    id: 'c008',
    name: 'Caca Silicone Soft Pro',
    brand: 'Caca',
    price: 79000,
    stock: 42,
    material: 'Silicone',
    features: ['Soft Touch', 'Slim'],
    compatibleModelIds: ['ip16p', 'ip15p', 'ip14p', 'ip13p'],
    cameraCutoutType: 'triple_square',
    category: 'Trending',
    description:
        'Silikon lembut dengan lapisan mikroserat di bagian dalam untuk mencegah goresan.',
    rating: 4.6,
  ),
  CaseModel(
    id: 'c009',
    name: 'Caca Armor Shockproof Pro',
    brand: 'Caca',
    price: 125000,
    stock: 11,
    material: 'TPU',
    features: ['Shockproof', 'Anti-Slip'],
    compatibleModelIds: ['ip16p', 'ip15p', 'ip14p'],
    cameraCutoutType: 'triple_square',
    category: 'Trending',
    description:
        'Perlindungan maksimal dengan tekstur grip pada sisi samping agar tidak mudah terlepas.',
    rating: 4.7,
  ),
  CaseModel(
    id: 'c010',
    name: 'Caca Leather Classic Pro',
    brand: 'Caca',
    price: 175000,
    stock: 9,
    material: 'Leather',
    features: ['Premium', 'MagSafe'],
    compatibleModelIds: ['ip16p', 'ip15p', 'ip14p', 'ip13p'],
    cameraCutoutType: 'triple_square',
    category: 'Terbaru',
    description:
        'Kulit bertekstur halus dengan jahitan rapi. Magnet MagSafe tertanam di dalam lapisan.',
    rating: 4.8,
  ),

  // ============================================================
  // Grup 3 — dual_vertical (iPhone 16, 16 Plus, 11)
  // ============================================================
  CaseModel(
    id: 'c011',
    name: 'Caca Clear Shield 16',
    brand: 'Caca',
    price: 82000,
    stock: 35,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Yellowing'],
    compatibleModelIds: ['ip16', 'ip16plus'],
    cameraCutoutType: 'dual_vertical',
    category: 'Terbaru',
    description:
        'Cutout kamera vertikal presisi untuk iPhone 16 dan 16 Plus. Bodi transparan tipis.',
    rating: 4.7,
  ),
  CaseModel(
    id: 'c012',
    name: 'Caca Pastel Soft 16',
    brand: 'Caca',
    price: 75000,
    stock: 48,
    material: 'Silicone',
    features: ['Soft Touch', 'Slim'],
    compatibleModelIds: ['ip16', 'ip16plus'],
    cameraCutoutType: 'dual_vertical',
    category: 'Trending',
    description:
        'Warna pastel lembut dengan tekstur velvety. Ringan dan nyaman digenggam.',
    rating: 4.5,
  ),
  CaseModel(
    id: 'c013',
    name: 'Caca MagSafe Clear 16',
    brand: 'Caca',
    price: 139000,
    stock: 18,
    material: 'TPU',
    features: ['MagSafe', 'Anti-Yellowing'],
    compatibleModelIds: ['ip16', 'ip16plus'],
    cameraCutoutType: 'dual_vertical',
    category: 'Terlaris',
    description:
        'Transparan dengan cincin MagSafe. Tetap mendukung pengisian daya nirkabel.',
    rating: 4.8,
  ),
  CaseModel(
    id: 'c014',
    name: 'Caca Retro Fit iPhone 11',
    brand: 'Caca',
    price: 69000,
    stock: 22,
    material: 'TPU',
    features: ['Slim', 'Anti-Slip'],
    compatibleModelIds: ['ip11'],
    cameraCutoutType: 'dual_vertical',
    category: 'Terlaris',
    description:
        'Cutout kamera vertikal untuk iPhone 11. Bahan TPU lentur yang mudah dipasang.',
    rating: 4.4,
  ),
  CaseModel(
    id: 'c015',
    name: 'Caca Armor iPhone 11',
    brand: 'Caca',
    price: 95000,
    stock: 0,
    material: 'Hybrid',
    features: ['Shockproof'],
    compatibleModelIds: ['ip11'],
    cameraCutoutType: 'dual_vertical',
    category: 'Trending',
    description:
        'Lapisan ganda untuk iPhone 11 dengan sudut diperkuat. Sedang tidak tersedia.',
    rating: 4.3,
  ),

  // ============================================================
  // Grup 4 — dual_diagonal (15, 15 Plus, 14, 14 Plus, 13, 13 mini, 12)
  // ============================================================
  CaseModel(
    id: 'c016',
    name: 'Caca Clear Shield 15',
    brand: 'Caca',
    price: 83000,
    stock: 29,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Yellowing'],
    compatibleModelIds: ['ip15', 'ip15plus'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Terlaris',
    description:
        'Cutout kamera diagonal untuk iPhone 15 dan 15 Plus. Bodi bening dengan pelindung layar bertepi.',
    rating: 4.7,
  ),
  CaseModel(
    id: 'c017',
    name: 'Caca Pastel Soft 15',
    brand: 'Caca',
    price: 76000,
    stock: 40,
    material: 'Silicone',
    features: ['Soft Touch', 'Slim'],
    compatibleModelIds: ['ip15', 'ip15plus', 'ip14', 'ip14plus'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Trending',
    description:
        'Silikon pastel dengan lapisan dalam anti-gores. Tersedia untuk seri 15 dan 14.',
    rating: 4.6,
  ),
  CaseModel(
    id: 'c018',
    name: 'Caca MagSafe Clear 15',
    brand: 'Caca',
    price: 135000,
    stock: 16,
    material: 'TPU',
    features: ['MagSafe', 'Anti-Yellowing'],
    compatibleModelIds: ['ip15', 'ip15plus', 'ip14', 'ip14plus'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Terbaru',
    description:
        'Transparan dengan magnet MagSafe. Mendukung pengisian nirkabel 15W.',
    rating: 4.8,
  ),
  CaseModel(
    id: 'c019',
    name: 'Caca Leather Classic 14',
    brand: 'Caca',
    price: 169000,
    stock: 7,
    material: 'Leather',
    features: ['Premium', 'MagSafe'],
    compatibleModelIds: ['ip14', 'ip14plus'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Terbaru',
    description:
        'Kulit premium untuk iPhone 14 dan 14 Plus. Tekstur halus dengan tepi dijahit tangan.',
    rating: 4.9,
  ),
  CaseModel(
    id: 'c020',
    name: 'Caca Frosted Matte 13',
    brand: 'Caca',
    price: 92000,
    stock: 26,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Fingerprint'],
    compatibleModelIds: ['ip13', 'ip13mini'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Terlaris',
    description:
        'Permukaan doff anti sidik jari untuk iPhone 13 dan 13 mini. Tipis dan ringan.',
    rating: 4.5,
  ),
  CaseModel(
    id: 'c021',
    name: 'Caca Armor Shockproof 13',
    brand: 'Caca',
    price: 118000,
    stock: 13,
    material: 'TPU',
    features: ['Shockproof', 'Anti-Slip'],
    compatibleModelIds: ['ip13', 'ip13mini', 'ip14', 'ip14plus'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Trending',
    description:
        'Bantalan udara di setiap sudut. Cocok untuk pengguna yang sering menjatuhkan ponsel.',
    rating: 4.6,
  ),
  CaseModel(
    id: 'c022',
    name: 'Caca Clear Shield 12',
    brand: 'Caca',
    price: 78000,
    stock: 33,
    material: 'Polycarbonate',
    features: ['Slim', 'Anti-Yellowing'],
    compatibleModelIds: ['ip12', 'ip13', 'ip13mini'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Terlaris',
    description:
        'Bodi transparan untuk iPhone 12 dan 13. Cutout kamera diagonal presisi.',
    rating: 4.5,
  ),
  CaseModel(
    id: 'c023',
    name: 'Caca Cute Bear 13 mini',
    brand: 'Caca',
    price: 88000,
    stock: 21,
    material: 'Silicone',
    features: ['Soft Touch', 'Cute Design'],
    compatibleModelIds: ['ip13mini'],
    cameraCutoutType: 'dual_diagonal',
    category: 'Trending',
    description:
        'Desain beruang lucu khusus iPhone 13 mini. Bahan silikon lembut dan ringan.',
    rating: 4.7,
  ),

  // ============================================================
  // Grup 5 — Universal (cocok semua model terdaftar)
  // ============================================================
  CaseModel(
    id: 'c024',
    name: 'Caca Universal Slim Clear',
    brand: 'Caca',
    price: 65000,
    stock: 60,
    material: 'TPU',
    features: ['Slim', 'Universal Fit'],
    compatibleModelIds: [
      'ip16pm', 'ip16p', 'ip16plus', 'ip16',
      'ip15pm', 'ip15p', 'ip15plus', 'ip15',
      'ip14pm', 'ip14p', 'ip14plus', 'ip14',
      'ip13pm', 'ip13p', 'ip13', 'ip13mini',
      'ip12pm', 'ip12', 'ip11', 'ip11pm',
    ],
    cameraCutoutType: 'universal',
    category: 'Terlaris',
    description:
        'Case serbaguna dengan cutout kamera besar yang mengakomodasi berbagai layout kamera.',
    rating: 4.2,
  ),
  CaseModel(
    id: 'c025',
    name: 'Caca Universal Grip Matte',
    brand: 'Caca',
    price: 72000,
    stock: 44,
    material: 'TPU',
    features: ['Anti-Slip', 'Universal Fit'],
    compatibleModelIds: [
      'ip16pm', 'ip16p', 'ip16plus', 'ip16',
      'ip15pm', 'ip15p', 'ip15plus', 'ip15',
      'ip14pm', 'ip14p', 'ip14plus', 'ip14',
      'ip13pm', 'ip13p', 'ip13', 'ip13mini',
      'ip12pm', 'ip12', 'ip11', 'ip11pm',
    ],
    cameraCutoutType: 'universal',
    category: 'Trending',
    description:
        'Permukaan bertekstur grip pada seluruh sisi. Cocok untuk semua model iPhone terdaftar.',
    rating: 4.3,
  ),
  CaseModel(
    id: 'c026',
    name: 'Caca Universal Ring Stand',
    brand: 'Caca',
    price: 98000,
    stock: 19,
    material: 'Hybrid',
    features: ['Kickstand', 'Universal Fit'],
    compatibleModelIds: [
      'ip16pm', 'ip16p', 'ip16plus', 'ip16',
      'ip15pm', 'ip15p', 'ip15plus', 'ip15',
      'ip14pm', 'ip14p', 'ip14plus', 'ip14',
      'ip13pm', 'ip13p', 'ip13', 'ip13mini',
      'ip12pm', 'ip12', 'ip11', 'ip11pm',
    ],
    cameraCutoutType: 'universal',
    category: 'Terbaru',
    description:
        'Cincin logam yang berfungsi sebagai penyangga sekaligus pegangan. Kompatibel luas.',
    rating: 4.4,
  ),

  // ============================================================
  // Grup 6 — Tambahan untuk variasi stok & kategori
  // ============================================================
  CaseModel(
    id: 'c027',
    name: 'Caca Pro Max Carbon Edition',
    brand: 'Caca',
    price: 199000,
    stock: 4,
    material: 'Carbon Fiber',
    features: ['Premium', 'Shockproof', 'MagSafe'],
    compatibleModelIds: ['ip16pm', 'ip15pm', 'ip14pm'],
    cameraCutoutType: 'triple_square',
    category: 'Terbaru',
    description:
        'Serat karbon asli dengan aksen magnetik. Edisi terbatas untuk pengguna Pro Max.',
    rating: 4.9,
  ),
  CaseModel(
    id: 'c028',
    name: 'Caca Daily Basic 16',
    brand: 'Caca',
    price: 59000,
    stock: 55,
    material: 'TPU',
    features: ['Slim', 'Anti-Slip'],
    compatibleModelIds: ['ip16', 'ip16plus'],
    cameraCutoutType: 'dual_vertical',
    category: 'Terlaris',
    description:
        'Pilihan ekonomis sehari-hari. Ringan, lentur, dan mudah dipasang.',
    rating: 4.1,
  ),
];
