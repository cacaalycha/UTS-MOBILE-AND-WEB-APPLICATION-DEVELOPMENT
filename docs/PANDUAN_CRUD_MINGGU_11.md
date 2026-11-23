# Panduan Praktikum Minggu 11 — CRUD Lengkap: Edit, Hapus, dan Dialog Konfirmasi

**Case iPhone Caca** · Alysha Syafiya Maisaroh · 23.01.55.0001 · Kelas Pagi A1
Mobile and Web Application Development — Ganjil 2026/2027

Batas pertemuan: target **Chrome**, paket **Spark** tanpa billing, operasi
**Update** dan **Delete** hanya untuk **pemilik** yang masih berstatus
**Menunggu**. **Tidak** dibahas: peran admin persetujuan, soft delete/restore,
pencarian, filter, atau upload berkas. Video panduan dosen:
https://www.youtube.com/watch?v=wliYRh2qDGY

Project Firebase: `case-iphone-caca` · Repository: https://github.com/cacaalycha/UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT

---

## 1. Peta CRUD ↔ HTTP ↔ Firestore

| Operasi | HTTP (RESTful) | Firestore | Ciri khas di Case iPhone Caca |
|---|---|---|---|
| Create | `POST /orders` | `add()` / `set()` |_doc auto-ID_ + `FieldValue.serverTimestamp()` |
| Read | `GET /orders` | `get()` / `.snapshots()` | `StreamBuilder`, filter `id_pengguna == uid` |
| Update | `PUT/PATCH /orders/{id}` | `doc(id).update()` | Hanya field yang berubah + `diubah_pada` |
| Delete | `DELETE /orders/{id}` | `doc(id).delete()` | Setelah dialog konfirmasi, permanen |

### `set()` vs `update()`

`set()` menulis dokumen secara utuh — field yang **tidak disebut ikut hilang**.
`update()` hanya menambal field yang disebut. Karena itu semua edit memakai
`update()`. Field audit yang **tidak boleh berubah**:

- `dibuat_pada` — waktu pesanan pertama kali dibuat.
- `id_pengguna` — pemilik dokumen (dipakai Rules untuk otorisasi).
- `status` — tetap `Menunggu` setelah diubah; keputusan ada pada pengelola.

```dart
// SALAH untuk edit: dibuat_pada & id_pengguna bisa hilang
await docRef.set({'tanggal': tanggal, 'jam': jam});

// BENAR
await docRef.update({
  'tanggal': tanggal,
  'jam': jam,
  'diubah_pada': FieldValue.serverTimestamp(),
});
```

---

## 2. Aturan bisnis (ditulis dua kali, tujuan berbeda)

| Aturan | Wujud di kode | Wujud di Security Rules |
|---|---|---|
| Hanya pemilik | `pastikanBolehDiubah(): data['id_pengguna'] == uid` | `resource.data.id_pengguna == request.auth.uid` |
| Hanya status Menunggu | `enabled: pesanan.bisaDiubah` pada menu | `resource.data.status == 'Menunggu'` |
| Hapus wajib konfirmasi | `await showDialog<bool>()` sebelum `delete()` | tidak bisa dicek server — tanggung jawab UI |
| Ubah tidak boleh bentrok | `adaBentrokPesanan(abaikanId: id)` | tidak bisa — butuh query lintas dokumen |
| Field audit utuh | `update()` hanya field yang berubah | `id_pengguna` tidak boleh berubah |

Fungsi `pastikanBolehDiubah()` dan `adaBentrokPesanan()` ada **sekali** di
`lib/data/data_simulasi.dart`, lalu dipakai ulang oleh `LayananFirestore`
(produksi) **dan** `LayananMemori` (widget test). Ini sesuai anjuran modul:
aturan bisnis terpusat, bukan disalin di banyak tempat.

### Jebakan yang sering terjadi

Saat mengubah **jumlah** pada case + tanggal + jam yang sama, dokumen itu
sendiri tetap terdaftar pada jadwal tersebut. Kalau tidak dikecualikan,
aplikasi menolak perubahan yang sah. Karena itu metode ubah mengirim
`abaikanId: idPesanan` ke pengecekan bentrok.

---

