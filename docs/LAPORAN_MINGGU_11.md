# Laporan Praktikum Minggu 11 — CRUD Lengkap: Edit, Hapus, dan Dialog Konfirmasi

**Judul aplikasi:** Case iPhone Caca

| Identitas | Isian |
|---|---|
| Nama / NIM | Alysha Syafiya Maisaroh / 23.01.55.0001 |
| Kelas dan judul aplikasi | Pagi A1 — Case iPhone Caca |
| Tautan repository GitHub | https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT |
| Nama project Firebase | `case-iphone-caca` |
| Paket / target | Spark (tanpa billing) / Chrome |
| Video panduan | https://www.youtube.com/watch?v=wliYRh2qDGY |

> **Status pengisian:** ✅ = sudah diverifikasi otomatis (`flutter analyze`,
> `flutter test`, kode & Rules lokal) · ⏳ = perlu dibuktikan di Chrome dan
> Firebase Console. Rules lokal sudah disiapkan, tetapi **wajib di-Publish di
> Console** oleh pemilik project sebelum penolakan `permission-denied` bisa
> diuji.

---

## 1. Tujuan dan pemetaan operasi

Melengkapi siklus CRUD: setelah Minggu 10 data tersimpan permanen, Minggu 11
menambah **Update** dan **Delete** yang aman — hanya pemilik, hanya saat status
masih **Menunggu**, dan penghapusan wajib lewat dialog konfirmasi.

| Operasi | HTTP | Firestore | Penerapan |
|---|---|---|---|
| Create | `POST /orders` | `add()` / `set()` | Form Pesanan (Minggu 10) |
| Read | `GET /orders` | `get()` / `.snapshots()` | `StreamBuilder` real-time |
| Update | `PUT/PATCH /orders/{id}` | `doc(id).update()` | Menu Ubah → form mode ubah |
| Delete | `DELETE /orders/{id}` | `doc(id).delete()` | Menu Hapus → dialog konfirmasi |

**`update()` dipilih, bukan `set()`**, karena `set()` tanpa `merge` menghilangkan
field yang tidak disebut. Field audit `dibuat_pada`, `id_pengguna`, dan `status`
harus tetap utuh; `diubah_pada` ditambahkan oleh `FieldValue.serverTimestamp()`.

---

## 2. Luaran pertemuan

| Butir | Status | Bukti |
|---|---|---|
| Rules kepemilikan `users`/`cases`/`orders` disiapkan | ✅ | `firestore.rules` |
| Rules sudah **di-Publish** di Console | ⏳ | Wajib dilakukan di Firebase Console |
| Menu Ubah & Hapus aktif hanya untuk status Menunggu | ✅ | `bisaDiubah` + `enabled:` pada popup menu |
| Form mode ubah terisi data lama | ✅ | Widget test |
| `dibuat_pada` & `id_pengguna` tidak berubah saat edit | ✅ | Unit + widget test |
| `diubah_pada` terisi setelah edit | ✅ | Unit test |
| Cek bentrok mengecualikan dokumen sendiri | ✅ | `abaikanId` — unit test |
| Dialog konfirmasi; Batal tidak mengubah data | ✅ | Widget test |
| SnackBar berhasil/gagal | ✅ | Widget test |
| `flutter analyze` bersih & semua test lulus | ✅ | Lihat bagian 7 |
| Tabel uji CRUD ≥ 6 kasus | ✅ struktur / ⏳ hasil nyata | 8 kasus di bawah |
| Screenshot Rules & Console | ⏳ | `screenshots/16..18-*.png` |
| ≥ 2 commit baru ter-push | ✅ | 3 commit bertahap (bagian 6) |

---

## 3. Tabel uji CRUD (8 kasus)

Hasil yang diharapkan ditulis sebelum menguji. Kasus berstatus ✅ dibuktikan
lewat test otomatis dengan `LayananMemori()` (tanpa Firebase), sesuai catatan
modul *"Widget test gagal karena Firebase"*.

