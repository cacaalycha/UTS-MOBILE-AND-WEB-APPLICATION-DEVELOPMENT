import '../data/data_simulasi.dart';

/// Kontrak lapisan data praktikum Minggu 10.
///
/// Ini padanan `abstract class LayananRoomBook` pada modul, dengan domain yang
/// sudah dipetakan ke **Case iPhone Caca**. Tujuan pemisahan ini persis seperti
/// yang ditulis modul: kode UI (page) cukup memanggil metode seperti
/// [tambahPesanan], model punya `toMap()`/`fromMap()`, dan widget test bisa
/// memakai `LayananMemori()` tanpa koneksi internet maupun Firebase asli.
abstract class LayananData {
  /// Membuat dokumen `users/{uid}` bila belum ada (idempoten).
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  });

  /// Profil pengguna aktif secara real-time untuk sapaan di Beranda.
  Stream<PenggunaFirestore?> streamProfilSaya();

  /// Auto-seed 4 case awal bila collection `cases` masih kosong.
  Future<void> isiCaseAwalJikaKosong();

  /// Daftar case real-time (`.snapshots()`), dipakai Daftar Case & dropdown.
  Stream<List<CaseKatalog>> streamDaftarCase();

  /// Menyimpan pesanan baru, menolak jadwal yang bentrok.
  ///
  /// Melempar [PesananBentrokException] bila kombinasi case + tanggal + jam
  /// pengambilan sudah ada pada pesanan aktif pengguna yang sama.
  Future<PesananFirestore> tambahPesanan({
    required CaseKatalog caseItem,
    required String namaModelIphone,
    required int jumlah,
    required String tanggal,
    required String jam,
    String catatan = '',
  });

  /// Mengubah pesanan milik sendiri yang masih berstatus Menunggu.
  ///
  /// Melempar [OperasiDitolakException] bila bukan pemilik / status terkunci,
  /// dan [PesananBentrokException] bila jadwal baru bentrok dengan pesanan
  /// lain. Dokumen yang sedang diubah tidak ikut dihitung bentrok.
  /// `dibuat_pada` dan `id_pengguna` tidak berubah; `diubah_pada` diisi.
  Future<PesananFirestore> ubahPesanan({
    required String idPesanan,
    required CaseKatalog caseItem,
    required String namaModelIphone,
    required int jumlah,
    required String tanggal,
    required String jam,
    String catatan = '',
  });

  /// Menghapus pesanan milik sendiri yang masih berstatus Menunggu.
  /// UI wajib meminta konfirmasi sebelum memanggil metode ini.
  Future<void> hapusPesanan(String idPesanan);

  /// Pesanan milik pengguna yang sedang login, real-time dan terisolasi.
  /// Query hanya memakai SATU `.where()`; urutan terbaru di-sort di Dart
  /// agar tidak memicu error *composite index* (lihat modul bagian 6).
  Stream<List<PesananFirestore>> streamPesananSaya();

  /// Menutup resource (dipakai `LayananMemori` pada widget test).
  void dispose() {}
}
