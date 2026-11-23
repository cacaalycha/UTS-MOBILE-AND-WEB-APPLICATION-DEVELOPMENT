# Laporan Praktikum Minggu 10 — Cloud Firestore: Tiga Collection, Tambah, dan Tampilkan Data

**Judul aplikasi:** Case iPhone Caca

| Identitas | Isian |
|---|---|
| Nama / NIM | Alysha Syafiya Maisaroh / 23.01.55.0001 |
| Kelas dan judul aplikasi | Pagi A1 — Case iPhone Caca |
| Tautan repository GitHub | https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT |
| Nama project Firebase | `case-iphone-caca` |
| Paket Firebase | Spark (tanpa billing account) |
| Target | Chrome |
| Dependensi | `firebase_core 5.1.0`, `firebase_auth 7.0.1`, `cloud_firestore 7.1.0` |

> **Status pengisian (per 22 November 2026):** ✅ = sudah diverifikasi otomatis
> (`flutter analyze`, `flutter test`, `flutter build web`, dan probe REST
> Firestore) · ⏳ = perlu dibuktikan sendiri di Chrome. **Cloud Firestore sudah
> aktif dan Security Rules sudah dipublikasikan**; yang tersisa tinggal uji
> langsung di browser dan screenshot Console yang hanya bisa diambil dari akun
> Google pemilik project.

---

## 1. Tujuan

Memindahkan data aplikasi dari memori ke **Cloud Firestore** agar tersimpan
permanen dan tampil **real-time**. Mahasiswa mampu: menjelaskan perbedaan
SQL/tabel dengan basis data dokumen, mengaktifkan Firestore pada paket Spark dan
menerbitkan Security Rules, memetakan ERD menjadi tiga collection, menulis serta
membaca data dengan aturan bisnis, dan menggunakan `StreamBuilder` +
`.snapshots()` yang terfilter per pengguna.

### Pemetaan ERD → Firestore

| Konsep ERD / SQL | Padanan Firestore | Contoh di Case iPhone Caca |
|---|---|---|
| Tabel | Collection | `users`, `cases`, `orders` |
| Baris (record) | Document (Document ID) | `cases/c001` |
| Kolom & nilai | Field & tipe data | `stok: 24` (int), `dibuat_pada: Timestamp` |
| Foreign key + JOIN | Simpan ID referensi + denormalisasi | `orders` menyimpan `id_case` **dan** `nama_case` |

Padanan contoh RoomBook pada modul: `users → users`, `rooms → cases`,
`reservations → orders`.

### Struktur 3 collection

| Collection / Doc ID | Field | Kegunaan |
|---|---|---|
| `users/{uid}` | `id_pengguna`, `nama_lengkap`, `email`, `nomor_telepon`, `peran` (String), `dibuat_pada` (Timestamp) | Profil otomatis saat daftar/masuk; sumber sapaan Beranda |
| `cases/{id_case}` | `id_case`, `nama_case`, `brand`, `material`, `kategori`, `status` (String), `harga` (double), `stok` (int), `fitur`, `model_kompatibel` (List\<String\>), `dibuat_pada` (Timestamp) | Master case auto-seed 4 dokumen; Daftar Case & dropdown Form |
| `orders/{auto-ID}` | `id_pesanan`, `id_pengguna`, `id_case`, **`nama_case`**, `nama_model_iphone`, `tanggal`, `jam`, `status`, `catatan` (String), `jumlah` (int), `harga_satuan`, `total_harga` (double), `dibuat_pada` (Timestamp) | Transaksi; difilter `id_pengguna == uid` |

---

## 2. Luaran pertemuan

| Butir | Status | Bukti |
|---|---|---|
| Cloud Firestore aktif di Console (Spark) | ✅ | Database `(default)` aktif; probe REST tidak lagi `SERVICE_DISABLED` |
| Security Rules `request.auth != null` terpublikasi | ✅ | Diverifikasi 22 Nov 2026: tanpa login `403`, dengan login `200 OK`. Aturan ada di `firestore.rules` |
| `cloud_firestore:7.1.0` terpasang | ✅ | `pubspec.yaml` + `pubspec.lock` |
| 3 collection terhubung dari aplikasi Flutter | ✅ | `lib/services/layanan_firestore.dart` |
| Form Pesanan menyimpan data baru | ✅ / ⏳ | Kode + test otomatis; ⏳ bukti Console |
| Jadwal bentrok ditolak | ✅ / ⏳ | `PesananBentrokException` + test SnackBar; ⏳ bukti Chrome |
| Beranda & Pesanan Saya real-time, bertahan saat F5 | ✅ / ⏳ | `StreamBuilder` + `.snapshots()`; ⏳ bukti Chrome |
| `flutter analyze` bersih & seluruh test lulus | ✅ | Lihat bagian 7 |
| Tabel uji Firestore ≥ 5 kasus | ✅ struktur / ⏳ hasil nyata | 7 kasus di bagian 3 |
| Screenshot ketiga collection di Console | ⏳ | `screenshots/12-firestore-users.png`, `13-firestore-cases.png`, `14-firestore-orders.png` |
| ≥ 2 commit baru ter-push | ✅ | 3 commit bertahap (lihat bagian 6) |

