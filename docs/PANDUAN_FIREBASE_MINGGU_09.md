# Panduan Praktikum Minggu 9 — Firebase Login (Case iPhone Caca)

**Mata kuliah:** Mobile and Web Application Development · **Kelas:** Pagi A1
**Nama / NIM:** Alysha Syafiya Maisaroh / 23.01.55.0001
**Repository:** https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT

---

## 0. Batas praktikum (sesuai modul)

| Butir | Ketentuan |
|---|---|
| Target | **Chrome** (wajib) |
| Paket Firebase | **Spark**, tanpa billing account |
| Penyedia | **Email/Password saja** |
| Database | **Belum memakai Firestore** (masuk Minggu 10) |
| Akun | **Email & password simulasi**, dilarang memakai password asli |
| Dependency | `firebase_core:5.1.0`, `firebase_auth:7.0.1` (sudah terpasang) |
| Versi lokal | Flutter 3.47.7 / Dart 3.13.5 |

> `firebase_core_web` menyuntikkan Firebase JS SDK dari `https://www.gstatic.com/firebasejs/...`
> secara otomatis saat `Firebase.initializeApp()` dipanggil. **Tidak perlu** menambah
> tag `<script>` ke `web/index.html`. Konsekuensinya: Chrome harus terhubung internet.

---

## 1. Yang sudah disiapkan di repositori

| Berkas | Peran |
|---|---|
| `pubspec.yaml` | `firebase_core 5.1.0` + `firebase_auth 7.0.1` |
| `lib/firebase_options.dart` | `DefaultFirebaseOptions.currentPlatform` (web) + deteksi konfigurasi |
| `firebase-config.example.json` | Template nilai `firebaseConfig` (5 wajib + 2 opsional) |
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()` → `await Firebase.initializeApp(...)` → `runApp` |
| `lib/main_uts.dart` | Entry point prototipe UTS tanpa Firebase, untuk build GitHub Pages |
| `lib/firebase_login_app.dart` | `MaterialApp(home: CekStatusLogin())` |
| `lib/utils/validasi_auth.dart` | `validasiEmail`, `validasiPassword`, `validasiUlangiPassword`, `pesanKesalahanAuth` |
| `lib/pages/masuk_page.dart` | Satu halaman, dua mode (`_modeDaftar`), `_sedangProses`, `obscureText: true` |
| `lib/pages/cek_status_login.dart` | `StreamBuilder<User?>` + `authStateChanges()` |
| `lib/pages/halaman_utama.dart` | Halaman terlindungi + tombol **Keluar** di app bar |
| `test/validasi_auth_test.dart`, `test/masuk_page_test.dart` | 24 test baru (tanpa memanggil Firebase) |
| `docs/LAPORAN_MINGGU_09.md` | Tabel uji, daftar periksa, refleksi, dan bukti |

---

## 2. Langkah di Firebase Console

1. Buka https://console.firebase.google.com/ dan masuk dengan akun Google.
2. **Create project** → nama konsisten, mis. `case-iphone-caca-2301550001`.
   Matikan *Gemini in Firebase* dan *Google Analytics* (tidak diperlukan).
3. Pastikan paket tetap **Spark**. **Jangan** menambahkan billing account.
4. Buka **Authentication → Get started → Sign-in method**, aktifkan **Email/Password**
   (cukup provider itu, jangan aktifkan yang lain).
5. Kembali ke **Project settings → Your apps**, klik ikon `</>` untuk mendaftarkan
   aplikasi web, beri nama `Case iPhone Caca Web`. **Jangan** centang Firebase Hosting.
6. Salin objek `firebaseConfig` yang tampil. Yang dipakai di sini:
   `apiKey`, `appId`, `messagingSenderId`, `projectId`, `authDomain`
   (opsional: `storageBucket`, `measurementId`).

> Nilai-nilai ini adalah **pengenal project, bukan password**, sehingga aman
> disimpan. Yang tidak boleh pernah ditulis di kode/README adalah password akun.

---

## 3. Menghubungkan project ke Flutter

### Jalur A — `dart-define-from-file` (dipakai repositori ini, disarankan)

Keuntungannya: nilai project tidak tertulis di Git, dan satu source tetap bisa
dipakai untuk mode mock maupun mode Firebase.

```bash
cp firebase-config.example.json firebase-config.json
# lalu edit firebase-config.json, isi 5 nilai wajib dari Console
```

Isi `firebase-config.json` (contoh bentuk, bukan nilai asli):

```json
{
  "FIREBASE_API_KEY": "AIzaSy...",
  "FIREBASE_APP_ID": "1:123456789012:web:abcd...",
  "FIREBASE_MESSAGING_SENDER_ID": "123456789012",
  "FIREBASE_PROJECT_ID": "case-iphone-caca-2301550001",
  "FIREBASE_AUTH_DOMAIN": "case-iphone-caca-2301550001.firebaseapp.com"
}
```

File `firebase-config.json` sudah masuk `.gitignore`.

Jalankan:

```bash
flutter pub get
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

