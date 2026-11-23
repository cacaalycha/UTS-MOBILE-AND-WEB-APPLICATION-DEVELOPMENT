import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../data/data_simulasi.dart';
import 'layanan_data.dart';

/// Implementasi [LayananData] memakai **Cloud Firestore asli**.
///
/// Padanan `class LayananFirestore` pada modul Minggu 10. Semua akses
/// `FirebaseFirestore.instance` terkonsentrasi di sini supaya halaman UI
/// tidak bergantung langsung pada Firebase — syarat agar widget test tetap
/// bisa memakai [LayananMemori].
class LayananFirestore implements LayananData {
  LayananFirestore({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String? get _uid => _auth.currentUser?.uid;

  @override
  Future<void> simpanPenggunaSaatLogin({
    required String uid,
    required String email,
    String? namaLengkap,
  }) async {
    final docRef = _db.collection('users').doc(uid);
    final snap = await docRef.get();
    if (snap.exists) return; // idempoten: jangan timpa profil yang sudah ada

    final namaBersih = (namaLengkap ?? '').trim();
    await docRef.set({
      'id_pengguna': uid,
      'nama_lengkap': namaBersih.isNotEmpty ? namaBersih : email.split('@').first,
      'email': email,
      'nomor_telepon': '',
      'peran': 'mahasiswa',
      'dibuat_pada': FieldValue.serverTimestamp(),
    });
  }

  @override
  Stream<PenggunaFirestore?> streamProfilSaya() {
    final uid = _uid;
    if (uid == null) return Stream<PenggunaFirestore?>.value(null);
    return _db.collection('users').doc(uid).snapshots().map(
          (snap) => snap.exists
              ? PenggunaFirestore.fromMap(
                  snap.data() ?? const <String, dynamic>{},
                  docId: snap.id,
                )
              : null,
        );
  }

  @override
  Future<void> isiCaseAwalJikaKosong() async {
    // Cek cepat: cukup satu dokumen untuk tahu collection sudah terisi.
    final cek = await _db.collection('cases').limit(1).get();
    if (cek.docs.isNotEmpty) return;

    final batch = _db.batch();
    for (final caseItem in daftarCaseAwal) {
      batch.set(
        _db.collection('cases').doc(caseItem.idCase),
        _caseKePayload(caseItem),
      );
    }
    await batch.commit();
  }

  Map<String, dynamic> _caseKePayload(CaseKatalog caseItem) => {
        'id_case': caseItem.idCase,
        'nama_case': caseItem.namaCase,
        'brand': caseItem.brand,
        'harga': caseItem.harga,
        'stok': caseItem.stok,
        'material': caseItem.material,
        'fitur': caseItem.fitur,
        'model_kompatibel': caseItem.modelKompatibel,
        'kategori': caseItem.kategori,
        'status': caseItem.status,
        'dibuat_pada': FieldValue.serverTimestamp(),
      };

  @override
  Stream<List<CaseKatalog>> streamDaftarCase() => _db
      .collection('cases')
      .snapshots()
      .map(
        (snap) => snap.docs
            .map(
              (doc) => CaseKatalog.fromMap(doc.data(), docId: doc.id),
            )
            .toList()
          ..sort((a, b) => a.namaCase.compareTo(b.namaCase)),
      );

  /// ATURAN BENTROK BERSAMA (dipakai tambah DAN ubah).
  ///
  /// Satu `.where('tanggal')` saja di Firestore, sisanya lewat fungsi bersama
  /// `adaBentrokPesanan()` di lapisan model. Ini menghindari *composite index*
  /// sekaligus menjaga pesan galat tetap sama di dua mode form.
  Future<void> _pastikanTidakBentrok({
    required String idCase,
    required String namaCase,
    required String tanggal,
    required String jam,
    String? abaikanId,
  }) async {
    final adaDiTanggal = await _db
        .collection('orders')
        .where('tanggal', isEqualTo: tanggal)
        .get();

    final bentrok = adaBentrokPesanan(
      daftar: adaDiTanggal.docs.map(
        (doc) => PesananFirestore.fromMap(doc.data(), docId: doc.id),
      ),
      idCase: idCase,
      tanggal: tanggal,
      jam: jam,
      abaikanId: abaikanId,
    );

    if (bentrok) {
      throw PesananBentrokException(
        pesanBentrok(namaCase: namaCase, tanggal: tanggal, jam: jam),
      );
    }
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
    final uid = _uid;
    if (uid == null) {
      throw StateError('Pengguna belum login. Tidak dapat menyimpan pesanan.');
    }

    // ATURAN BISNIS (dijalankan SEBELUM .set()).
    await _pastikanTidakBentrok(
      idCase: caseItem.idCase,
      namaCase: caseItem.namaCase,
      tanggal: tanggal,
      jam: jam,
    );

    final docRef = _db.collection('orders').doc();
    final total = caseItem.harga * jumlah;

    await docRef.set({
      'id_pesanan': docRef.id,
      'id_pengguna': uid,
      'id_case': caseItem.idCase,
      // DENORMALISASI: nama case ikut disimpan agar daftar pesanan cukup
      // satu kali baca (Firestore tidak mendukung JOIN antar-collection).
      'nama_case': caseItem.namaCase,
      'nama_model_iphone': namaModelIphone,
      'jumlah': jumlah,
      'harga_satuan': caseItem.harga,
      'total_harga': total,
      'tanggal': tanggal,
      'jam': jam,
      'status': statusMenunggu,
      'catatan': catatan,
      'dibuat_pada': FieldValue.serverTimestamp(),
    });

    return PesananFirestore(
      idPesanan: docRef.id,
      idPengguna: uid,
      idCase: caseItem.idCase,
      namaCase: caseItem.namaCase,
      namaModelIphone: namaModelIphone,
      jumlah: jumlah,
      hargaSatuan: caseItem.harga,
      totalHarga: total,
      tanggal: tanggal,
      jam: jam,
      catatan: catatan,
      dibuatPada: DateTime.now(),
    );
  }

  @override
  Future<PesananFirestore> ubahPesanan({
    required String idPesanan,
    required CaseKatalog caseItem,
    required String namaModelIphone,
    required int jumlah,
    required String tanggal,
    required String jam,
    String catatan = '',
  }) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Pengguna belum login. Tidak dapat mengubah pesanan.');
    }

    final docRef = _db.collection('orders').doc(idPesanan);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw const OperasiDitolakException('Pesanan tidak ditemukan.');
    }

