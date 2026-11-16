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

    // ATURAN BISNIS (dijalankan SEBELUM .set()):
    // Cukup satu .where() di Firestore, sisanya dicek di Dart supaya tidak
    // memerlukan composite index. Bentrok = case + tanggal + jam sama pada
    // pesanan yang masih aktif (status bukan "Dibatalkan").
    final adaDiTanggal = await _db
        .collection('orders')
        .where('tanggal', isEqualTo: tanggal)
        .get();

    final bentrok = adaDiTanggal.docs.any((doc) {
      final data = doc.data();
      return data['id_pengguna'] == uid &&
          data['id_case'] == caseItem.idCase &&
          data['jam'] == jam &&
          (data['status'] as String? ?? statusMenunggu).toLowerCase() !=
              statusDibatalkan.toLowerCase();
    });

    if (bentrok) {
      throw PesananBentrokException(
        '${caseItem.namaCase} sudah dipesan pada tanggal $tanggal jam $jam. '
        'Pilih jam pengambilan lain.',
      );
    }

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