---

## 3. Tabel uji Firestore (7 kasus)

Hasil yang diharapkan ditulis **sebelum** menguji di Chrome dan Firebase Console.
Kasus berstatus ✅ dibuktikan oleh test otomatis
(`test/minggu10_model_test.dart`, `test/minggu10_layanan_test.dart`,
`test/minggu10_widget_test.dart`) yang memakai `LayananMemori`, sehingga tidak
membutuhkan koneksi Firebase.

| # | Kasus uji | Langkah | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|---|
| 1 | Tambah data valid | Kirim Form Pesanan dengan isian lengkap (case, model, jumlah, tanggal, jam) | Dokumen baru muncul di `orders` dan langsung tampil di **Pesanan Saya** tanpa refresh | ✅ Sesuai (test layanan + widget) / ⏳ Console |
| 2 | Tolak pesanan bentrok | Ajukan **case + tanggal + jam** yang sama untuk pengguna yang sama | SnackBar *"… sudah dipesan pada tanggal … jam …"*; jumlah dokumen tidak bertambah | ✅ Sesuai (unit + widget test) / ⏳ Chrome |
| 3 | Bertahan saat refresh | Tekan **F5** di Chrome setelah menambah pesanan | Sapaan nama, daftar case, dan pesanan tetap tampil (data dari server, bukan memori) | ⏳ isi setelah uji di Chrome |
| 4 | Isolasi antar akun | Keluar, lalu masuk dengan akun simulasi kedua | Pesanan akun pertama **tidak muncul** di Pesanan Saya akun kedua | ✅ Sesuai (`gantiPengguna` pada test) / ⏳ Chrome |
| 5 | Security Rules | Uji akses tanpa login / saat aturan ditolak | Firebase mengembalikan `permission-denied`, UI menampilkan pesan error ramah | ✅ **Diverifikasi 22 Nov 2026**: tanpa login → `403 Missing or insufficient permissions`; dengan akun uji login → `200 OK`. Akun uji dihapus setelah cek |
| 6 | Auto-seed cases | Login pertama saat `cases` masih kosong | 4 dokumen dibuat sekali via `WriteBatch`; login ulang tidak menduplikasi | ✅ Sesuai (unit test) / ⏳ Console |
| 7 | Validasi form & tiga keadaan Stream | Kosongkan jumlah; lalu simulasikan error stream | Pesan validasi muncul, tidak ada dokumen baru; UI menampilkan `waiting` / `error` / `empty` dengan benar | ✅ Sesuai (widget test) |

> Catatan aturan bentrok: status `Dibatalkan` dikecualikan dari pengecekan,
> sepadan dengan `status != 'ditolak'` pada RoomBook. Pengecekan dijalankan
> **sebelum** `.set()`, dengan satu `.where('tanggal')` saja; sisa filter
> dilakukan di Dart agar tidak memicu error *composite index*.

---

## 4. Daftar periksa Latihan 1–4

| Latihan | Butir | Status |
|---|---|---|
| 1 | Cloud Firestore aktif pada paket Spark | ✅ |
| 1 | Security Rules `request.auth != null` dipublikasikan | ✅ |
| 1 | `cloud_firestore:7.1.0` di `pubspec.yaml` | ✅ |
| 1 | Model `PenggunaFirestore`, `CaseKatalog`, `PesananFirestore` + `toMap/fromMap` | ✅ |
| 2 | Mode Daftar punya kolom **Nama lengkap** | ✅ |
| 2 | Dokumen `users/{uid}` muncul setelah daftar/masuk | ⏳ |
| 2 | `cases` terisi otomatis dan tampil di Daftar Case | ✅ kode / ⏳ Console |
| 3 | Dropdown mengambil pilihan dari `cases` | ✅ |
| 3 | Form valid menambah dokumen `orders` | ✅ kode / ⏳ Console |
| 3 | Pengajuan ulang ditolak dengan SnackBar | ✅ kode / ⏳ Chrome |
| 4 | `StreamBuilder` menangani `waiting` / `error` / kosong | ✅ |
| 4 | `streamPesananSaya()` terfilter `id_pengguna == uid`, urut di Dart | ✅ |
| 4 | Data bertahan setelah F5 | ⏳ |
| 4 | Tabel uji ≥ 5 kasus & screenshot 3 collection | ✅ struktur / ⏳ screenshot |
| 4 | ≥ 2 commit baru ter-push | ✅ |

