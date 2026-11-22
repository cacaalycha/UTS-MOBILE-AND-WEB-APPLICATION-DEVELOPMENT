# Panduan Praktikum Minggu 10 — Cloud Firestore

**Case iPhone Caca** · Alysha Syafiya Maisaroh · 23.01.55.0001 · Kelas Pagi A1
Mobile and Web Application Development — Ganjil 2026/2027

Topik: **Cloud Firestore: Tiga Collection, Tambah, dan Tampilkan Data**.
Batas pertemuan: target **Chrome**, paket **Spark** (tanpa billing), operasi hanya
**Create** dan **Read**. Update/Delete dibahas Minggu 11.

Project Firebase: `case-iphone-caca` (sama dengan Minggu 9).
Repository: https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT

---

## 1. Pemetaan ERD relasional → Cloud Firestore

| Konsep ERD / SQL | Padanan Firestore | Contoh di Case iPhone Caca |
|---|---|---|
| Tabel | Collection | `users`, `cases`, `orders` |
| Baris (record) | Document (punya Document ID) | `cases/c001` |
| Kolom & nilai | Field & tipe data | `stok: 24` (int), `dibuat_pada: Timestamp` |
| Foreign key + JOIN | Simpan ID referensi + **denormalisasi** | `orders` menyimpan `id_case` **dan** `nama_case` |

Firestore tidak mendukung `JOIN` antar-collection. Karena daftar pesanan selalu
perlu menampilkan nama case, field `nama_case` disalin (denormalisasi) ke
`orders`. Ini padanan langsung dari `nama_ruang` pada contoh RoomBook modul.
Dengan begitu halaman **Pesanan Saya** cukup satu kali baca.

### Struktur 3 collection

| Collection / Doc ID | Field dan tipe data | Kegunaan |
|---|---|---|
| `users/{uid}` (Doc ID = uid Firebase Auth) | `id_pengguna` (String), `nama_lengkap` (String), `email` (String), `nomor_telepon` (String), `peran` (String), `dibuat_pada` (Timestamp) | Profil yang dibuat otomatis saat daftar/masuk; sumber sapaan "Halo, …" di Beranda Firestore |
| `cases/{id_case}` (Doc ID = kode case) | `id_case`, `nama_case`, `brand`, `material`, `kategori`, `status` (String), `harga` (double), `stok` (int), `fitur` (List\<String\>), `model_kompatibel` (List\<String\>), `dibuat_pada` (Timestamp) | Master data case; tampil di Daftar Case dan dropdown Form Pesanan |
| `orders/{auto-ID}` | `id_pesanan`, `id_pengguna`, `id_case`, **`nama_case`** (denormalisasi), `nama_model_iphone`, `tanggal` (`yyyy-MM-dd`), `jam`, `status`, `catatan` (String), `jumlah` (int), `harga_satuan`, `total_harga` (double), `dibuat_pada` (Timestamp) | Transaksi pesanan case; difilter per `id_pengguna` |

Padanan dengan contoh modul: `users → users`, `rooms → cases`,
`reservations → orders`. Empat case awal (`c001`, `c002`, `c003`, `c016`)
diisikan sekali lewat `WriteBatch` bila `cases` masih kosong.

---

## 2. Langkah di Firebase Console (WAJIB, sekali saja)

> Saat pengerjaan kode, database Firestore project `case-iphone-caca` **belum
> aktif**. Probe REST terakhir masih mengembalikan:
> `403 SERVICE_DISABLED — "Cloud Firestore API has not been used in project
> case-iphone-caca before or it is disabled"`. Aplikasi sudah menangani kondisi
> ini dengan banner peringatan, tetapi data baru akan benar-benar tersimpan
> setelah langkah berikut dilakukan.
>
> Jalur pintas bila menu **Firestore Database** tidak langsung mengaktifkan API:
> https://console.developers.google.com/apis/api/firestore.googleapis.com/overview?project=case-iphone-caca
> → klik **Enable**, tunggu beberapa menit, lalu kembali ke langkah 2.