    // Aturan bisnis: pemilik + status Menunggu (sama seperti Rules).
    pastikanBolehDiubah(
      data: snap.data()!,
      uidAktif: uid,
      aksi: 'ubah',
    );

    // Kecualikan dokumen sendiri agar mengubah jumlah pada jam yang sama
    // tidak dianggap bentrok (jebakan pada modul).
    await _pastikanTidakBentrok(
      idCase: caseItem.idCase,
      namaCase: caseItem.namaCase,
      tanggal: tanggal,
      jam: jam,
      abaikanId: idPesanan,
    );

    final lama = PesananFirestore.fromMap(snap.data()!, docId: snap.id);
    final sekarang = FieldValue.serverTimestamp();
    await docRef.update(<String, dynamic>{
      'id_case': caseItem.idCase,
      'nama_case': caseItem.namaCase,
      'nama_model_iphone': namaModelIphone,
      'jumlah': jumlah,
      'harga_satuan': caseItem.harga,
      'total_harga': caseItem.harga * jumlah,
      'tanggal': tanggal,
      'jam': jam,
      'catatan': catatan,
      // id_pengguna, dibuat_pada, dan status SENGAJA tidak disentuh.
      'diubah_pada': sekarang,
    });

    return PesananFirestore(
      idPesanan: idPesanan,
      idPengguna: lama.idPengguna,
      idCase: caseItem.idCase,
      namaCase: caseItem.namaCase,
      namaModelIphone: namaModelIphone,
      jumlah: jumlah,
      hargaSatuan: caseItem.harga,
      totalHarga: caseItem.harga * jumlah,
      tanggal: tanggal,
      jam: jam,
      status: lama.status,
      catatan: catatan,
      dibuatPada: lama.dibuatPada,
      diubahPada: DateTime.now(),
    );
  }

  @override
  Future<void> hapusPesanan(String idPesanan) async {
    final uid = _uid;
    if (uid == null) {
      throw StateError('Pengguna belum login. Tidak dapat menghapus pesanan.');
    }

    final docRef = _db.collection('orders').doc(idPesanan);
    final snap = await docRef.get();
    if (!snap.exists) {
      throw const OperasiDitolakException('Pesanan tidak ditemukan.');
    }

    pastikanBolehDiubah(
      data: snap.data()!,
      uidAktif: uid,
      aksi: 'hapus',
    );

    await docRef.delete();
  }

  @override
  Stream<List<PesananFirestore>> streamPesananSaya() {
    final uid = _uid;
    if (uid == null) {
      return Stream<List<PesananFirestore>>.value(
        const <PesananFirestore>[],
      );
    }
    return _db
        .collection('orders')
        .where('id_pengguna', isEqualTo: uid)
        .snapshots()
        .map((snap) {
      final daftar = snap.docs
          .map(
            (doc) => PesananFirestore.fromMap(doc.data(), docId: doc.id),
          )
          .toList();
      // Urutkan di sisi Dart, BUKAN .orderBy() di Firestore.
      daftar.sort(
        (a, b) => (b.dibuatPada ?? DateTime(0))
            .compareTo(a.dibuatPada ?? DateTime(0)),
      );
      return daftar;
    });
  }

  @override
  void dispose() {}
}