### Uji teman

| # | Skenario | Temuan / hasil |
|---|---|---|
| 1 | Teman mendaftarkan akun simulasi baru dan memastikan namanya tampil di sapaan Beranda | ⏳ isi setelah uji |
| 2 | Teman mengajukan satu pesanan valid, me-refresh Chrome, memastikan data tetap muncul | ⏳ isi setelah uji |
| 3 | Teman mencoba case, tanggal, dan jam yang sama untuk menguji penolakan bentrok | ⏳ isi setelah uji |
| 4 | Teman masuk memakai akun berbeda, memastikan daftar Pesanan Saya terpisah | ⏳ isi setelah uji |

---

## 5. Bukti screenshot Firebase Console

Ambil tiga screenshot di **Firebase Console → Build → Firestore Database → Data**
setelah menjalankan aplikasi di Chrome, lalu simpan dengan nama:

```
screenshots/12-firestore-users.png    → collection users, dokumen {uid}
screenshots/13-firestore-cases.png    → collection cases, 4 dokumen auto-seed
screenshots/14-firestore-orders.png   → collection orders, minimal 1 dokumen
```

![Collection users](../screenshots/12-firestore-users.png)
![Collection cases](../screenshots/13-firestore-cases.png)
![Collection orders](../screenshots/14-firestore-orders.png)

> ⏳ Berkas-berkas ini **belum ada** dan sengaja tidak dibuat-reka: screenshot
> hanya bisa diambil dari project Firebase milik mahasiswa. Setelah disimpan,
> gambar di atas tampil otomatis. Screenshot tab **Rules** yang menunjukkan
> `allow read, write: if request.auth != null;` juga baik dilampirkan sebagai
> `screenshots/15-firestore-rules.png`.

---

## 6. Riwayat commit Minggu 10

| # | Pesan commit | Isi |
|---|---|---|
| 1 | `feat(firestore): setup Cloud Firestore, rules, dan model 3 collection` | `cloud_firestore:7.1.0`, `firestore.rules`, `lib/data/data_simulasi.dart`, `lib/services/layanan_data.dart`, `layanan_firestore.dart`, `layanan_memori.dart`, `firestore_status.dart` |
| 2 | `feat(firestore): halaman Minggu 10, integrasi rute, dan widget test` | 4 halaman `lib/pages/minggu10/`, `sapaan_firestore.dart`, `app_router.dart`, `beranda_page.dart`, `masuk_page.dart`, `cek_status_login.dart`, `firebase_katalog_app.dart`, 3 file test Minggu 10 |
| 3 | `docs: panduan, laporan, dan tabel uji Firestore Minggu 10` | Dokumen ini, `PANDUAN_FIRESTORE_MINGGU_10.md`, pembaruan README, `pubspec.yaml` |

Modul meminta **minimal 2 commit baru ter-push**; tersedia 3 commit bertahap.
Semua pesan commit ditulis dalam bahasa Indonesia mengikuti riwayat Minggu 9.

### Temuan uji dan perbaikan selama pengerjaan

- **Firestore API sempat belum aktif → SELESAI 22 November 2026.** Probe REST
  awal mengembalikan `403 SERVICE_DISABLED — Cloud Firestore API has not been
  used ... or is disabled`. Tidak bisa diperbaiki dari kode: harus **Create
  database** di Console. Sambil menunggu, `FirestoreStatus` menangkap kegagalan
  inisialisasi dan menampilkan **banner peringatan** di Beranda Firestore,
  bukan crash. Setelah database dibuat dan aturan dipublish, probe berubah
  menjadi `403 Missing or insufficient permissions` untuk akses tanpa login —
  persis perilaku `request.auth != null`. Uji dengan akun sementara
  menghasilkan `200 OK`; akun tersebut langsung dihapus agar data tetap bersih.
- **Composite index.** Menggabungkan `.where()` dan `.orderBy()` pada field
  berbeda memicu `failed-precondition`. Solusi sesuai modul: hanya satu
  `.where()` di Firestore, pengurutan `.sort()` di Dart.
- **Test ikut gagal karena Firebase.** Sesuai catatan modul, semua halaman
  Minggu 10 menerima `LayananData` lewat parameter; test menyuntik
  `LayananMemori()` yang bisa menyimulasikan error stream.