1. Buka https://console.firebase.google.com → pilih project **case-iphone-caca**.
2. Menu kiri: **Databases & Storage → Firestore Database**.
   Pada tampilan Console terbaru, kategori **Build** pada modul sudah berganti nama menjadi
   **Databases & Storage** (klik untuk membuka submenu). Lihat
   [`docs/langkah-aktifkan-firestore.png`](langkah-aktifkan-firestore.png)
   untuk posisi tombolnya pada tampilan Console saat ini.
3. Klik **Create database**.
4. Biarkan edisi **Standard** (gratis pada paket Spark), jangan pilih yang
   meminta billing.
5. Lokasi terdekat: `asia-southeast2` (Jakarta) atau `asia-southeast1`
   (Singapura). Lokasi tidak bisa diubah setelah dibuat.
6. Pilih **Start in production mode** → klik **Create**. Tunggu hingga
   status database "Active".
7. Buka tab **Rules**, ganti seluruh isinya dengan:

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

8. Klik **Publish**. Isi aturan ini juga tersimpan di
   [`firestore.rules`](../firestore.rules) di root repository.

> **Penting:** jangan membiarkan Test Mode
> `allow read, write: if true;` aktif terus-menerus. Siapa pun di internet bisa
> membaca dan menghapus data. Aturan `request.auth != null` memastikan hanya
> pengguna yang sudah login lewat Firebase Authentication yang boleh
> membaca/menulis.

---

## 3. Dependensi dan arsitektur kode

```bash
flutter pub add cloud_firestore:7.1.0
```

Versi terpasang (lihat `pubspec.yaml`): `firebase_core 5.1.0`,
`firebase_auth 7.0.1`, `cloud_firestore 7.1.0`.

Seluruh akses `FirebaseFirestore.instance` **hanya** ada di
`lib/services/layanan_firestore.dart`. UI tidak pernah memanggil Firebase
langsung, sehingga widget test dapat menyuntik `LayananMemori()`.

| Berkas | Peran |
|---|---|
| `lib/data/data_simulasi.dart` | Model `PenggunaFirestore`, `CaseKatalog`, `PesananFirestore` + `toMap/fromMap`, `PesananBentrokException`, `daftarCaseAwal` (4 case), `daftarJamPengambilan` |
| `lib/services/layanan_data.dart` | Kontrak abstrak `LayananData` |
| `lib/services/layanan_firestore.dart` | Implementasi Firestore asli: `users`, `cases`, `orders`, `FieldValue.serverTimestamp()`, `WriteBatch`, `.snapshots()`, cek bentrok |
| `lib/services/layanan_memori.dart` | Implementasi in-memory untuk widget test (bisa diset `simulasiError`) |
| `lib/services/firestore_status.dart` | `ChangeNotifier` status inisialisasi → banner error di Beranda |
| `lib/widgets/components/sapaan_firestore.dart` | Sapaan real-time dari `users/{uid}` |
| `lib/pages/minggu10/beranda_firestore_page.dart` | Beranda Firestore: sapaan, ringkasan 3 collection, pintasan halaman |
| `lib/pages/minggu10/daftar_case_page.dart` | `StreamBuilder<List<CaseKatalog>>` dari `cases` |
| `lib/pages/minggu10/form_pesanan_page.dart` | Form Create dengan validasi + penolakan bentrok |
| `lib/pages/minggu10/pesanan_saya_page.dart` | `StreamBuilder` per pengguna dari `orders` |
| `lib/firebase_katalog_app.dart` | Menyuntik `Provider<LayananData>`, membuat `users/{uid}` + auto-seed `cases` saat login |
| `lib/router/app_router.dart` | Rute `/firestore`, `/firestore/case`, `/firestore/form`, `/firestore/pesanan` |
| `lib/pages/home/beranda_page.dart` | Kartu pintasan "Praktikum Minggu 10 — Firestore" (hanya mode Firebase) |
| `lib/pages/masuk_page.dart` | Kolom **Nama lengkap** pada mode Daftar + `updateDisplayName` |
| `firestore.rules` | Salinan aturan keamanan yang dipublish ke Console |

### Rute halaman (mode Firebase)

