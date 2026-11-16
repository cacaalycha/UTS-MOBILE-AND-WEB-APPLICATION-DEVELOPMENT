import 'package:flutter/foundation.dart';

// ============================================================================
// Praktikum Minggu 10 — Model dokumen Cloud Firestore (Case iPhone Caca)
//
// Padanan dengan contoh RoomBook pada modul:
//   users        -> users        (profil, Doc ID = uid Firebase Auth)
//   rooms        -> cases        (master data case, Doc ID = kode case)
//   reservations -> orders       (pesanan, Doc ID = auto-ID)
//
// Sengaja TIDAK mengimpor cloud_firestore / firebase_auth di file ini.
// `dibuat_pada` dibaca lewat [bacaWaktu] yang menerima Timestamp, DateTime,
// maupun String, supaya model tetap bisa dipakai `LayananMemori` pada widget
// test tanpa koneksi Firebase (lihat "Masalah umum" pada modul).
// ============================================================================

/// Mengubah nilai `dibuat_pada` dari Firestore (`Timestamp`), memori
/// (`DateTime`), atau JSON (`String`) menjadi [DateTime] Dart.
DateTime? bacaWaktu(dynamic nilai) {
  if (nilai == null) return null;
  if (nilai is DateTime) return nilai;
  if (nilai is String) return DateTime.tryParse(nilai);
  // Timestamp dari cloud_firestore punya .toDate(); duck-typing dipakai
  // supaya file ini tidak bergantung pada paket Firebase.
  try {
    final hasil = (nilai as dynamic).toDate();
    return hasil is DateTime ? hasil : null;
  } catch (_) {
    return null;
  }
}

/// Format tanggal `yyyy-MM-dd` untuk field `tanggal` pada orders.
String formatTanggal(DateTime waktu) {
  String dua(int angka) => angka.toString().padLeft(2, '0');
  return '${waktu.year}-${dua(waktu.month)}-${dua(waktu.day)}';
}

// ---------------------------------------------------------------------------
// users/{uid}
// ---------------------------------------------------------------------------

/// Profil pengguna yang ditulis otomatis saat daftar / masuk.
@immutable
class PenggunaFirestore {
  const PenggunaFirestore({
    required this.idPengguna,
    required this.namaLengkap,
    required this.email,
    this.nomorTelepon = '',
    this.peran = 'mahasiswa',
    this.dibuatPada,
  });

  final String idPengguna;
  final String namaLengkap;
  final String email;
  final String nomorTelepon;
  final String peran;
  final DateTime? dibuatPada;

  /// Nama yang aman ditampilkan bila dokumen belum punya nama lengkap.
  String get namaTampil =>
      namaLengkap.trim().isEmpty ? email.split('@').first : namaLengkap.trim();

  Map<String, dynamic> toMap() => {
        'id_pengguna': idPengguna,
        'nama_lengkap': namaLengkap,
        'email': email,
        'nomor_telepon': nomorTelepon,
        'peran': peran,
        'dibuat_pada': dibuatPada?.toIso8601String(),
      };

  factory PenggunaFirestore.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) =>
      PenggunaFirestore(
        idPengguna: (map['id_pengguna'] as String?) ?? docId ?? '',
        namaLengkap: (map['nama_lengkap'] as String?) ?? '',
        email: (map['email'] as String?) ?? '',
        nomorTelepon: (map['nomor_telepon'] as String?) ?? '',
        peran: (map['peran'] as String?) ?? 'mahasiswa',
        dibuatPada: bacaWaktu(map['dibuat_pada']),
      );
}

// ---------------------------------------------------------------------------
// cases/{id_case} — master data (padanan collection rooms)
// ---------------------------------------------------------------------------

/// Master data case iPhone yang tampil di Daftar Case dan dropdown Form.
@immutable
class CaseKatalog {
  const CaseKatalog({
    required this.idCase,
    required this.namaCase,
    required this.brand,
    required this.harga,
    required this.stok,
    required this.material,
    required this.fitur,
    required this.modelKompatibel,
    required this.kategori,
    this.status = 'Tersedia',
    this.dibuatPada,
  });

  final String idCase;
  final String namaCase;
  final String brand;
  final double harga;
  final int stok;
  final String material;
  final List<String> fitur;
  final List<String> modelKompatibel;
  final String kategori;
  final String status;
  final DateTime? dibuatPada;

  bool get tersedia => stok > 0 && status.toLowerCase() != 'habis';

  Map<String, dynamic> toMap() => {
        'id_case': idCase,
        'nama_case': namaCase,
        'brand': brand,
        'harga': harga,
        'stok': stok,
        'material': material,
        'fitur': fitur,
        'model_kompatibel': modelKompatibel,
        'kategori': kategori,
        'status': status,
        'dibuat_pada': dibuatPada?.toIso8601String(),
      };

  factory CaseKatalog.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) =>
      CaseKatalog(
        idCase: (map['id_case'] as String?) ?? docId ?? '',
        namaCase: (map['nama_case'] as String?) ?? '',
        brand: (map['brand'] as String?) ?? '',
        harga: ((map['harga'] as num?) ?? 0).toDouble(),
        stok: (map['stok'] as num?)?.toInt() ?? 0,
        material: (map['material'] as String?) ?? '',
        fitur: _listString(map['fitur']),
        modelKompatibel: _listString(map['model_kompatibel']),
        kategori: (map['kategori'] as String?) ?? 'Semua',
        status: (map['status'] as String?) ?? 'Tersedia',
        dibuatPada: bacaWaktu(map['dibuat_pada']),
      );
}

List<String> _listString(dynamic nilai) {
  if (nilai is List) return nilai.map((e) => e.toString()).toList();
  return const <String>[];
}

