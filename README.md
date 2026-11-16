# CASE IPHONE CACA

**Aplikasi Katalog dan Pemilihan Case iPhone Berdasarkan Model iPhone**

> Repositori ini berisi **source code lengkap Flutter/Dart** (mobile **dan** web), proposal UTS, diagram perancangan, dan screenshot — bukan hanya README dan screenshot. Seluruh kode aplikasi ada di folder `lib/` dan dapat langsung dijalankan dengan `flutter run` atau `flutter run -d chrome`.

- Repository: https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT
- Demo web (GitHub Pages): https://cacaalycha.github.io/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/

> **Pembaruan Minggu 9:** repositori ini sekarang juga memuat alur login **Firebase Authentication** (Email/Password, target Chrome, paket Spark). Lihat [bagian 13](#13-praktikum-minggu-9--firebase-authentication) serta [`docs/LAPORAN_MINGGU_09.md`](docs/LAPORAN_MINGGU_09.md).
>
> **Pembaruan Minggu 10:** data katalog dan pesanan kini tersimpan permanen di **Cloud Firestore** (tiga collection `users`, `cases`, `orders`) dan tampil real-time lewat `StreamBuilder`. Lihat [bagian 14](#14-praktikum-minggu-10--cloud-firestore), [`docs/PANDUAN_FIRESTORE_MINGGU_10.md`](docs/PANDUAN_FIRESTORE_MINGGU_10.md), dan [`docs/LAPORAN_MINGGU_10.md`](docs/LAPORAN_MINGGU_10.md).

---

## 1. Identitas Project

| Keterangan | Informasi |
|---|---|
| Nama Project | Case iPhone Caca |
| Nama Mahasiswa | Alysha Syafiya Maisaroh |
| NIM | 23.01.55.0001 |
| Kelas | Pagi A1 |
| Mata Kuliah | Mobile and Web Application Development |
| Framework | Flutter (Dart) |
| Package name | `case_iphone_caca` |
| Versi | 1.0.0+1 |

## 2. Deskripsi Project

Case iPhone Caca merupakan aplikasi katalog penjualan case iPhone berbasis Flutter yang membantu pengguna menemukan case yang benar-benar cocok dengan model iPhone yang dimiliki. Permasalahan utama yang diselesaikan adalah **ketidakcocokan case dengan model iPhone** (terutama perbedaan cutout kamera dan ukuran bodi) yang sering menyebabkan salah beli.

Aplikasi menyediakan pemilihan model iPhone, katalog produk, detail produk, **Compatibility Checker** yang menyaring case berdasarkan model dan tipe cutout kamera, keranjang belanja, checkout dengan validasi form, riwayat pesanan, serta halaman admin untuk kelola produk. Pengguna utamanya adalah pemilik iPhone yang ingin membeli case secara online, dan admin toko sebagai pengelola katalog.

Prototipe UTS memakai **mock data / mock repository** (tanpa backend). Mulai Minggu 9 **autentikasi** terhubung ke Firebase Authentication, dan mulai Minggu 10 **profil pengguna, master case, dan pesanan** tersimpan permanen di Cloud Firestore dalam tiga collection `users`, `cases`, `orders` (operasi Create + Read, real-time). Kedua mode tetap berdampingan: tanpa konfigurasi `FIREBASE_*` aplikasi berjalan sebagai prototipe mock agar pengujian dan demo GitHub Pages tidak bergantung pada cloud. Rancangan database Firestore lengkap ada di proposal dan `docs/firestore-schema.png`.

## 3. Isi Repositori (Source Code Lengkap)

| Folder / Berkas | Isi |
|---|---|
| `lib/main.dart`, `lib/main_uts.dart` | Entry point mode Firebase (Minggu 9) dan mode prototipe UTS untuk build web |
| `lib/app.dart`, `lib/firebase_login_app.dart` | Root widget prototipe UTS (Provider) dan root widget praktikum Minggu 9 |
| `lib/models/` | 5 model: `UserModel`, `IphoneModel`, `CaseModel`, `CartItemModel`, `OrderModel` |
| `lib/data/mock/` | Data mock: 20 model iPhone, case, pesanan, akun demo |
| `lib/data/repositories/` | Abstraksi repository + 4 implementasi mock (auth, product, cart, order) |
| `lib/providers/` | State management `ChangeNotifier`: auth, product, cart, order |
| `lib/router/app_router.dart` | GoRouter + `StatefulShellRoute` + role guard (pembeli/admin) |
| `lib/pages/auth/` | Login & Register prototipe UTS dengan validasi form |
| `lib/pages/home/`, `lib/pages/model/` | Beranda & Pemilihan Model iPhone |
| `lib/pages/catalog/` | Katalog (filter + pencarian) & Detail Case + Compatibility Checker |
| `lib/pages/cart/`, `lib/pages/order/` | Keranjang, Checkout, Konfirmasi, Pesanan Saya, Detail Pesanan |
| `lib/pages/admin/` | Dashboard Admin, Kelola Produk, Form Tambah/Edit Produk |
| `lib/widgets/` | Widget reusable: `AppShell`, `CaseCard`, buttons, badges, empty state, section header |
| `lib/core/` | Tema Material 3, warna, tipografi, spacing, validator |
| `lib/firebase_options.dart`, `firebase-config.example.json` | Konfigurasi project Firebase via `--dart-define` (tanpa menyimpan nilai di Git) |
| `lib/utils/validasi_auth.dart` | Validator + terjemahan 7 kode `FirebaseAuthException` (Minggu 9) |
| `lib/pages/masuk_page.dart`, `lib/pages/cek_status_login.dart`, `lib/pages/halaman_utama.dart` | Halaman Masuk/Daftar dua mode, gerbang `authStateChanges()`, halaman utama + tombol Keluar |
| `lib/data/data_simulasi.dart` | Model dokumen Firestore Minggu 10: `PenggunaFirestore`, `CaseKatalog`, `PesananFirestore` + 4 case auto-seed |
| `lib/services/` | `LayananData` (kontrak), `LayananFirestore`, `LayananMemori` (untuk test), `FirestoreStatus` |
| `lib/pages/minggu10/` | Beranda Firestore, Daftar Case, Form Pesanan, Pesanan Saya |
| `lib/widgets/components/sapaan_firestore.dart` | Sapaan real-time dari `users/{uid}` |
| `lib/firebase_katalog_app.dart` | Root mode Firebase: menyuntik `Provider<LayananData>`, membuat profil & auto-seed `cases` |
| `firestore.rules` | Aturan keamanan `allow read, write: if request.auth != null;` |
| `test/` | 10 file widget/unit test, **80 test** (validator & form Minggu 9 + model/layanan/halaman Minggu 10) |
| `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` | Konfigurasi platform bawaan Flutter (termasuk **Flutter Web**) |
| `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.metadata` | Dependensi dan konfigurasi project |
| `Proyek_UTS_Case_iPhone_Caca_Proposal.docx` / `.pdf` | Proposal UTS lengkap |
| `docs/` | Diagram user flow, sitemap, wireframe, skema Firestore, panduan & laporan praktikum Minggu 9 dan Minggu 10 |
| `screenshots/` | 10 screenshot aplikasi UTS + screenshot Firebase Console Minggu 9 & Minggu 10 |
| branch `gh-pages` | Hasil build statis `flutter build web --release` (versi web siap hosting) |

## 4. Fitur Aplikasi

### A. Fitur Pembeli
- **Login & Register** — autentikasi mock dengan validasi email dan password.
- **Beranda** — ringkasan produk dan akses cepat ke fitur utama.
- **Pilih Model iPhone** — 20 model dikelompokkan per seri; model tersimpan sebagai preferensi.
- **Katalog Produk** — daftar case dengan pencarian dan filter kategori.
- **Compatibility Checker** — case hanya tampil bila model iPhone terdaftar dan tipe cutout kamera cocok.
- **Detail Produk** — informasi case, harga, daftar model kompatibel.
- **Keranjang Belanja** — tambah/hapus item, ubah jumlah, total harga.
- **Checkout** — form nama, telepon, alamat dengan validasi (wajib diisi, format, minimal panjang).
- **Konfirmasi & Pesanan Saya** — status pesanan beserta detail.

### B. Fitur Admin
- Dashboard admin, manajemen produk (tambah, edit, hapus) dengan form tervalidasi.

### C. Fitur Minggu 9 (Firebase)
- Daftar, masuk, dan keluar dengan Firebase Authentication (Email/Password).
- Halaman utama hanya terbuka setelah login; sesi bertahan setelah refresh browser.
- Pesan kesalahan yang jelas dari 7 kode `FirebaseAuthException`.

### D. Fitur Minggu 10 (Cloud Firestore)
- **Profil otomatis** — `users/{uid}` dibuat saat daftar/masuk; sapaan nama real-time di Beranda.
- **Master case** — collection `cases` diisi otomatis 4 dokumen lewat `WriteBatch`, tampil di Daftar Case dan dropdown Form Pesanan.
- **Form Pesanan (Create)** — validasi jumlah, tanggal, jam; menyimpan dokumen `orders` beserta `nama_case` (denormalisasi) dan `FieldValue.serverTimestamp()`.
- **Cegah bentrok** — kombinasi `id_pengguna + id_case + tanggal + jam` yang sama ditolak dengan SnackBar, dokumen tidak bertambah.
- **Pesanan Saya (Read)** — `StreamBuilder` + `.snapshots()` terfilter per `uid`, menangani keadaan loading / error / kosong, dan bertahan setelah refresh Chrome.
- **Security Rules** — hanya pengguna terautentikasi yang boleh membaca/menulis.

### E. Prioritas Fitur
Urutan prioritas: (1) pemilihan model iPhone, (2) Compatibility Checker, (3) katalog & detail, (4) keranjang + checkout tervalidasi, (5) riwayat pesanan, (6) admin. Alur inti "pilih model → cari case yang cocok → pesan" diprioritaskan karena itulah yang langsung menyelesaikan masalah salah beli case.

## 5. Desain UI/UX dan Prototype Figma

- **Figma Design / Wireframe:** https://www.figma.com/design/TPBZUe0azGKFVuAyHcQ0nq/-23.01.55.0001--%E2%80%93--Case-iPhone-Caca--%E2%80%93-Wireframe?node-id=1-2&t=lGxr09H65HQXbOiX-1
- **Figma Prototype:** https://www.figma.com/proto/TPBZUe0azGKFVuAyHcQ0nq/-23.01.55.0001--%E2%80%93--Case-iPhone-Caca--%E2%80%93-Wireframe?node-id=7-22&p=f&t=3IUcGORs9VA7dQZJ-1&scaling=scale-down&content-scaling=fixed&page-id=1%3A3&starting-point-node-id=7%3A22
- Versi gambar lokal (tanpa perlu login Figma): `docs/wireframe.png`

Diagram perancangan lainnya:

| Diagram | Berkas |
|---|---|
| User flow | `docs/user-flow.png` |
| Sitemap | `docs/sitemap.png` |
| Wireframe low fidelity | `docs/wireframe.png` |
| Rancangan database Firestore | `docs/firestore-schema.png` |

## 6. Proposal UTS

- **PDF:** [`Proyek_UTS_Case_iPhone_Caca_Proposal.pdf`](Proyek_UTS_Case_iPhone_Caca_Proposal.pdf)
- **DOCX:** [`Proyek_UTS_Case_iPhone_Caca_Proposal.docx`](Proyek_UTS_Case_iPhone_Caca_Proposal.docx)

Berisi: problem statement, persona, user story, kebutuhan fungsional & non-fungsional, prioritas fitur, user flow, sitemap, wireframe, tech stack, rancangan database Firestore, rencana pengujian, dan roadmap pengembangan.

## 7. Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter 3.x / Dart 3 | Framework & bahasa (Material 3, responsif mobile & web) |
| Provider | State management (`ChangeNotifier`) |
| GoRouter | Navigasi, nested shell route, redirect & role guard |
| Google Fonts | Tipografi |
| Intl | Format mata uang / angka |
| Cupertino Icons | Ikon antarmuka |
| Flutter Web | Target web (`flutter run -d chrome`, `flutter build web`) |
| Figma | Perancangan UI/UX dan prototype |
| GitHub / GitHub Pages | Source code, riwayat commit, dan hosting demo web |
| Firebase Authentication (`firebase_core` 5.1.0, `firebase_auth` 7.0.1) | Praktikum Minggu 9: daftar, masuk, keluar, cek status login (Email/Password, target Chrome) |
| Cloud Firestore (`cloud_firestore` 7.1.0) | Minggu 10: `users`, `cases`, `orders` — `WriteBatch`, `FieldValue.serverTimestamp()`, `.snapshots()` + `StreamBuilder`, aturan `request.auth != null` |

## 8. Cara Menjalankan Project

### Persyaratan
- Flutter SDK (Dart SDK termasuk di dalamnya)
- VS Code / Android Studio
- Emulator Android, perangkat fisik, atau Chrome untuk target web

### Langkah 1 — Clone / buka folder project

```bash
git clone https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT.git
cd UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT
```

### Langkah 2 — Install dependencies

```bash
flutter pub get
```

### Langkah 3 — Cek konfigurasi (opsional)

```bash
flutter doctor
flutter analyze
```

### Langkah 4 — Jalankan aplikasi

```bash
# Mobile / desktop (pilih device yang tersedia) — mode prototipe UTS
flutter run

# Web di Chrome — mode prototipe UTS (mock, tanpa Firebase)
flutter run -d chrome

# Web di Chrome — praktikum Minggu 9 + Minggu 10 (mode Firebase + Firestore)
flutter run -d chrome --dart-define-from-file=firebase-config.json

# Build release mode Firebase (hasil di build/web)
MSYS_NO_PATHCONV=1 flutter build web --release \
  --dart-define-from-file=firebase-config.json

# Atau build web statis mode prototipe UTS lalu sajikan folder build/web
flutter build web --release
```

> **Minggu 10 — sebelum menjalankan mode Firebase:** aktifkan
> **Build → Firestore Database → Create database** (Standard, paket Spark) di
> Firebase Console, lalu publish aturan dari `firestore.rules`. Tanpa langkah ini
> aplikasi tetap terbuka, tetapi Beranda Firestore menampilkan banner peringatan
> dan data belum tersimpan. Rincian ada di
> [`docs/PANDUAN_FIRESTORE_MINGGU_10.md`](docs/PANDUAN_FIRESTORE_MINGGU_10.md).

Aplikasi memiliki **dua mode** yang dipilih otomatis di `lib/main.dart`: bila
lima nilai `FIREBASE_*` diberikan, `Firebase.initializeApp()` dijalankan dan
yang tampil adalah alur login Minggu 9; bila tidak, yang tampil adalah prototipe
UTS berbasis mock. Cara mengisi konfigurasi dijelaskan di
[`docs/PANDUAN_FIREBASE_MINGGU_09.md`](docs/PANDUAN_FIREBASE_MINGGU_09.md).

### Langkah 5 — Jalankan pengujian

```bash
flutter analyze   # No issues found!
flutter test      # All tests passed! (80 test)
```

### Akun Demo

| Peran | Email | Password |
|---|---|---|
| Pembeli | `pembeli@caca.test` | `123456` |
| Admin | `admin@caca.test` | `123456` |

> Akun demo ini **khusus mode prototipe UTS (mock)**. Pada mode Firebase, daftarkan akun simulasi baru lewat halaman Daftar dan jangan pernah memakai password asli. Data mock (in-memory) akan kembali ke kondisi awal saat aplikasi di-restart.

## 9. Demo Web

Versi web aplikasi dapat dibuka langsung tanpa install Flutter melalui GitHub Pages:

**https://cacaalycha.github.io/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/**

Hasil build statisnya disimpan terpisah di branch `gh-pages` agar branch `main` tetap berisi source code yang ringan. Sejak Minggu 9, build demo UTS memakai entry point `lib/main_uts.dart` supaya demo tidak menjalankan `Firebase.initializeApp()` dan tetap menampilkan prototipe UTS (SDK JS Firebase hanya dimuat saat inisialisasi dipanggil):

```bash
MSYS_NO_PATHCONV=1 flutter build web --release -t lib/main_uts.dart \
  --base-href "/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/"
```

Untuk menjalankan versi web UTS secara lokal, cukup `flutter run -d chrome` dari source di branch `main`.

## 10. Rancangan Penyimpanan Data

**Minggu 9 (sekarang):** sesi autentikasi tersimpan permanen oleh Firebase Authentication. Katalog, keranjang, dan pesanan UTS masih memakai mock repository di `lib/data/repositories/impl/` (data in-memory) dan hilang saat aplikasi dijalankan ulang.

**Minggu 10 (terimplementasi):** **Cloud Firestore** dengan tiga collection untuk praktikum — `users/{uid}`, `cases/{id_case}`, `orders/{auto-ID}`. Field `nama_case` sengaja didenormalisasi ke `orders` karena Firestore tidak mendukung `JOIN`. Abstraksi `LayananData` memisahkan UI dari Firebase, sehingga `LayananFirestore` dipakai saat runtime dan `LayananMemori` dipakai pada widget test. Rancangan database UTS jangka panjang (`users`, `iphones`, `cases`, `carts`, `orders` + sub-koleksi `items`) tetap tersedia di proposal dan `docs/firestore-schema.png`. Aturan keamanan: `allow read, write: if request.auth != null;`.

## 11. Screenshot Aplikasi

### A. Halaman Login
![Halaman Login](screenshots/01-login.png)

### B. Halaman Beranda
![Halaman Beranda](screenshots/02-beranda.png)

### C. Halaman Katalog
![Halaman Katalog](screenshots/03-katalog.png)

### D. Halaman Detail Produk
![Halaman Detail Produk](screenshots/04-detail.png)

### E. Halaman Pilih Model iPhone
![Halaman Pilih Model iPhone](screenshots/05-pilih-model.png)

### F. Halaman Keranjang
![Halaman Keranjang](screenshots/06-keranjang.png)

### G. Halaman Checkout (form tervalidasi)
![Halaman Checkout](screenshots/07-checkout.png)

### H. Halaman Admin
![Halaman Admin](screenshots/08-admin.png)

### I. Tampilan Mobile — Katalog & Detail
![Katalog Mobile](screenshots/09-mobile-katalog.png)
![Detail Mobile](screenshots/10-mobile-detail.png)

### J. Bukti Firebase Console — Minggu 9
![Daftar pengguna Firebase Console](screenshots/11-firebase-users.png)

> Screenshot J diambil dari **Authentication → Users** pada project Firebase mahasiswa; berkasnya disimpan setelah praktikum dijalankan di Chrome.

### K. Bukti Firestore Console — Minggu 10

Berkas berikut diambil dari **Build → Firestore Database → Data** setelah praktikum Minggu 10 dijalankan di Chrome (lihat [bagian 14](#14-praktikum-minggu-10--cloud-firestore)):

| Berkas | Isi |
|---|---|
| `screenshots/12-firestore-users.png` | Collection `users`, dokumen `{uid}` |
| `screenshots/13-firestore-cases.png` | Collection `cases`, 4 dokumen auto-seed |
| `screenshots/14-firestore-orders.png` | Collection `orders`, minimal 1 dokumen pesanan |
| `screenshots/15-firestore-rules.png` | Tab Rules: `allow read, write: if request.auth != null;` |

> Berkas-berkas di atas **belum tersedia** dan sengaja tidak dibuat-reka: screenshot hanya dapat diambil dari project Firebase milik mahasiswa. Setelah disimpan, tautan ini dapat disertakan dalam pengumpulan tugas.

## 12. Riwayat Pengembangan

Riwayat commit disusun bertahap mengikuti proses pengerjaan, bukan satu commit besar: inisialisasi project → model & data → repository & state → widget & tema → autentikasi → katalog & compatibility → keranjang/checkout/pesanan → admin → pengujian → dokumentasi & proposal → build web → **(Minggu 9)** koneksi Firebase → halaman Masuk/Daftar → cek status login & tombol Keluar → laporan praktikum → perbaikan temuan uji → **(Minggu 10)** setup Firestore + rules + model 3 collection → halaman & rute Minggu 10 + widget test → panduan, laporan, dan tabel uji.

## 13. Praktikum Minggu 9 — Firebase Authentication

Pertemuan pertama setelah UTS: aplikasi mulai terhubung ke layanan cloud.
Batasnya: **target Chrome**, paket **Spark** tanpa billing account, penyedia
**Email/Password saja**, dan **belum memakai Firestore**.

| Berkas | Peran |
|---|---|
| `lib/firebase_options.dart` | `DefaultFirebaseOptions.currentPlatform` (web) + deteksi konfigurasi |
| `firebase-config.example.json` | Template nilai `firebaseConfig` dari Firebase Console |
| `lib/main.dart` | `WidgetsFlutterBinding.ensureInitialized()` → `await Firebase.initializeApp(...)` → `runApp` |
| `lib/main_uts.dart` | Entry point prototipe UTS untuk build GitHub Pages |
| `lib/firebase_login_app.dart` | `MaterialApp(home: CekStatusLogin())` |
| `lib/utils/validasi_auth.dart` | Validator + `pesanKesalahanAuth` untuk 7 kode error |
| `lib/pages/masuk_page.dart` | Satu halaman dua mode (`_modeDaftar`), `_sedangProses`, `obscureText: true` |
| `lib/pages/cek_status_login.dart` | `StreamBuilder<User?>` + `authStateChanges()` |
| `lib/pages/halaman_utama.dart` | Halaman terlindungi + tombol Keluar di app bar |

### Menjalankan

```bash
cp firebase-config.example.json firebase-config.json
# isi 5 nilai wajib dari Firebase Console > Project settings > firebaseConfig
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

Tanpa konfigurasi, aplikasi otomatis berjalan dalam **mode mock** (prototipe
UTS) supaya `flutter test` dan demo GitHub Pages tetap berfungsi — mengikuti
catatan modul *"Widget test gagal karena Firebase"*. Inisialisasi dan pemilihan
mode ada di `lib/main.dart`.

### Dokumen praktikum

- Panduan setup Console, tiga jalur koneksi, daftar periksa Latihan 1–4, dan troubleshooting: [`docs/PANDUAN_FIREBASE_MINGGU_09.md`](docs/PANDUAN_FIREBASE_MINGGU_09.md)
- Laporan (identitas, **12 kasus uji login**, refleksi individu, temuan uji teman, dan bukti commit): [`docs/LAPORAN_MINGGU_09.md`](docs/LAPORAN_MINGGU_09.md)
- Bukti screenshot: `screenshots/11-firebase-users.png`

Dependensi mengikuti modul: `firebase_core:5.1.0` dan `firebase_auth:7.0.1`.
`flutter analyze` bersih dan `flutter test` lulus **50 test** pada tahap Minggu 9.

## 14. Praktikum Minggu 10 — Cloud Firestore

Batas pertemuan: target **Chrome**, paket **Spark** tanpa billing, operasi hanya
**Create** dan **Read**. Update/Delete menyusul Minggu 11. Contoh RoomBook pada
modul (`users`/`rooms`/`reservations`) disesuaikan ke domain **Case iPhone Caca**:

| RoomBook (modul) | Case iPhone Caca | Doc ID | Isi |
|---|---|---|---|
| `users` | `users` | `uid` Firebase Auth | Profil + sapaan real-time |
| `rooms` | `cases` | `id_case` (`c001` … `c016`) | Master case, auto-seed 4 dokumen via `WriteBatch` |
| `reservations` | `orders` | auto-ID | Pesanan case, terfilter per `id_pengguna` |

**Denormalisasi:** `nama_case` disalin ke `orders` (bersama `harga_satuan` dan
`total_harga`) karena Firestore tidak punya `JOIN`; Pesanan Saya cukup satu kali
baca. **Aturan bisnis:** kombinasi `id_pengguna + id_case + tanggal + jam` yang
sama ditolak lewat `PesananBentrokException` sebelum `.set()`. Query memakai
**satu** `.where()` saja, pengurutan dilakukan di Dart agar tidak perlu
*composite index*.

### Berkas utama

| Berkas | Peran |
|---|---|
| `firestore.rules` | `allow read, write: if request.auth != null;` (publish di Console) |
| `lib/data/data_simulasi.dart` | 3 model + `toMap/fromMap`, `bacaWaktu()`, 4 case awal |
| `lib/services/layanan_data.dart` | Kontrak abstrak `LayananData` |
| `lib/services/layanan_firestore.dart` | Satu-satunya tempat `FirebaseFirestore.instance` dipanggil |
| `lib/services/layanan_memori.dart` | Implementasi in-memory untuk widget test |
| `lib/services/firestore_status.dart` | Status inisialisasi → banner error di Beranda |
| `lib/pages/minggu10/*.dart` | Beranda Firestore, Daftar Case, Form Pesanan, Pesanan Saya |
| `lib/router/app_router.dart` | `/firestore`, `/firestore/case`, `/firestore/form`, `/firestore/pesanan` |
| `test/minggu10_*_test.dart` | Unit test model/layanan + widget test empat halaman |

### Tabel uji Firestore (7 kasus)

Kasus berstatus ✅ dibuktikan oleh test otomatis berbasis `LayananMemori()`;
kolom "Hasil nyata" dilengkapi setelah uji langsung di Chrome dan Firebase Console.

| # | Kasus uji | Langkah | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|---|
| 1 | Tambah data valid | Kirim Form Pesanan dengan isian lengkap | Dokumen tampil di `orders` & Pesanan Saya | ✅ test / ⏳ Console |
| 2 | Tolak pesanan bentrok | Ajukan case, tanggal, dan jam yang sama | SnackBar "sudah dipesan"; dokumen tidak bertambah | ✅ test / ⏳ Chrome |
| 3 | Bertahan saat refresh | Tekan F5 / muat ulang Chrome | Sapaan nama, daftar case, & pesanan tetap tampil | ⏳ isi setelah uji |
| 4 | Isolasi antar akun | Keluar lalu masuk dengan akun simulasi kedua | Pesanan akun pertama tidak muncul di akun kedua | ✅ test / ⏳ Chrome |
| 5 | Security Rules | Uji akses tanpa login / saat aturan ditolak | Firebase mengembalikan `permission-denied` | ✅ UI error state / ⏳ Console |
| 6 | Auto-seed cases | Login pertama saat `cases` masih kosong | 4 dokumen dibuat sekali, tidak duplikat saat login ulang | ✅ test / ⏳ Console |
| 7 | Validasi & 3 keadaan Stream | Kosongkan jumlah; simulasikan error stream | Pesan validasi muncul; `waiting` / `error` / `empty` tampil benar | ✅ test |

### Menjalankan dan memverifikasi

```bash
cd D:/dev/caseipcaca
flutter analyze
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
  NO_PROXY=localhost,127.0.0.1 flutter test      # 80 test, All tests passed!
MSYS_NO_PATHCONV=1 flutter build web --release \
  --dart-define-from-file=firebase-config.json   # √ Built build/web
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

**Sebelum uji di Chrome:** aktifkan Firestore di Console
(**Build → Firestore Database → Create database**, Standard / Spark,
`asia-southeast2` Jakarta), lalu **Publish** isi `firestore.rules`. Akun yang
dibuat sebelum Minggu 10 belum punya `users/{uid}` — cukup **Keluar lalu masuk
kembali**. Bila database belum aktif, Beranda Firestore menampilkan banner
peringatan alih-alih crash.

### Dokumen praktikum

- Panduan setup Console, pemetaan ERD, Security Rules, daftar periksa Latihan 1–4, dan troubleshooting: [`docs/PANDUAN_FIRESTORE_MINGGU_10.md`](docs/PANDUAN_FIRESTORE_MINGGU_10.md)
- Laporan (identitas, **7 kasus uji**, refleksi individu, temuan uji, dan bukti commit): [`docs/LAPORAN_MINGGU_10.md`](docs/LAPORAN_MINGGU_10.md)
- Screenshot tiga collection: `screenshots/12-firestore-users.png`, `13-firestore-cases.png`, `14-firestore-orders.png`

Dependensi mengikuti modul: `cloud_firestore:7.1.0`. `flutter analyze` bersih,
`flutter test` lulus **80 test**, dan `flutter build web --release` berhasil.
Modul meminta minimal 2 commit baru ter-push; Minggu 10 menyumbang 3 commit
bertahap.

---

**Case iPhone Caca**  
Developed by **Alysha Syafiya Maisaroh**  
NIM: 23.01.55.0001 — Kelas Pagi A1