- **Dropdown Form Pesanan overflow & tidak terkirim.** Ditambahkan
  `isExpanded: true` dan nilai default `idTerpilih` diteruskan ke `_kirim`;
  test memakai viewport besar agar tidak ada `RenderFlex overflow`.
- **`AuthProvider` ambigu** (ada di `provider` dan `firebase_auth`). Di atasi
  dengan `import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider;`.
- **Sapaan kosong untuk akun lama.** Akun yang dibuat sebelum Minggu 10 belum
  punya `users/{uid}`; solusinya **Keluar lalu masuk kembali** karena
  `simpanPenggunaSaatLogin` dijalankan setiap kali `FirebaseKatalogApp` dibuat.

---

## 7. Refleksi individu

**1. Field apa yang Anda denormalisasi pada collection utama proyek Anda dan mengapa?**

Field `nama_case` pada collection `orders`. Firestore tidak memiliki perintah
`JOIN` antar-collection; kalau `orders` hanya menyimpan `id_case`, halaman
**Pesanan Saya** harus melakukan query tambahan ke `cases` untuk setiap baris
agar nama produk bisa ditampilkan. Menyalin `nama_case` (bersama `harga_satuan`
dan `total_harga`) membuat daftar pesanan cukup **satu kali baca** dan tetap
bersejarah benar walaupun harga master case kelak berubah. Risikonya adalah
data ganda bila nama case diedit, sehingga pada Minggu 11 perlu strategi
update (misalnya menulis ulang dokumen `orders` terkait) atau menerima bahwa
nama pada pesanan adalah *snapshot saat transaksi* — yang justru memang
diinginkan untuk bukti pesanan.

**2. Kendala apa yang muncul saat menghubungkan Firestore dan bagaimana mengatasinya?**

- Database/API belum aktif di Console → tidak ada perbaikan sisi kode; dibuat
  mekanisme `FirestoreStatus` + banner agar aplikasi tetap bisa dibuka dan
  pesan kesalahannya jelas, lalu langkah aktivasi ditulis di panduan.
- Error *composite index* dihindari sejak awal dengan satu `.where()` dan
  `.sort()` di Dart, persis anjuran modul.
- Widget test lama (50 test Minggu 9/UTS) tidak boleh rusak. Semua akses
  `FirebaseFirestore.instance` dikonsentrasikan di `layanan_firestore.dart`,
  halaman menerima `LayananData`, dan test memakai `LayananMemori`. Mode mock
  di `main.dart` tetap dipertahankan supaya `flutter test` dan GitHub Pages
  tidak membutuhkan Firebase.
- `FieldValue.serverTimestamp()` menghasilkan `Timestamp`, sementara
  `LayananMemori` memakai `DateTime`. Model dibuat agnostik lewat helper
  `bacaWaktu()` yang menerima `Timestamp`, `DateTime`, maupun `String`, supaya
  `fromMap` bisa dipakai dua implementasi sekaligus.
- Beberapa temuan kecil pada UI (dropdown overflow, nilai default tidak
  terkirim, import ambigu) ditemukan lewat `flutter analyze` dan widget test,
  lalu diperbaiki sebelum build release.

**3. Fitur edit dan hapus apa yang akan Anda tambahkan pada Minggu 11?**

Pada `orders`: ubah status pesanan (`Menunggu` → `Diproses`/`Selesai`/
`Dibatalkan`), ubah jumlah/jam pengambilan dengan pengecekan bentrok ulang, dan
**hapus/batalkan pesanan** lewat dialog konfirmasi. Status `Dibatalkan` sudah
disiapkan sebagai pengecualian pada aturan bentrok. Pada `cases`: tambah, edit,
dan hapus master case dari halaman admin (dengan konfirmasi agar dokumen
`orders` yang sudah mereferensikan case tidak kehilangan konteks). Operasi
tersebut dipetakan ke endpoint RESTful `GET` (baca), `POST` (tambah),
`PUT` (ubah), dan `DELETE` (hapus).

---

## 8. Cara mengulang verifikasi

```bash
cd D:/dev/caseipcaca
flutter analyze                    # No issues found! (0 issues)
flutter test                       # All tests passed! (83 test)
MSYS_NO_PATHCONV=1 flutter build web --release \
  --dart-define-from-file=firebase-config.json
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

Panduan lengkap (setup Console, Security Rules, pemetaan ERD, troubleshooting)
ada di [`docs/PANDUAN_FIRESTORE_MINGGU_10.md`](PANDUAN_FIRESTORE_MINGGU_10.md).
Panutan modul: *Cloud Firestore: Tiga Collection, Tambah, dan Tampilkan Data*
(Minggu 10) dan materi ajar `materi-ajar-minggu-10-firestore.pptx`.
