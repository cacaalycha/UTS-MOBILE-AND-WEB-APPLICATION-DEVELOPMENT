# Ringkasan Tahapan & Perbaikan — Case iPhone Caca

Dokumen ini merangkum seluruh tahapan pengerjaan dan perbaikan yang sudah masuk ke repository
`cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT`. Disusun untuk memudahkan dosen
menelusuri progres lewat riwayat commit, bukan hanya melihat hasil akhir.

**Identitas**

| Keterangan | Isi |
|---|---|
| Nama | Alysha Syafiya Maisaroh |
| NIM | 23.01.55.0001 |
| Kelas | Pagi A1 |
| Judul aplikasi | Case iPhone Caca |
| Repository | https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT |
| Demo web | https://cacaalycha.github.io/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT/ |
| Total commit | 35 (periode 2 Nov – 23 Nov 2026) |
| Commit terakhir | `c5d6320` |

---

## 1. Tahapan Pengerjaan

### Tahap 1 — Inisialisasi & fondasi project
**Commit:** `023275f` → `c052f9b`

- Menyiapkan project Flutter multi-platform (Android, iOS, Web, Windows, Linux, macOS).
- Membuat model domain: iPhone, case, pengguna, dan pesanan beserta mock data.
- Membuat abstraksi repository + implementasi mock, serta Provider untuk auth, produk,
  keranjang, dan pesanan.
- Membangun komponen UI reusable, app shell, tema, dan navigation shell.
- Mengimplementasikan halaman:
  - Login & register dengan validasi form.
  - Beranda, pilih model iPhone, katalog, detail case, dan Compatibility Checker.
  - Keranjang, checkout, konfirmasi, dan riwayat pesanan.
  - Dashboard admin & manajemen produk.
- Merangkai rute dengan `go_router` dan role guard (pembeli vs admin).

### Tahap 2 — Pengujian & kelengkapan UTS
**Commit:** `8bf7202`, `aab508d`, `5e7c6d6`

- Menambah widget test dan unit test untuk alur inti aplikasi.
- Menyusun proposal UTS (DOCX + PDF): problem statement, persona, minimal 5 user story,
  kebutuhan fungsional & non-fungsional, user flow, sitemap, wireframe/Figma, tech stack,
  dan rancangan database Firestore.
- Membuat diagram perancangan: `docs/firestore-schema.png`, user flow, sitemap, wireframe.
- Merapikan README sesuai ketentuan dosen (identitas, deskripsi, Figma, cara menjalankan,
  screenshot, tabel uji).

### Tahap 3 — Minggu 9: Firebase Authentication
**Commit:** `76855a3` → `a19f7c7`

- Menambah `firebase_core` 5.1.0 dan `firebase_auth` 7.0.1.
- Membuat `firebase_options.dart` yang membaca konfigurasi Web dari environment variable.
- Menerapkan dua mode startup:
  - **Tanpa config** → prototipe UTS memakai mock repository.
  - **Dengan `firebase-config.json`** → mode Firebase Authentication.
- Membuat halaman Masuk/Daftar Firebase dengan validasi dan terjemahan kode error.
- Menambah `CekStatusLogin`, tombol Keluar, dan halaman utama setelah login.
- Membuat panduan, laporan praktikum, dan tabel uji Minggu 9.
- **Perbaikan:** tombol tidak lagi binda setelah login sukses (`a19f7c7`).

### Tahap 4 — Minggu 10: Cloud Firestore
**Commit:** `d28d59a` → `12fe75c`

- Menambah `cloud_firestore` 7.1.0 dan file `firestore.rules`.
- Membuat tiga collection: `users/{uid}`, `cases/{id_case}`, `orders/{auto-ID}`.
- Membuat abstraksi `LayananData` + dua implementasi:
  - `LayananFirestore` untuk runtime.
  - `LayananMemori` untuk widget test (tidak membutuhkan Firebase).
- Fitur: profil pengguna, auto-seed 4 case awal dengan `WriteBatch`,
  pemesanan dengan `FieldValue.serverTimestamp()`, dan daftar pesanan real-time
  lewat `.snapshots()` + `StreamBuilder`.
- Menangani aturan bisnis: kombinasi `id_pengguna + id_case + tanggal + jam` tidak boleh
  ganda (`PesananBentrokException`). Query hanya memakai satu `.where()` agar tidak
  membutuhkan *composite index*.
- Mengintegrasikan Firestore ke rute dan halaman aplikasi, termasuk ringkasan status error.
- Menambah panduan, laporan, tabel uji 7 kasus, dan screenshot beranotasi.
- Firestore aktif dan Rules berhasil diverifikasi:
  - tanpa login → `403 Missing or insufficient permissions`;
  - dengan login → `200 OK`.

### Tahap 5 — Peran admin di mode Firebase
**Commit:** `2c69ec8`, `a1c7825`

- Masalah: `adminf@gmail.com` tetap tampil sebagai "admin (pelanggan)" karena Firebase Auth
  tidak menyimpan field peran.
- Solusi: variabel `FIREBASE_ADMIN_EMAILS` di `firebase-config.json`, diparse oleh
  `lib/utils/peran_firebase.dart`, lalu dipakai `FirebaseAuthRepository` untuk memetakan
  email tersebut ke `UserRole.admin`.
- Router mengarahkan admin Firebase langsung ke `/admin`, dan dashboard admin menampilkan
  pintasan praktikum Firestore.
- Menambah `test/peran_firebase_test.dart` dan memperbarui dokumentasi.

### Tahap 6 — Minggu 11: CRUD lengkap (Edit, Hapus, Konfirmasi)
**Commit:** `e4a3ff3` → `c5d6320`