// ---------------------------------------------------------------------------
// orders/{auto-ID} — transaksi (padanan collection reservations)
// ---------------------------------------------------------------------------

/// Status pesanan. Nilai `dibatalkan` dipakai sebagai pengecualian pengecekan
/// bentrok, sepadan dengan `status != 'ditolak'` pada modul RoomBook.
const String statusMenunggu = 'Menunggu';
const String statusDibatalkan = 'Dibatalkan';

/// Dilempar ketika case yang sama sudah dipesan pada tanggal & jam
/// pengambilan yang sama oleh pengguna yang sama.
class PesananBentrokException implements Exception {
  const PesananBentrokException(this.pesan);

  final String pesan;

  @override
  String toString() => pesan;
}

@immutable
class PesananFirestore {
  const PesananFirestore({
    required this.idPesanan,
    required this.idPengguna,
    required this.idCase,
    required this.namaCase,
    required this.namaModelIphone,
    required this.jumlah,
    required this.hargaSatuan,
    required this.totalHarga,
    required this.tanggal,
    required this.jam,
    this.status = statusMenunggu,
    this.catatan = '',
    this.dibuatPada,
  });

  final String idPesanan;
  final String idPengguna;

  final String idCase;

  /// DENORMALISASI: `nama_case` ikut disalin ke orders walaupun sudah ada
  /// `id_case`. Firestore tidak punya JOIN, jadi daftar pesanan cukup satu
  /// kali baca. Ini padanan `nama_ruang` pada modul.
  final String namaCase;
  final String namaModelIphone;

  final int jumlah;
  final double hargaSatuan;
  final double totalHarga;

  /// `yyyy-MM-dd` dan `HH:mm` — dipakai aturan bisnis cegah bentrok.
  final String tanggal;
  final String jam;

  final String status;
  final String catatan;
  final DateTime? dibuatPada;

  Map<String, dynamic> toMap() => {
        'id_pesanan': idPesanan,
        'id_pengguna': idPengguna,
        'id_case': idCase,
        'nama_case': namaCase,
        'nama_model_iphone': namaModelIphone,
        'jumlah': jumlah,
        'harga_satuan': hargaSatuan,
        'total_harga': totalHarga,
        'tanggal': tanggal,
        'jam': jam,
        'status': status,
        'catatan': catatan,
        'dibuat_pada': dibuatPada?.toIso8601String(),
      };

  factory PesananFirestore.fromMap(
    Map<String, dynamic> map, {
    String? docId,
  }) =>
      PesananFirestore(
        idPesanan: (map['id_pesanan'] as String?) ?? docId ?? '',
        idPengguna: (map['id_pengguna'] as String?) ?? '',
        idCase: (map['id_case'] as String?) ?? '',
        namaCase: (map['nama_case'] as String?) ?? '',
        namaModelIphone: (map['nama_model_iphone'] as String?) ?? '',
        jumlah: (map['jumlah'] as num?)?.toInt() ?? 1,
        hargaSatuan: ((map['harga_satuan'] as num?) ?? 0).toDouble(),
        totalHarga: ((map['total_harga'] as num?) ?? 0).toDouble(),
        tanggal: (map['tanggal'] as String?) ?? '',
        jam: (map['jam'] as String?) ?? '',
        status: (map['status'] as String?) ?? statusMenunggu,
        catatan: (map['catatan'] as String?) ?? '',
        dibuatPada: bacaWaktu(map['dibuat_pada']),
      );
}

/// 4 case awal untuk auto-seed `cases` lewat WriteBatch, sepadan dengan
/// "auto-seed 4 ruang" pada modul Minggu 10.
const List<CaseKatalog> daftarCaseAwal = <CaseKatalog>[
  CaseKatalog(
    idCase: 'c001',
    namaCase: 'Caca Clear Shield Pro Max',
    brand: 'Caca',
    harga: 89000,
    stok: 24,
    material: 'Polycarbonate',
    fitur: <String>['Slim', 'Anti-Yellowing'],
    modelKompatibel: <String>['ip16pm', 'ip15pm', 'ip14pm'],
    kategori: 'Terlaris',
  ),
  CaseKatalog(
    idCase: 'c002',
    namaCase: 'Caca Armor Shockproof Pro Max',
    brand: 'Caca',
    harga: 129000,
    stok: 15,
    material: 'TPU',
    fitur: <String>['Shockproof', 'Anti-Slip'],
    modelKompatibel: <String>['ip16pm', 'ip15pm', 'ip14pm', 'ip13pm'],
    kategori: 'Trending',
  ),
  CaseKatalog(
    idCase: 'c003',
    namaCase: 'Caca Leather Classic Pro Max',
    brand: 'Caca',
    harga: 185000,
    stok: 8,
    material: 'Leather',
    fitur: <String>['Premium', 'MagSafe'],
    modelKompatibel: <String>[
      'ip16pm',
      'ip15pm',
      'ip14pm',
      'ip13pm',
      'ip12pm',
    ],
    kategori: 'Terbaru',
  ),
  CaseKatalog(
    idCase: 'c016',
    namaCase: 'Caca Slim Matte iPhone 15',
    brand: 'Caca',
    harga: 99000,
    stok: 20,
    material: 'Silicone',
    fitur: <String>['Slim', 'Matte'],
    modelKompatibel: <String>['ip15', 'ip15plus', 'ip14'],
    kategori: 'Terlaris',
  ),
];

/// Daftar jam pengambilan untuk dropdown Form Pesanan.
const List<String> daftarJamPengambilan = <String>[
  '08.00',
  '09.00',
  '10.00',
  '11.00',
  '13.00',
  '14.00',
  '15.00',
  '16.00',
];