```
/login (Firebase) → /beranda (katalog UTS)
                     └─ kartu pintasan → /firestore
                                          ├─ /firestore/case     Daftar Case
                                          ├─ /firestore/form     Form Pesanan
                                          └─ /firestore/pesanan  Pesanan Saya
```

---

## 4. Menjalankan di Chrome

Konfigurasi Web sudah ada di `firebase-config.json` (file ini **di-ignore Git**,
jangan pernah di-commit). Salin dari `firebase-config.example.json` bila belum
ada, lalu isi nilai dari *Project settings → Your apps → Web app → firebaseConfig*.

```bash
cd D:/dev/caseipcaca

# Mode Firebase (Minggu 9 + Minggu 10)
flutter run -d chrome --dart-define-from-file=firebase-config.json

# Alternatif: build release statis
MSYS_NO_PATHCONV=1 flutter build web --release \
  --dart-define-from-file=firebase-config.json
```

Tanpa `--dart-define-from-file`, `DefaultFirebaseOptions.isConfigured` bernilai
`false` dan aplikasi otomatis berjalan dalam **mode prototipe UTS (mock)** supaya
`flutter test` dan GitHub Pages tetap berfungsi.

### Verifikasi otomatis (tanpa Firebase)

```bash
flutter analyze                    # No issues found!
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
  NO_PROXY=localhost,127.0.0.1 flutter test   # All tests passed! (80 test)
```

---

## 5. Daftar periksa Latihan 1–4

### Latihan 1 — Aktifkan database dan model ERD

- [ ] Cloud Firestore aktif di Console (paket Spark).
- [ ] Security Rules `request.auth != null` sudah **Publish**.
- [ ] `cloud_firestore:7.1.0` tercantum di `pubspec.yaml`.
- [ ] 3 model lengkap dengan `toMap` / `fromMap`.
- [ ] Commit: *"Setup Cloud Firestore, Security Rules, dan model 3 collection"*.

### Latihan 2 — Profil pengguna & daftar case dari Firestore

- [ ] `MasukPage` mode Daftar punya kolom **Nama lengkap**.
- [ ] Setelah daftar/masuk, dokumen `users/{uid}` muncul di Console.
- [ ] Collection `cases` terisi otomatis 4 dokumen dan tampil di Daftar Case.
- [ ] Commit: *"Simpan profil ke users dan baca daftar cases dari Firestore"*.

> Akun yang dibuat **sebelum** Minggu 10 belum punya dokumen `users/{uid}`.
> Cukup **Keluar lalu masuk kembali** — `simpanPenggunaSaatLogin` akan
> membuat dokumennya (idempoten: dokumen yang sudah ada tidak ditimpa).

### Latihan 3 — Simpan pesanan & cegah bentrok

- [ ] Dropdown Form Pesanan mengambil pilihan dari `cases`.
- [ ] Kirim form valid menambah dokumen baru di `orders`.
- [ ] Pengajuan ulang pada **case + tanggal + jam** sama ditolak dengan
      SnackBar; jumlah dokumen tidak bertambah.
- [ ] Commit: *"Simpan pesanan ke Firestore dan cegah jadwal bentrok"*.

Aturan bentrok dijalankan **sebelum** `.set()`: query cukup satu
`.where('tanggal', isEqualTo: tanggal)`, lalu sisa pengecekan
(`id_pengguna`, `id_case`, `jam`, status bukan `Dibatalkan`) dilakukan di Dart.
Ini sengaja dilakukan untuk menghindari error *composite index*.

### Latihan 4 — Tampilkan data real-time & tabel uji

- [ ] `StreamBuilder` menangani 3 keadaan: `waiting` (loading),
      `hasError` (pesan ramah), dan daftar kosong (`KeadaanKosong`).
- [ ] `streamPesananSaya()` memakai `.where('id_pengguna', isEqualTo: uid)`
      dan mengurutkan di sisi Dart.
- [ ] Tekan **F5** di Chrome: sapaan nama, daftar case, dan pesanan tetap tampil.
- [ ] Tabel uji ≥ 5 kasus terisi di [`LAPORAN_MINGGU_10.md`](LAPORAN_MINGGU_10.md)
      dan di README.
- [ ] Screenshot ketiga collection di Console disimpan di `screenshots/`.
- [ ] ≥ 2 commit baru ter-push ke GitHub.