- **Rules diperketat** (`e4a3ff3`):
  - `users/{uid}` hanya untuk uid bersangkutan.
  - `cases` bisa dibaca dan ditulis oleh pengguna login.
  - `orders`: `create` hanya jika `id_pengguna == uid` dan status `Menunggu`;
    `update`/`delete` hanya oleh pemilik dan status masih `Menunggu`.
- **Aturan bisnis dipusatkan** di `lib/data/data_simulasi.dart`:
  - `pastikanBolehDiubah()` — menolak bukan pemilik atau status terkunci.
  - `adaBentrokPesanan()` dengan parameter `abaikanId` agar dokumen yang sedang diubah
    tidak dianggap bentrok dengan dirinya sendiri.
  - `OperasiDitolakException` untuk pesan galat yang ramah pengguna.
- **Layer layanan** (`e7831af`):
  - `ubahPesanan()` memakai `doc.update()` (bukan `set()`) sehingga `dibuat_pada`,
    `id_pengguna`, dan `status` tetap utuh, serta menambah `diubah_pada`.
  - `hapusPesanan()` memanggil `docRef.delete()`.
- **UI** (`e7831af`):
  - Form yang sama dipakai untuk tambah dan ubah; mode ubah mengisi data lama dan
    mengganti tombol menjadi **Simpan Perubahan**.
  - Menu aksi Ubah/Hapus otomatis nonaktif bila status bukan `Menunggu`.
  - Hapus memakai `showDialog<bool>` yang menyebut case, tanggal, dan jam;
    **Batal** tidak mengubah data, **Hapus** memunculkan SnackBar.
- **Dokumentasi** (`0093b7b`, `c5d6320`): `PANDUAN_CRUD_MINGGU_11.md`,
  `LAPORAN_MINGGU_11.md`, tabel uji 8 kasus, dan screenshot anotasi lokasi menu Rules.

---

## 2. Daftar Perbaikan

| Masalah / temuan | Perbaikan | Commit |
|---|---|---|
| Tombol tidak aktif lagi setelah login sukses | Perbaikan state pada halaman Masuk | `a19f7c7` |
| Tombol Masuk tidak memunculkan Beranda pada mode Firebase | Alur login diarahkan ke katalog Beranda lewat `FirebaseKatalogApp`, dengan fallback `currentUser` | `d879ca6`, `9da63a3` |
| Firestore belum aktif (`403 SERVICE_DISABLED`) | Database `(default)` dibuat di Console; akses diverifikasi ulang dengan REST | `12fe75c` |
| Rules masih `if false;` | Diganti `request.auth != null;`, lalu diverifikasi (tanpa login 403, dengan login 200) | `12fe75c` |
| Lokasi `firebaseConfig` di Console membingungkan | Panduan + screenshot beranotasi dan tooling `tools/isi_firebase_config.py` | `687f59c` |
| Akun admin tampil sebagai pelanggan | `FIREBASE_ADMIN_EMAILS` + `lib/utils/peran_firebase.dart` | `a1c7825` |
| Rules Minggu 10 terlalu longgar | Rules kepemilikan & status `Menunggu` | `e4a3ff3` |
| Belum ada edit/hapus pesanan | `ubahPesanan()`, `hapusPesanan()`, form mode ubah, dialog konfirmasi | `e7831af` |
| Edit bisa menimpa field audit | `doc.update()` + field `diubah_pada`, bukan `set()` | `e7831af` |
| Edit ke jadwal sendiri dianggap bentrok | `abaikanId` pada pengecekan bentrok | `e4a3ff3`, `e7831af` |
| Menu aksi tetap aktif pada status terkunci | `enabled: pesanan.bisaDiubah` | `e7831af` |
| Deskripsi `firestore.rules` di README masih versi Minggu 10 | Diselaraskan dengan Rules Minggu 11 | `0093b7b` |
| Lokasi tab Rules sulit ditemukan di Console baru | Screenshot beranotasi `docs/lokasi-rules-m11.png` | `c5d6320` |

---

## 3. Hasil Verifikasi Terakhir

```bash
flutter analyze   # No issues found!
flutter test      # All tests passed! (107 test)
flutter build web --release --dart-define-from-file=firebase-config.json
                  # √ Built build/web
```

Repository bersih, tidak ada commit yang belum ter-push, dan `HEAD` lokal sama dengan
`refs/heads/main` di GitHub (`c5d6320`).

---

## 4. Yang Masih Menjadi Tugas Mahasiswa

Hal ini tidak bisa diambil alih karena bergantung pada akun Firebase dan browser milik sendiri:

1. Salin isi `firestore.rules` ke Firebase Console → **Rules** → **Publish**.
2. Uji manual di Chrome dan isi kolom **Hasil nyata** di `docs/LAPORAN_MINGGU_11.md`.
3. Simpan screenshot:
   - `screenshots/16-firestore-rules-m11.png`
   - `screenshots/17-ubah-pesanan.png`
   - `screenshots/18-dialog-hapus.png`
   - serta `screenshots/12-firestore-*.png` sampai `15-firestore-rules.png` untuk Minggu 10.
4. Buat video presentasi UTS maksimal 10 menit sesuai ketentuan dosen.

---

## 5. Dokumen Terkait

- [`PANDUAN_CRUD_MINGGU_11.md`](PANDUAN_CRUD_MINGGU_11.md)
- [`LAPORAN_MINGGU_11.md`](LAPORAN_MINGGU_11.md)
- [`PANDUAN_FIRESTORE_MINGGU_10.md`](PANDUAN_FIRESTORE_MINGGU_10.md)
- [`LAPORAN_MINGGU_10.md`](LAPORAN_MINGGU_10.md)
- [`LAPORAN_MINGGU_09.md`](LAPORAN_MINGGU_09.md)
- [`lokasi-rules-m11.png`](lokasi-rules-m11.png)
