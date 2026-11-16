import 'dart:async';

import '../data/data_simulasi.dart';
import 'layanan_data.dart';

/// Implementasi [LayananData] berbasis memori untuk **widget test**.
///
/// Padanan `class LayananMemori` pada modul Minggu 10. Tidak mengimpor
/// Firebase sama sekali, sehingga `flutter test` tetap cepat dan hijau tanpa
/// project Firebase (lihat "Masalah umum → Widget test gagal karena Firebase").
///
/// Seluruh [Stream] bersifat broadcast dan selalu mengirim nilai terkini
/// begitu ada subscriber, mirip perilaku `.snapshots()` Firestore.
class LayananMemori implements LayananData {
  // ignore: prefer_initializing_formals
  LayananMemori({String uid = 'uid-uji'}) : _uid = uid;

  String _uid;
  bool _ditutup = false;

  /// Aktifkan untuk menguji keadaan `snapshot.hasError` pada StreamBuilder.
  bool simulasiError = false;

  final Map<String, PenggunaFirestore> _pengguna = {};
  final List<CaseKatalog> _cases = [];
  final List<PesananFirestore> _pesanan = [];

  final StreamController<PenggunaFirestore?> _profilController =
      StreamController<PenggunaFirestore?>.broadcast();
  final StreamController<List<CaseKatalog>> _caseController =
      StreamController<List<CaseKatalog>>.broadcast();
  final StreamController<List<PesananFirestore>> _pesananController =
      StreamController<List<PesananFirestore>>.broadcast();

  /// Mengganti pengguna aktif — dipakai untuk menguji isolasi antar akun.
  void gantiPengguna(String uid) {
    _uid = uid;
    _kirimProfil();
    _kirimPesanan();
  }

  String get uidSaatIni => _uid;

  List<CaseKatalog> get casesTersimpan => List.unmodifiable(_cases);
  List<PesananFirestore> get pesananTersimpan => List.unmodifiable(_pesanan);
  Map<String, PenggunaFirestore> get penggunaTersimpan =>
      Map.unmodifiable(_pengguna);

  // -------------------------------------------------------------------------
  // Stream: kirim snapshot awal lalu dengarkan perubahan berikutnya.
  // -------------------------------------------------------------------------

  Stream<T> _aliran<T>(T awal, Stream<T> perubahan) async* {
    if (simulasiError) {
      throw StateError('Simulasi gangguan koneksi Firestore.');
    }
    yield awal;
    yield* perubahan;
  }

  @override
  Stream<PenggunaFirestore?> streamProfilSaya() => _aliran(
        _pengguna[_uid],
        _profilController.stream,
      );

  @override
  Stream<List<CaseKatalog>> streamDaftarCase() => _aliran(
        List<CaseKatalog>.unmodifiable(_cases),
        _caseController.stream,
      );

  @override
  Stream<List<PesananFirestore>> streamPesananSaya() => _aliran(
        _pesananSaya(),
        _pesananController.stream,
      );

  List<PesananFirestore> _pesananSaya() {
    final daftar = _pesanan
        .where((item) => item.idPengguna == _uid)
        .toList()
      ..sort(
        (a, b) => (b.dibuatPada ?? DateTime(0))
            .compareTo(a.dibuatPada ?? DateTime(0)),
      );
    return List.unmodifiable(daftar);
  }

  void _kirimProfil() {
    if (!_ditutup && !_profilController.isClosed) {
      _profilController.add(_pengguna[_uid]);
    }
  }

  void _kirimCase() {
    if (!_ditutup && !_caseController.isClosed) {
      _caseController.add(List<CaseKatalog>.unmodifiable(_cases));
    }
  }

  void _kirimPesanan() {
    if (!_ditutup && !_pesananController.isClosed) {
      _pesananController.add(_pesananSaya());
    }
  }

  // -------------------------------------------------------------------------
  // Operasi tulis (Create + Read) sesuai batas Minggu 10.
  // -------------------------------------------------------------------------

  @override
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  }) async {
    if (_pengguna.containsKey(uid)) return; // idempoten
    final namaBersih = (namaLengkap ?? '').trim();
    _pengguna[uid] = PenggunaFirestore(
      idPengguna: uid,
      namaLengkap: namaBersih.isNotEmpty ? namaBersih : email.split('@').first,
      email: email,
      dibuatPada: DateTime.now(),
    );
    _kirimProfil();
  }

  @override
  Future<void> isiCaseAwalJikaKosong() async {
    if (_cases.isNotEmpty) return;
    _cases.addAll(daftarCaseAwal);
    _kirimCase();
  }

  @override
  Future<PesananFirestore> tambahPesanan({
    required CaseKatalog caseItem,
    required String namaModelIphone,
    required int jumlah,
    required String tanggal,
    required String jam,
    String catatan = '',
  }) async {
    final bentrok = _pesanan.any(
      (item) =>
          item.idPengguna == _uid &&
          item.idCase == caseItem.idCase &&
          item.tanggal == tanggal &&
          item.jam == jam &&
          item.status.toLowerCase() != statusDibatalkan.toLowerCase(),
    );
    if (bentrok) {
      throw PesananBentrokException(
        '${caseItem.namaCase} sudah dipesan pada tanggal $tanggal jam $jam. '
        'Pilih jam pengambilan lain.',
      );
    }

    final sekarang = DateTime.now();
    final pesanan = PesananFirestore(
      idPesanan: 'ORD-M10-${_pesanan.length + 1}',
      idPengguna: _uid,
      idCase: caseItem.idCase,
      namaCase: caseItem.namaCase,
      namaModelIphone: namaModelIphone,
      jumlah: jumlah,
      hargaSatuan: caseItem.harga,
      totalHarga: caseItem.harga * jumlah,
      tanggal: tanggal,
      jam: jam,
      catatan: catatan,
      dibuatPada: sekarang,
    );
    _pesanan.add(pesanan);
    _kirimPesanan();
    return pesanan;
  }

  /// Hanya untuk keperluan test: menyuntik data awal tanpa menunggu seed.
  void isiUntukTest({
    Iterable<CaseKatalog>? cases,
    Iterable<PesananFirestore>? pesanan,
  }) {
    if (cases != null) {
      _cases
        ..clear()
        ..addAll(cases);
      _kirimCase();
    }
    if (pesanan != null) {
      _pesanan
        ..clear()
        ..addAll(pesanan);
      _kirimPesanan();
    }
  }

  @override
  void dispose() {
    _ditutup = true;
    _profilController.close();
    _caseController.close();
    _pesananController.close();
  }
}