Bila lebih suka tanpa file, lima `--dart-define` bisa diketik langsung.
Di **Git Bash** pakai `\` untuk baris lanjutan:

```bash
flutter run -d chrome \
  --dart-define=FIREBASE_API_KEY=AIzaSy... \
  --dart-define=FIREBASE_APP_ID=1:...:web:... \
  --dart-define=FIREBASE_MESSAGING_SENDER_ID=123456789012 \
  --dart-define=FIREBASE_PROJECT_ID=case-iphone-caca-2301550001 \
  --dart-define=FIREBASE_AUTH_DOMAIN=case-iphone-caca-2301550001.firebaseapp.com
```

Di **PowerShell** gunakan backtick (`` ` ``) sebagai penerus baris, atau
tulis semuanya dalam satu baris.

### Jalur B — salin manual (jalur cadangan modul)

Buka `lib/firebase_options.dart`, ganti kelima baris
`String.fromEnvironment('FIREBASE_*')` dengan literal dari Console, mis.:

```dart
static const String _apiKey = 'AIzaSy............';
static const String _appId = '1:123456789012:web:abcd...';
static const String _messagingSenderId = '123456789012';
static const String _projectId = 'case-iphone-caca-2301550001';
static const String _authDomain = 'case-iphone-caca-2301550001.firebaseapp.com';
```

Lalu cukup `flutter run -d chrome` (tanpa flag tambahan).

### Jalur C — FlutterFire CLI (jalur utama modul)

```bash
npm install -g firebase-tools
dart pub global activate flutterfire_cli
firebase login
flutterfire configure --platforms=web
```

> ⚠️ Perintah ini **menimpa** `lib/firebase_options.dart` dan menghilangkan getter
> `isConfigured` yang dipakai `lib/main.dart`. Bila memilih jalur C, ubah
> `main.dart` agar langsung memanggil `Firebase.initializeApp(...)` tanpa
> pengecekan `DefaultFirebaseOptions.isConfigured`, atau kembalikan getter
> tersebut. Untuk praktikum ini jalur A/B lebih aman.

---

## 4. Dua mode aplikasi dan alasannya

| Kondisi | Yang berjalan | Root widget |
|---|---|---|
| Konfigurasi **lengkap** | Praktikum Minggu 9 — login Firebase | `FirebaseLoginApp` → `CekStatusLogin` |
| Konfigurasi **kosong** | Prototipe UTS (mock repository) | `CaseIphoneCacaApp` → GoRouter |

Modul bagian *Masalah umum* memperingatkan: *"Widget test gagal karena Firebase"*.
Karena 26 test UTS lama membangun `CaseIphoneCacaApp()` tanpa inisialisasi
Firebase, mode mock tetap dipertahankan sebagai **default**. Test baru untuk
Minggu 9 juga sengaja murni fungsi / hanya menguji validasi form, sehingga tidak
pernah memanggil `FirebaseAuth.instance`.

Konsekuensi untuk GitHub Pages: demo UTS dibangun dari `lib/main_uts.dart` agar
tidak menjalankan `Firebase.initializeApp()` dan tetap menampilkan prototipe
UTS. Sebagian besar kode Firebase tersaring oleh tree-shaking; SDK JS Firebase
hanya disuntikkan dari `gstatic.com` saat inisialisasi benar-benar dipanggil:

```bash
MSYS_NO_PATHCONV=1 flutter build web --release -t lib/main_uts.dart \
  --base-href "/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/"
```

---

## 5. Cara menguji di Chrome

1. Jalankan perintah jalur A. Pastikan tidak ada error inisialisasi di terminal.
2. Tekan **Belum punya akun? Daftar**, isi email simulasi (mis.
   `pembeli@caca.test`) dan password `123456`, ulangi password, tekan **Daftar**.
3. Setelah berhasil, `CekStatusLogin` otomatis menampilkan **Halaman Utama**
   tanpa satupun pemanggilan `Navigator`.
4. Cek **Authentication → Users** di Console: akun simulasi harus muncul.
5. **Refresh browser** → harus tetap masuk (sesi disimpan Firebase).
6. Tekan **Keluar** → kembali ke halaman **Masuk**.
7. Uji pesan kesalahan: password salah, email salah format, kolom kosong, daftar
   dengan email yang sudah terpakai. Catat di `docs/LAPORAN_MINGGU_09.md`.