### Uji teman

1. Teman mendaftarkan akun simulasi baru → namanya tampil di sapaan Beranda.
2. Teman mengajukan satu pesanan valid, **refresh Chrome**, data tetap muncul.
3. Teman mencoba case + tanggal + jam yang sama → penolakan bentrok.
4. Teman masuk dengan akun berbeda → daftar Pesanan Saya terpisah.

---

## 6. Tabel uji Firestore (≥ 5 kasus)

| # | Kasus uji | Langkah | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|---|
| 1 | Tambah data valid | Kirim Form Pesanan dengan isian lengkap | Dokumen tampil di `orders` & Pesanan Saya | *isi setelah uji di Chrome* |
| 2 | Tolak pesanan bentrok | Ajukan case, tanggal, dan jam yang sama | Muncul SnackBar "sudah dipesan"; dokumen tidak bertambah | *isi setelah uji di Chrome* |
| 3 | Bertahan saat refresh | Tekan F5 / muat ulang Chrome | Sapaan nama, daftar case, & pesanan tetap tampil | *isi setelah uji di Chrome* |
| 4 | Isolasi antar akun | Keluar lalu masuk dengan akun simulasi kedua | Pesanan akun pertama tidak muncul di akun kedua | *isi setelah uji di Chrome* |
| 5 | Security Rules | Uji akses tanpa login / saat aturan ditolak | Firebase mengembalikan `permission-denied` | *isi setelah uji di Chrome* |
| 6 | Auto-seed cases | Login pertama setelah database kosong | 4 dokumen `cases` dibuat sekali, tidak duplikat saat login ulang | *isi setelah uji di Chrome* |
| 7 | Form tidak valid | Kosongkan jumlah / pilih jam kosong lalu Kirim | Pesan validasi muncul, tidak ada dokumen baru | *isi setelah uji di Chrome* |

Kolom **Hasil nyata** wajib diisi sendiri setelah praktikum di Chrome dan
Firebase Console. Versi siap cetak ada di `docs/LAPORAN_MINGGU_10.md`.

---

## 7. Masalah umum dan solusinya

| Gejala / pesan | Penyebab | Solusi |
|---|---|---|
| `[cloud_firestore/permission-denied]` | Rules masih `allow false` (production default) atau pengguna belum login | Pastikan Rules memakai `allow read, write: if request.auth != null;` dan sudah **Publish** |
| `[cloud_firestore/failed-precondition] requires an index` | Menggabungkan `.where()` dan `.orderBy()` pada field berbeda tanpa indeks | Hapus `.orderBy()` dari query; urutkan list di Dart dengan `.sort()` |
| Loading berputar terus (`waiting`) | Database Firestore belum dibuat / Cloud Firestore API disabled | Cek **Build → Firestore Database** di Console, klik **Create database** |
| `403 Cloud Firestore API has not been used ... or is disabled` | API belum diaktifkan untuk project | Sama seperti di atas; aktivasi database akan mengaktifkan API otomatis |
| Widget test gagal karena Firebase | Halaman memanggil `FirebaseFirestore.instance` saat test | Suntik `LayananMemori()` lewat parameter `layanan` (sudah diterapkan di `test/minggu10_*_test.dart`) |
| Sapaan masih "Halo, selamat datang" | `users/{uid}` belum ada karena akun dibuat sebelum Minggu 10 | **Keluar lalu masuk kembali** |
| Banner merah "Firestore belum aktif" di Beranda | `simpanPenggunaSaatLogin` / auto-seed gagal | Aktifkan database + publish Rules, lalu refresh Chrome |

---

## 8. Persiapan Minggu 11

Melengkapi CRUD dengan **Edit (Update)** dan **Hapus (Delete)** beserta dialog
konfirmasi, serta memetakan operasi aplikasi ke endpoint RESTful
(`GET`, `POST`, `PUT`, `DELETE`). Untuk Case iPhone Caca: ubah status/jumlah
pesanan dan batalkan pesanan (status `Dibatalkan` sudah disiapkan sebagai
pengecualian pengecekan bentrok), serta kelola master `cases` dari halaman admin.
