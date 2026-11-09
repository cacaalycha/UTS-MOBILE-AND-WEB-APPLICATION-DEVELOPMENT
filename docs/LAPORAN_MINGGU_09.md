# Laporan Praktikum Minggu 9 — Menghubungkan Firebase dan Login Email/Password

**Judul aplikasi:** Case iPhone Caca

| Identitas | Isian |
|---|---|
| Nama / NIM | Alysha Syafiya Maisaroh / 23.01.55.0001 |
| Kelas dan judul aplikasi | Pagi A1 — Case iPhone Caca |
| Tautan repository GitHub | https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT |
| Nama project Firebase | `case-iphone-caca-2301550001` *(sesuaikan dengan nama di Console)* |
| Paket / penyedia | Spark (tanpa billing) / Email-Password saja |
| Target | Chrome |

> **Status pengisian:** ✅ = sudah diverifikasi otomatis di repositori ·
> ⏳ = perlu diisi/dibuktikan setelah project Firebase dibuat dan dijalankan di
> Chrome. Konfigurasi `firebaseConfig` hanya bisa diperoleh dari akun Google
> pemilik project, sehingga bagian ⏳ tidak dapat diisi otomatis.

---

## 1. Tujuan

Menjelaskan peran Firebase Authentication sebagai layanan backend, membedakan
autentikasi dan otorisasi, membangun alur daftar–masuk–keluar, mengarahkan
pengguna dengan `authStateChanges()`, serta menerjemahkan
`FirebaseAuthException.code` menjadi pesan yang jelas.

| Istilah | Pertanyaan | Penerapan di Case iPhone Caca |
|---|---|---|
| Autentikasi | Siapa kamu? | Masuk dengan email & password lewat `FirebaseAuth.instance` |
| Otorisasi | Boleh melakukan apa? | `CekStatusLogin` hanya membuka `HalamanUtama` saat `snapshot.hasData` |
| Token | Bukti sudah login | Dikelola otomatis oleh SDK Firebase, tidak disimpan manual |
| Sesi | Berapa lama tetap masuk? | Tetap masuk setelah refresh, sampai tombol **Keluar** ditekan |

---

## 2. Luaran pertemuan

| Butir | Status | Bukti |
|---|---|---|
| Project Firebase Spark terhubung, tanpa billing account | ⏳ | Isi `firebase-config.json` dari Console |
| Daftar, masuk, dan keluar berjalan di Chrome | ⏳ | Uji manual butir 1, 6, 8 pada tabel uji |
| Halaman utama hanya terbuka setelah login | ✅ | `CekStatusLogin` + `StreamBuilder<User?>` |
| Sesi bertahan setelah refresh | ⏳ | Butir 7 pada tabel uji |
| Kesalahan login tampil sebagai pesan yang jelas | ✅ | 7 kode dipetakan + 11 test di `test/validasi_auth_test.dart` |
| Tabel uji login ≥ 5 kasus terisi | ✅ / ⏳ | 12 kasus di bawah; 6 sudah diverifikasi otomatis |
| Screenshot daftar pengguna di Firebase Console | ⏳ | Simpan ke `screenshots/11-firebase-users.png` |
| ≥ 2 commit baru ter-push | ✅ | 5 commit bertahap (lihat bagian 5) |

---

## 3. Tabel uji login (12 kasus)

Hasil yang diharapkan ditulis **sebelum** mencoba; hasil nyata dicatat setelah
menjalankan di Chrome. Kasus berstatus ✅ dibuktikan oleh test otomatis
(`test/validasi_auth_test.dart` dan `test/masuk_page_test.dart`) karena tidak
membutuhkan koneksi Firebase.

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|---|
| 1 | Login benar | Akun simulasi terdaftar, password benar | Halaman Utama tampil tanpa Navigator | ⏳ isi setelah uji di Chrome |
| 2 | Password salah | Email terdaftar + password `salah123` | `Email atau password salah` | ⏳ isi setelah uji di Chrome |
| 3 | Email tidak valid | `bukan-email` + `123456` | `Format email belum benar` | ✅ Sesuai (unit + widget test) |
| 4 | Kolom kosong | — (kedua kolom dikosongkan) | `Email wajib diisi` dan `Password wajib diisi` | ✅ Sesuai (widget test) |
| 5 | Daftar dengan email terpakai | Email yang sudah terdaftar | `Email sudah terdaftar. Silakan masuk.` | ⏳ isi setelah uji di Chrome |
| 6 | Daftar akun simulasi baru | `pembeli@caca.test` / `123456` | Akun muncul di Authentication > Users | ⏳ isi setelah uji di Chrome |
| 7 | Refresh browser | Tekan F5 saat sudah masuk | Tetap di Halaman Utama (sesi tersimpan) | ⏳ isi setelah uji di Chrome |
| 8 | Keluar | Tombol **Keluar** di app bar | Kembali ke Halaman Masuk | ⏳ isi setelah uji di Chrome |
| 9 | Password terlalu pendek | `123` | `Password minimal 6 karakter` | ✅ Sesuai (unit + widget test) |
| 10 | Ulangi password berbeda (mode Daftar) | `123456` vs `654321` | `Password tidak sama` | ✅ Sesuai (widget test) |
| 11 | Kode `operation-not-allowed` | Penyedia sengaja dinonaktifkan | `Login email/password belum diaktifkan di Firebase Console` | ✅ Sesuai (unit test pemetaan) |
| 12 | Kode error tak dikenal | `kode-asing` | `Terjadi kesalahan. Silakan coba lagi.` (bukan pesan teknis) | ✅ Sesuai (unit test) |