| # | Kasus uji | Langkah | Hasil yang diharapkan | Hasil nyata |
|---|---|---|---|---|
| 1 | Ubah data valid | Ubah jumlah/tanggal/jam lewat menu Ubah | Dokumen berubah; `dibuat_pada` & `id_pengguna` tetap; `diubah_pada` terisi | ✅ otomatis / ⏳ Console |
| 2 | Ubah jadi bentrok | Pindahkan jam ke jadwal pesanan lain | Ditolak dengan pesan jadwal; data lama utuh | ✅ otomatis / ⏳ Chrome |
| 3 | Ubah jam sendiri | Ubah jumlah tanpa mengganti jadwal | Berhasil — dokumen sendiri tidak dihitung bentrok | ✅ otomatis / ⏳ Chrome |
| 4 | Ubah status terkunci | Coba ubah/hapus pesanan berstatus Dibatalkan | Menu nonaktif; bila dipaksa → `permission-denied` | ✅ UI otomatis / ⏳ Rules |
| 5 | Hapus dengan konfirmasi | Pilih Hapus, lalu setujui dialog | Dokumen hilang; SnackBar "Pesanan berhasil dihapus." | ✅ otomatis / ⏳ Console |
| 6 | Hapus dibatalkan | Pilih Hapus, lalu tekan **Batal** | Dialog tertutup; data tetap ada | ✅ otomatis / ⏳ Chrome |
| 7 | Hapus milik akun lain | Masuk akun kedua, hapus data akun pertama | Ditolak (`permission-denied` / pesan bukan pemilik) | ✅ pesan kode / ⏳ Rules |
| 8 | Rules lama belum di-Publish | Biarkan Rules Minggu 10 aktif, coba hapus data orang lain | Akun lain masih bisa menulis → aturan belum berlaku; Publish ulang | ⏳ uji di Console |

Kolom **Hasil nyata** wajib diisi setelah praktikum di Chrome dan Console.

---

## 4. Daftar periksa Latihan 1–3

| Latihan | Butir | Status |
|---|---|---|
| 1 | Rules kepemilikan tersedia & dipublish | ✅ file / ⏳ publish |
| 1 | `pastikanBolehDiubah()` di lapisan layanan | ✅ |
| 1 | Model punya `bisaDiubah` | ✅ |
| 2 | Menu Ubah membuka form dengan data lama | ✅ |
| 2 | Tombol berubah jadi "Simpan Perubahan" | ✅ |
| 2 | `dibuat_pada` & `id_pengguna` utuh; `diubah_pada` terisi | ✅ |
| 2 | Penolakan bukan pemilik / status terkunci | ✅ |
| 3 | Dialog menyebut nama case, tanggal, jam | ✅ |
| 3 | Batal tidak mengubah data | ✅ |
| 3 | Hapus menghilangkan dokumen & SnackBar tampil | ✅ |
| 3 | Rules kepemilikan terpublish | ⏳ |

### Uji teman

| # | Skenario | Hasil |
|---|---|---|
| 1 | Teman mengubah tanggal & jam pesanan Anda, lalu memastikan `dibuat_pada` tidak berubah | ⏳ isi setelah uji |
| 2 | Teman mencoba menghapus pesanan berstatus Dibatalkan | ⏳ isi setelah uji |
| 3 | Teman masuk akun berbeda dan mencoba menghapus pesanan Anda | ⏳ isi setelah uji |
| 4 | Teman menekan **Batal** pada dialog dan memastikan data tetap ada | ⏳ isi setelah uji |

---

## 5. Bukti screenshot

Simpan di folder `screenshots/`:

| Berkas | Isi |
|---|---|
| `screenshots/16-firestore-rules-m11.png` | Tab Rules dengan aturan kepemilikan yang sudah dipublish |
| `screenshots/17-ubah-pesanan.png` | Form mode ubah dengan data lama & tombol Simpan Perubahan |
| `screenshots/18-dialog-hapus.png` | Dialog konfirmasi hapus |

> ⏳ Berkas belum ada dan sengaja tidak dibuat-reka — harus diambil dari
> project Firebase dan browser mahasiswa.

---

## 6. Riwayat commit Minggu 11