## 3. Memperketat Security Rules di Firebase Console

1. Buka https://console.firebase.google.com → project **case-iphone-caca**.
2. **Build / Databases & Storage → Firestore Database → tab Rules**.
3. Ganti seluruh isi dengan aturan di [`firestore.rules`](../firestore.rules):

```javascript
rules_version = '2';

service cloud.firestore {
  match /databases/{database}/documents {
    function sudahMasuk() {
      return request.auth != null;
    }
    function pemilik(data) {
      return sudahMasuk() && data.id_pengguna == request.auth.uid;
    }
    match /users/{uid} {
      allow read, write: if sudahMasuk() && request.auth.uid == uid;
    }
    match /cases/{idCase} {
      allow read: if sudahMasuk();
      allow write: if sudahMasuk();
    }
    match /orders/{idPesanan} {
      allow create: if pemilik(request.resource.data)
                    && request.resource.data.status == 'Menunggu';
      allow read: if sudahMasuk();
      allow update, delete: if pemilik(resource.data)
                            && resource.data.status == 'Menunggu';
    }
  }
}
```

4. Klik **Publish** — perubahan belum berlaku sebelum tombol ini ditekan.

Perbedaan dengan Minggu 10: dulu semua yang login boleh menulis ke semua
dokumen. Sekarang tulisan dibatasi pada dokumen sendiri dan status Menunggu.
Efeknya, pelanggaran muncul sebagai `permission-denied` dari server, bukan
sekadar pesan di aplikasi.

---

## 4. Berkas yang berubah

| Berkas | Peran Minggu 11 |
|---|---|
| `firestore.rules` | Rules kepemilikan + status Menunggu |
| `lib/data/data_simulasi.dart` | `OperasiDitolakException`, `bisaDiubah`, `diubahPada`, `pastikanBolehDiubah()`, `adaBentrokPesanan()` |
| `lib/services/layanan_data.dart` | Kontrak `ubahPesanan()` & `hapusPesanan()` |
| `lib/services/layanan_firestore.dart` | `update()`, `delete()`, cek pemilik, cek bentrok dengan `abaikanId` |
| `lib/services/layanan_memori.dart` | Versi in-memory untuk widget test |
| `lib/pages/minggu10/form_pesanan_page.dart` | `pesananAwal` → mode ubah, tombol "Simpan Perubahan" |
| `lib/pages/minggu10/pesanan_saya_page.dart` | Menu Ubah/Hapus (`enabled: bisaDiubah`), dialog konfirmasi, SnackBar |
| `lib/router/app_router.dart` | `/firestore/form` menerima `extra: PesananFirestore` |
| `test/minggu11_*.dart` | Unit test aturan & layanan, widget test UI |

### Alur singkat

```
Pesanan Saya (StreamBuilder)
 ├─ Ubah → /firestore/form (extra: pesanan)
 │         → isian terisi data lama → ubahPesanan()
 │         → pastikanBolehDiubah() → cek bentrok (abaikan diri) → update()
 └─ Hapus → showDialog<bool> → Batal = tidak ada aksi
                             → Setujui → hapusPesanan() → delete()
```

---

## 5. Daftar periksa Latihan 1–3

### Latihan 1 — aturan bisnis & Rules

- [ ] Rules kepemilikan sudah **Publish** di Console.
- [ ] `pastikanBolehDiubah()` tersedia di lapisan layanan.
- [ ] Model `PesananFirestore` punya `bisaDiubah` (status Menunggu).
- [ ] Commit: *"Perketat Security Rules dan aturan bisnis ubah/hapus"*.

### Latihan 2 — ubah data

- [ ] Menu **Ubah** membuka form dengan data lama terisi.
- [ ] Tombol berubah menjadi **Simpan Perubahan**.
- [ ] Perubahan tersimpan; `dibuat_pada` dan `id_pengguna` tidak berubah.
- [ ] `diubah_pada` terisi setelah perubahan pertama.
- [ ] Mengubah jam yang sama dengan dirinya sendiri tidak ditolak.
- [ ] Penolakan muncul saat bukan pemilik / status bukan Menunggu.
- [ ] Commit: *"Tambah fitur ubah pesanan dengan validasi dan cek bentrok"*.