**Catatan keamanan:** `invalid-credential`, `wrong-password`, dan `user-not-found`
sengaja menghasilkan pesan yang sama. Project Firebase baru mengaktifkan
perlindungan enumerasi email, sehingga orang lain tidak dapat menebak alamat
email mana yang terdaftar.

**Kolom password** memakai `obscureText: true`; **tombol** dinonaktifkan dan
menampilkan `CircularProgressIndicator` selama `_sedangProses == true` agar
permintaan tidak terkirim dua kali.

---

## 4. Daftar periksa latihan

| Latihan | Butir | Status |
|---|---|---|
| 1 | Project dibuat, paket Spark, Email/Password aktif | ⏳ |
| 1 | `lib/firebase_options.dart` tersedia | ✅ |
| 1 | `flutter run -d chrome` tanpa error setelah inisialisasi | ⏳ |
| 2 | Satu halaman dengan mode Masuk dan Daftar | ✅ |
| 2 | Email/password tervalidasi; password disembunyikan | ✅ |
| 2 | Tombol nonaktif saat proses berjalan | ✅ |
| 2 | Akun simulasi muncul di Authentication > Users | ⏳ |
| 3 | Belum login → Halaman Masuk; sesudah masuk → Halaman Utama | ✅ / ⏳ |
| 3 | Sesi bertahan setelah refresh | ⏳ |
| 3 | Tombol Keluar mengembalikan ke Halaman Masuk | ⏳ |
| 4 | ≥ 5 kasus uji ditulis dan dicatat | ✅ struktur / ⏳ hasil nyata |

---

## 5. Bukti screenshot Firebase Console

Ambil di **Firebase Console → Authentication → Users** setelah mendaftarkan
minimal satu akun simulasi. Simpan dengan nama:

```
screenshots/11-firebase-users.png
```

![Daftar pengguna Firebase Console](../screenshots/11-firebase-users.png)

> ⏳ Berkas ini **belum ada** dan sengaja tidak dibuat-reka: screenshot hanya
> dapat diambil dari project Firebase milik mahasiswa. Setelah disimpan, gambar
> di atas akan tampil otomatis dan tautan ini bisa disertakan dalam pengumpulan.

---

## 6. Riwayat commit Minggu 9

| # | Pesan commit | Isi |
|---|---|---|
| 1 | `feat(firebase): hubungkan project ke Firebase (core, auth, firebase_options)` | `pubspec.yaml`, `firebase_options.dart`, `validasi_auth.dart`, template config, `.gitignore`, unit test |
| 2 | `feat(auth): tambah halaman masuk dan daftar dengan validasi form` | `masuk_page.dart` + widget test |
| 3 | `feat(auth): tambah cek status login dan tombol keluar` | `cek_status_login.dart`, `halaman_utama.dart`, `firebase_login_app.dart`, `main.dart`, `main_uts.dart` |
| 4 | `docs: panduan, laporan praktikum, dan README Minggu 9` | Dokumen ini, panduan, pembaruan README |
| 5 | `fix(auth): perbaikan temuan uji — tombol tidak aktif lagi setelah login sukses` | Perbaikan satu temuan uji |

Modul meminta **minimal 2 commit baru ter-push**; tersedia 5 commit bertahap.

### Temuan uji dan perbaikan (refleksi uji teman)

