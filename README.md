# CASE IPHONE CACA

**Aplikasi Katalog dan Pemilihan Case iPhone Berdasarkan Model iPhone**

> Repositori ini berisi **source code lengkap Flutter/Dart** (mobile **dan** web), proposal UTS, diagram perancangan, dan screenshot — bukan hanya README dan screenshot. Seluruh kode aplikasi ada di folder `lib/` dan dapat langsung dijalankan dengan `flutter run` atau `flutter run -d chrome`.

- Repository: https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT
- Demo web (GitHub Pages): https://cacaalycha.github.io/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/

> **Pembaruan Minggu 9:** repositori ini sekarang juga memuat alur login **Firebase Authentication** (Email/Password, target Chrome, paket Spark). Lihat [bagian 13](#13-praktikum-minggu-9--firebase-authentication) serta [`docs/LAPORAN_MINGGU_09.md`](docs/LAPORAN_MINGGU_09.md).

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

Pada versi UTS ini data masih berupa **mock data / mock repository** (tanpa backend). Mulai Minggu 9, **autentikasi** sudah terhubung ke Firebase Authentication; Firestore untuk data katalog/pesanan menyusul pada Minggu 10. Rancangan database Firestore tersedia di dalam proposal.

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
| `test/` | 7 file widget/unit test, **50 test** (termasuk validator & form Firebase Minggu 9) |
| `android/`, `ios/`, `web/`, `windows/`, `linux/`, `macos/` | Konfigurasi platform bawaan Flutter (termasuk **Flutter Web**) |
| `pubspec.yaml`, `pubspec.lock`, `analysis_options.yaml`, `.metadata` | Dependensi dan konfigurasi project |
| `Proyek_UTS_Case_iPhone_Caca_Proposal.docx` / `.pdf` | Proposal UTS lengkap |
| `docs/` | Diagram user flow, sitemap, wireframe, skema Firestore, panduan & laporan praktikum Minggu 9 |
| `screenshots/` | 10 screenshot aplikasi UTS + tempat untuk screenshot Firebase Console Minggu 9 |
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

### D. Prioritas Fitur
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
| Firebase Firestore | **Rancangan** database untuk Minggu 10 (belum diintegrasikan) |

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

# Web di Chrome — praktikum Minggu 9 (mode Firebase)
flutter run -d chrome --dart-define-from-file=firebase-config.json

# Atau build web statis lalu sajikan folder build/web
flutter build web --release
```

Aplikasi memiliki **dua mode** yang dipilih otomatis di `lib/main.dart`: bila
lima nilai `FIREBASE_*` diberikan, `Firebase.initializeApp()` dijalankan dan
yang tampil adalah alur login Minggu 9; bila tidak, yang tampil adalah prototipe
UTS berbasis mock. Cara mengisi konfigurasi dijelaskan di
[`docs/PANDUAN_FIREBASE_MINGGU_09.md`](docs/PANDUAN_FIREBASE_MINGGU_09.md).

### Langkah 5 — Jalankan pengujian

```bash
flutter analyze   # No issues found
flutter test      # All tests passed! (+50)
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

**Minggu 10 (rencana):** **Cloud Firestore** dengan koleksi `users`, `iphones`, `cases`, `carts`, dan `orders` (+ sub-koleksi `items`). Relasi, field, tipe data, contoh dokumen JSON, serta aturan keamanan dijelaskan di proposal dan `docs/firestore-schema.png`. Abstraksi repository sudah disiapkan sehingga implementasi Firestore dapat menggantikan mock tanpa mengubah UI.

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

## 12. Riwayat Pengembangan

Riwayat commit disusun bertahap mengikuti proses pengerjaan, bukan satu commit besar: inisialisasi project → model & data → repository & state → widget & tema → autentikasi → katalog & compatibility → keranjang/checkout/pesanan → admin → pengujian → dokumentasi & proposal → build web → **(Minggu 9)** koneksi Firebase → halaman Masuk/Daftar → cek status login & tombol Keluar → laporan praktikum → perbaikan temuan uji.

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
`flutter analyze` bersih dan `flutter test` lulus **50 test**.

---

**Case iPhone Caca**  
Developed by **Alysha Syafiya Maisaroh**  
NIM: 23.01.55.0001 — Kelas Pagi A1
