import 'package:flutter/foundation.dart';

/// Status inisialisasi data awal Minggu 10 (`users` + auto-seed `cases`).
///
/// Dipisah dari [LayananData] supaya kegagalan aktifasi Firestore di Console
/// tidak membuat aplikasi crash, melainkan tampil sebagai banner ramah.
class FirestoreStatus extends ChangeNotifier {
  bool _selesai = false;
  String? _error;

  bool get selesai => _selesai;
  String? get error => _error;

  void mulai() {
    _selesai = false;
    _error = null;
    notifyListeners();
  }

  void berhasil() {
    _selesai = true;
    _error = null;
    notifyListeners();
  }

  void gagal(Object kesalahan) {
    _selesai = true;
    _error = kesalahan.toString();
    notifyListeners();
  }
}