- **Temuan (uji mandiri):** setelah login berhasil, blok `finally` sempat
  menjalankan `setState(() => _sedangProses = false)` sebelum `CekStatusLogin`
  mengganti halaman, sehingga tombol **Masuk** aktif kembali satu frame
  (kedip sesaat, berisiko diketik dua kali oleh pengguna cepat).
- **Perbaikan (commit 5):** penurunan `_sedangProses` dipindah ke dalam blok
  `catch` saja, tetap dijaga `if (mounted)`, persis seperti pola modul. Saat
  berhasil, `CekStatusLogin` langsung mencopot halaman tanpa menyalakan tombol
  lagi.
- **Temuan lanjutan untuk uji teman:** ⏳ minta teman mencoba kolom kosong,
  email salah format, dan password salah; nilai kejelasan pesan dan pastikan
  pesan tidak membocorkan email yang terdaftar. Catat temuan tambahan di sini,
  lalu commit dan push.

---

## 7. Refleksi individu

**1. Halaman mana yang boleh dibuka tanpa login? Mengapa?**

Hanya `MasukPage` (satu halaman untuk mode Masuk **dan** Daftar). Semua halaman
lain — `HalamanUtama`, dan pada prototipe UTS juga beranda, katalog, keranjang,
checkout, riwayat pesanan, serta dashboard admin — wajib terlindungi. Alasannya
membedakan autentikasi dan otorisasi: halaman login dipakai untuk membuktikan
identitas, sedangkan halaman setelahnya berisi data yang harus dikaitkan dengan
`uid` pengguna. Membiarkannya terbuka berarti data pesanan tidak punya pemilik
dan peran admin tidak bisa dibatasi.

**2. Kendala apa yang muncul saat setup Firebase dan bagaimana mengatasinya?**

- Nilai `firebaseConfig` hanya tersedia setelah project dibuat di Console dengan
  akun Google pemilik; tidak bisa ditebak atau digenerate lokal. Solusinya:
  konfigurasi dibaca dari `--dart-define-from-file=firebase-config.json` dengan
  template `firebase-config.example.json`, sehingga kode tetap lengkap dan nilai
  project tidak tertulis di Git.
- 26 test UTS lama membangun widget tanpa Firebase. Sesuai catatan modul
  *"Widget test gagal karena Firebase"*, `main.dart` dibuat **dua mode**: tanpa
  konfigurasi tetap menjalankan prototipe mock, dan test baru hanya menguji
  validator/form murni. Hasilnya `flutter test` tetap hijau (**50 test**).
- Demo GitHub Pages seharusnya tetap menampilkan prototipe UTS, bukan halaman
  login Firebase. Dibuat entry point terpisah `lib/main_uts.dart` yang tidak
  memanggil `Firebase.initializeApp()`, sehingga SDK JS Firebase tidak pernah
  dimuat pada demo tersebut.
- `firebase_core_web` ternyata menyuntikkan JS SDK dari `gstatic.com` sendiri,
  jadi `web/index.html` tidak perlu dimodifikasi; yang perlu dijaga hanyalah
  koneksi internet Chrome saat uji.
- Di Windows muncul peringatan *"Building with plugins requires symlink
  support / Developer Mode"*. Peringatan ini terkait plugin desktop dan tidak
  menghalangi target wajib Chrome.

**3. Data apa yang harus tersimpan permanen di Firestore pada Minggu 10?**

Mengikuti rancangan pada proposal UTS dan `docs/firestore-schema.png`:

| Collection | Isi |
|---|---|
| `users` | Profil pembeli/admin, `role`, nomor telepon, alamat (dikunci oleh `uid`) |
| `iphones` | 20 model iPhone beserta seri, ukuran, tipe cutout kamera |
| `cases` | Katalog case, harga, stok, kategori, daftar `compatibleModelIds` |
| `carts` / `items` | Keranjang per pengguna |
| `orders` / `items` | Pesanan, status, total, alamat kirim, riwayat |

Saat ini yang permanen **hanya sesi autentikasi**. Katalog, keranjang, dan
pesanan masih tersimpan di memori sehingga hilang saat aplikasi dijalankan
ulang — itulah yang akan diperbaiki Minggu 10 dengan aturan keamanan Firestore
berbasis `request.auth.uid`.

---

## 8. Cara mengulang verifikasi

```bash
flutter analyze                    # No issues found
flutter test                       # All tests passed! (+50)
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

Panduan lengkap (setup Console, tiga jalur koneksi, troubleshooting, dan build
GitHub Pages) ada di [`docs/PANDUAN_FIREBASE_MINGGU_09.md`](PANDUAN_FIREBASE_MINGGU_09.md).