### Latihan 3 — hapus data

- [ ] Dialog konfirmasi menyebut nama case, tanggal, dan jam.
- [ ] Menekan **Batal** tidak mengubah data.
- [ ] Menekan **Hapus** menghilangkan dokumen dari Console.
- [ ] SnackBar berhasil/gagal muncul setelah aksi selesai.
- [ ] Commit: *"Tambah fitur hapus dengan dialog konfirmasi dan pesan status"*.

---

## 6. Tabel uji CRUD (8 kasus)

| # | Kasus uji | Langkah | Hasil yang diharapkan |
|---|---|---|---|
| 1 | Ubah data valid | Ubah jumlah/tanggal/jam dari menu Ubah | Dokumen berubah; `dibuat_pada` & `id_pengguna` tetap; `diubah_pada` terisi |
| 2 | Ubah jadi bentrok | Ubah jam ke jadwal pesanan lain | Ditolak dengan pesan jadwal; data lama utuh |
| 3 | Ubah jam sendiri | Ubah jumlah tanpa mengganti jadwal | Berhasil — dokumen sendiri tidak dihitung bentrok |
| 4 | Ubah status terkunci | Ubah pesanan berstatus Dibatalkan | Menu nonaktif; bila dipaksa, `permission-denied` |
| 5 | Hapus dengan konfirmasi | Pilih Hapus lalu setujui dialog | Dokumen hilang; SnackBar berhasil |
| 6 | Hapus dibatalkan | Pilih Hapus lalu tekan Batal | Dialog tertutup; data tetap ada |
| 7 | Hapus milik akun lain | Masuk akun kedua, hapus data akun pertama | Ditolak (`permission-denied` / pesan bukan pemilik) |
| 8 | Rules lama masih aktif | Biarkan Rules Minggu 10 belum di-Publish | Akun lain masih bisa menulis → aturan keamanan belum berjalan; publish ulang |

Kolom **Hasil nyata** diisi setelah uji Chrome dan Console; lihat
[`LAPORAN_MINGGU_11.md`](LAPORAN_MINGGU_11.md).

---

## 7. Masalah umum

| Gejala | Penyebab | Solusi |
|---|---|---|
| `permission-denied` saat hapus/ubah | Rules lama belum diganti atau belum Publish | Pasang Rules kepemilikan, klik **Publish** |
| `dibuat_pada` hilang setelah edit | Memakai `set()` tanpa `merge` | Ganti dengan `update()` |
| Ubah selalu ditolak "sudah dipesan" | Dokumen sendiri ikut dihitung bentrok | Kirim `abaikanId` pada pengecekan |
| Menu tetap aktif saat Dibatalkan | Properti `bisaDiubah` belum dipakai | `enabled: pesanan.bisaDiubah` |
| Dialog tidak muncul / hasil diabaikan | `showDialog` tanpa `await` | `await showDialog<bool>()` + cek hasilnya |
| Data lama masih tampil | Halaman tidak membaca stream | Baca ulang lewat `StreamBuilder` |

---

## 8. Cara menjalankan & memverifikasi

```bash
cd D:/dev/caseipcaca
flutter analyze
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
  NO_PROXY=localhost,127.0.0.1 flutter test
MSYS_NO_PATHCONV=1 flutter build web --release \
  --dart-define-from-file=firebase-config.json
flutter run -d chrome --dart-define-from-file=firebase-config.json
```

> Perhatian: setelah Rules diperketat, **akun admin** di
> `FIREBASE_ADMIN_EMAILS` tetap tunduk pada aturan kepemilikan — admin hanya
> mengubah/menghapus pesanan miliknya sendiri. Sementara itu halaman admin
> kelola produk masih memakai data mock; menyambungkannya ke `cases`
> membutuhkan Update/Delete pada master data (rencana Minggu 12).

---

## 9. Persiapan Minggu 12

Rangkai seluruh CRUD menjadi satu alur bisnis inti: pilih case → isi form →
simpan → lihat riwayat → ubah/batalkan. Pastikan konsisten di mobile dan web,
rapikan umpan balik setiap langkah, lalu uji dari awal sampai akhir.