| # | Pesan commit | Isi |
|---|---|---|
| 1 | `feat(firestore): perketat rules kepemilikan dan aturan bisnis ubah/hapus` | `firestore.rules`, model (`OperasiDitolakException`, `bisaDiubah`, `diubah_pada`, fungsi bersama), unit test aturan |
| 2 | `feat(firestore): tambah ubah dan hapus pesanan dengan dialog konfirmasi` | `LayananData`, `LayananFirestore`, `LayananMemori`, form mode ubah, menu aksi & dialog, router, widget test |
| 3 | `docs: panduan, laporan, dan tabel uji CRUD Minggu 11` | Panduan, laporan ini, README, build verifikasi |

Modul meminta **minimal 2 commit baru ter-push**; tersedia 3 commit bertahap.

### Temuan dan perbaikan selama pengerjaan

- **Aturan bisnis tersebar.** Kode cek bentrok dan cek pemilik mula-mula
  mirip di dua implementasi. Keduanya sekarang memanggil satu fungsi bersama
  di `data_simulasi.dart`, persis seperti anjuran modul ("aturan bisnis
  ditulis sekali sebagai fungsi bersama").
- **Jebakan bentrok saat ubah.** Mengubah jumlah pada case+tanggal+jam yang
  sama sempat berisiko ditolak karena dokumen sendiri ikut terhitung.
  Ditambahkan `abaikanId` dan diuji khusus.
- **Widget test butuh router.** Form memanggil `context.go()` setelah sukses;
  test sukses dibungkus `GoRouter` kecil, sementara test penolakan tetap
  memakai `MaterialApp` biasa.
- **Rules belum otomatis terpublish.** Perubahan di `firestore.rules` hanya
  tersimpan di repository; pemilik project tetap harus membuka Console,
  menempelkan aturan, dan klik **Publish**.

---

## 7. Refleksi individu

**1. Mengapa `update()` lebih aman daripada `set()` untuk fitur ubah pada proyek Anda?**

`set()` menimpa seluruh dokumen: field yang tidak dicantumkan akan hilang.
Pada `orders`, itu berarti `dibuat_pada`, `id_pengguna`, dan `status` bisa
terhapus hanya karena form edit tidak mengirimnya. Akibatnya jejak waktu
pembuatan hilang dan Security Rules kehilangan data `id_pengguna` yang
dipakai untuk mengecek kepemilikan. `update()` hanya menambal field yang
disebut, sehingga field audit terjaga; `diubah_pada` justru ditambahkan
secara eksplisit dengan `FieldValue.serverTimestamp()`.

**2. Aturan bisnis apa yang Anda tambahkan pada proyek sendiri, dan mengapa?**

Dua aturan utama: **hanya pemilik** (`id_pengguna == uid`) dan **hanya status
Menunggu**. Keduanya ditulis di kode agar pesan galatnya jelas, dan di Rules
agar aman bila API dipanggil langsung. Saya juga mempertahankan aturan
Minggu 10 — cek bentrok `id_pengguna + id_case + tanggal + jam` — dengan
satu penyesuaian penting: saat ubah, dokumen yang sedang diedit dikecualikan.
Tanpa itu, mengubah jumlah pesanan pada jam yang sama akan salah ditolak.

**3. Bagian mana yang akan Anda rapikan sebelum alur bisnis inti dirakit Minggu 12?**

Yang pertama adalah menyambungkan **master `cases`** ke halaman admin
sehingga tambah/edit/hapus produk benar-benar menulis ke Firestore (saat ini
masih `MockProductRepository`). Kedua, merapikan umpan balik di setiap
langkah alur — pesan sukses/gagal yang konsisten, indikator proses, dan
keadaan kosong. Ketiga, memastikan alur "pilih case → isi form → simpan →
lihat riwayat → ubah/batalkan" berjalan mulus baik di layar mobile maupun web.

---

## 8. Cara mengulang verifikasi

```bash
cd D:/dev/caseipcaca
flutter analyze                    # No issues found!
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
  NO_PROXY=localhost,127.0.0.1 flutter test
MSYS_NO_PATHCONV=1 flutter build web --release \
  --dart-define-from-file=firebase-config.json
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

Panduan lengkap: [`docs/PANDUAN_CRUD_MINGGU_11.md`](PANDUAN_CRUD_MINGGU_11.md).