---

## 6. Daftar periksa latihan

### Latihan 1 — hubungkan project
- [ ] Project Firebase dibuat dan paket tetap Spark
- [ ] Penyedia Email/Password aktif
- [ ] `lib/firebase_options.dart` tersedia / nilai terisi
- [ ] `flutter run -d chrome` berjalan tanpa error setelah inisialisasi
- [ ] Commit: **"Hubungkan project ke Firebase"**

### Latihan 2 — halaman Masuk/Daftar
- [ ] Satu halaman dengan mode Masuk dan Daftar
- [ ] Email dan password tervalidasi; password disembunyikan
- [ ] Tombol nonaktif saat proses berjalan
- [ ] Akun simulasi muncul di Authentication > Users
- [ ] Commit: **"Tambah halaman masuk dan daftar"**

### Latihan 3 — cek status login
- [ ] Belum login: yang tampil Halaman Masuk
- [ ] Setelah masuk: Halaman Utama tampil tanpa Navigator
- [ ] Sesi bertahan setelah refresh
- [ ] Tombol Keluar mengembalikan ke Halaman Masuk
- [ ] Commit: **"Tambah cek status login dan tombol keluar"**

### Latihan 4 — tabel uji login
- [ ] Minimal 5 kasus ditulis sebelum mencoba
- [ ] Hasil nyata dicatat setelah mencoba
- [ ] Satu temuan uji teman diperbaiki, lalu commit & push

---

## 7. Masalah umum

| Gejala | Penyebab | Solusi |
|---|---|---|
| `No Firebase App '[DEFAULT]' has been created` | `initializeApp` belum dipanggil/ditunggu | Pastikan `await Firebase.initializeApp(...)` sebelum `runApp` |
| `api-key-not-valid` | `apiKey` salah salin | Salin ulang `firebaseConfig`, cek `firebase-config.json` |
| `operation-not-allowed` | Email/Password belum aktif | Aktifkan di Authentication → Sign-in method |
| Selalu muncul pesan umum | Kode error belum diterjemahkan | Tambah `case` pada `pesanKesalahanAuth` |
| Halaman tidak berganti setelah masuk | `home` bukan `CekStatusLogin` | Pastikan `MaterialApp(home: const CekStatusLogin())` |
| Widget test gagal karena Firebase | Test membuka widget yang memanggil Firebase | Mode mock default + test baru hanya uji validasi |
| `flutterfire` tidak dikenali | Folder pub cache belum di PATH | Tambahkan ke PATH atau pakai jalur A/B |
| Aplikasi web tidak bisa login | JS SDK dari `gstatic.com` terblokir | Pastikan Chrome terhubung internet / proxy tidak memblokir |
| Peringatan *"Developer Mode / symlink"* di Windows | Plugin desktop butuh symlink | Tidak berdampak pada target web; abaikan atau aktifkan Developer Mode |

---

## 8. Verifikasi otomatis

```bash
flutter analyze
flutter test
```

Catatan lingkungan lokal: bila `flutter test` gagal dengan `WebSocketException:
Invalid WebSocket upgrade request`, matikan variabel proxy untuk proses tersebut:

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
  -u ALL_PROXY -u all_proxy NO_PROXY=localhost,127.0.0.1 flutter test
```

---

## 9. Commit yang disarankan (sudah dibuat bertahap)

| # | Pesan |
|---|---|
| 1 | `feat(firebase): hubungkan project ke Firebase (core, auth, firebase_options)` |
| 2 | `feat(auth): tambah halaman masuk dan daftar dengan validasi form` |
| 3 | `feat(auth): tambah cek status login dan tombol keluar` |
| 4 | `docs: panduan, laporan praktikum, dan README Minggu 9` |
| 5 | `fix(auth): perbaikan temuan uji — tombol tidak aktif lagi setelah login sukses` |

Modul meminta **minimal 2 commit baru**; repositori ini menghasilkan 5.

---

## 10. Persiapan Minggu 10

Bawa rancangan database dari proposal UTS (`docs/firestore-schema.png`):
koleksi `users`, `iphones`, `cases`, `carts`, `orders` (+ `items`). Minggu 10
merancang collection dan field Firestore, lalu membuat fitur tambah dan tampilkan
data. Yang sudah permanen hari ini **hanya sesi autentikasi**; katalog, keranjang,
dan pesanan masih hilang saat aplikasi dijalankan ulang.
