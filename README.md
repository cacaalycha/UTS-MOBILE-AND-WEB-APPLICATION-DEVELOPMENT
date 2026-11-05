# UTS-MOBILE-AND-WEB-APPLICATION-DEVELOPMENT

# CASE IPHONE CACA

**Aplikasi Katalog dan Pemilihan Case iPhone Berdasarkan Model iPhone**

## 1. Identitas Project

| Keterangan | Informasi |
|---|---|
| Nama Project | Case iPhone Caca |
| Nama Mahasiswa | Alysha Syafiya Maisaroh |
| NIM | 23.01.55.0001 |
| Kelas | Pagi A1 |
| Mata Kuliah | Web and Mobile Application Development |
| Framework | Flutter |
| Bahasa Pemrograman | Dart |

## 2. Deskripsi Project

Case iPhone Caca merupakan aplikasi katalog penjualan case iPhone berbasis Flutter yang dirancang untuk membantu pengguna menemukan dan memilih case sesuai dengan model iPhone yang dimiliki.

Aplikasi ini menyediakan katalog produk, detail produk, fitur pengecekan kompatibilitas case berdasarkan model iPhone, keranjang belanja, proses checkout, serta informasi pesanan. Selain itu, tersedia halaman admin untuk membantu pengelolaan data produk.

Project ini dikembangkan sebagai aplikasi mobile dengan tampilan yang sederhana dan mudah digunakan. Pada versi saat ini, data aplikasi masih menggunakan mock data melalui repository sehingga integrasi Firebase Firestore direncanakan sebagai pengembangan selanjutnya.

## 3. Fitur Aplikasi

### A. Fitur Customer
- **Beranda:** Menampilkan halaman utama dan informasi produk.
- **Katalog Produk:** Menampilkan daftar case iPhone yang tersedia.
- **Detail Produk:** Menampilkan informasi dan detail case.
- **Compatibility Checker:** Membantu pengguna memilih case berdasarkan model iPhone yang dimiliki.
- **Keranjang Belanja:** Menyimpan produk yang akan dibeli.
- **Checkout:** Memproses pesanan dan informasi pembelian.
- **Konfirmasi Pesanan:** Menampilkan konfirmasi setelah proses checkout.
- **Pesanan Saya:** Menampilkan daftar dan detail pesanan.
- **Login dan Register:** Menyediakan fitur autentikasi pengguna pada tampilan aplikasi.

### B. Fitur Admin
- **Dashboard Admin:** Menampilkan halaman utama admin.
- **Manajemen Produk:** Menampilkan data produk.
- **Tambah Produk:** Menambahkan produk baru.
- **Edit Produk:** Mengubah informasi produk.
- **Hapus Produk:** Menghapus produk dari katalog.

## 4. Desain UI/UX dan Prototype Figma

Desain antarmuka aplikasi dibuat menggunakan Figma sebagai acuan dalam proses pengembangan aplikasi.

- **Figma Design / Wireframe:**  
  https://www.figma.com/design/TPBZUe0azGKFVuAyHcQ0nq/-23.01.55.0001--%E2%80%93--Case-iPhone-Caca--%E2%80%93-Wireframe?node-id=1-2&t=lGxr09H65HQXbOiX-1

- **Figma Prototype:**  
  https://www.figma.com/proto/TPBZUe0azGKFVuAyHcQ0nq/-23.01.55.0001--%E2%80%93--Case-iPhone-Caca--%E2%80%93-Wireframe?node-id=7-22&p=f&t=3IUcGORs9VA7dQZJ-1&scaling=scale-down&content-scaling=fixed&page-id=1%3A3&starting-point-node-id=7%3A22

## 5. Teknologi yang Digunakan

| Teknologi | Kegunaan |
|---|---|
| Flutter | Framework pengembangan aplikasi |
| Dart | Bahasa pemrograman |
| Provider | State management |
| GoRouter | Pengaturan navigasi halaman |
| Google Fonts | Pengaturan jenis huruf |
| Intl | Format angka dan informasi lainnya |
| Cupertino Icons | Ikon antarmuka aplikasi |
| Figma | Perancangan UI/UX dan prototype |
| GitHub | Penyimpanan dan pengelolaan source code |

**Catatan:** Versi saat ini menggunakan mock data dan mock repository. Firebase Firestore belum diintegrasikan ke dalam aplikasi.

## 6. Struktur Folder Project

```text
caseipcaca/
├── android/
├── ios/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   ├── theme/
│   │   └── utils/
│   ├── data/
│   │   ├── mock/
│   │   └── repositories/
│   ├── models/
│   ├── pages/
│   │   ├── admin/
│   │   ├── auth/
│   │   ├── cart/
│   │   ├── catalog/
│   │   ├── home/
│   │   ├── model/
│   │   └── order/
│   ├── providers/
│   ├── router/
│   ├── widgets/
│   ├── app.dart
│   └── main.dart
├── test/
├── web/
├── pubspec.yaml
└── README.md
```

## 7. Cara Menjalankan Project

### Persyaratan
Sebelum menjalankan aplikasi, pastikan perangkat sudah memiliki:
- Flutter SDK
- Dart SDK
- Visual Studio Code atau Android Studio
- Emulator Android atau perangkat Android

### Langkah 1: Buka Folder Project

Buka folder project Case iPhone Caca yang tersimpan di:

```text
D:\dev\caseipcaca
```

Folder tersebut dapat dibuka melalui Visual Studio Code dengan memilih **File → Open Folder**, kemudian pilih folder `caseipcaca`.

### Langkah 2: Buka Terminal

Setelah folder project terbuka, buka terminal pada Visual Studio Code melalui menu **Terminal → New Terminal**.

### Langkah 3: Install Dependencies

Jalankan perintah berikut untuk mengunduh seluruh dependencies yang dibutuhkan:

```bash
flutter pub get
```

### Langkah 4: Periksa Konfigurasi Flutter

Jalankan perintah berikut untuk memastikan Flutter sudah terkonfigurasi dengan baik:

```bash
flutter doctor
```

### Langkah 5: Jalankan Aplikasi

Pastikan emulator atau perangkat yang digunakan sudah terhubung, kemudian jalankan:

```bash
flutter run
```

Aplikasi Case iPhone Caca akan dijalankan pada perangkat atau emulator yang telah dipilih.

### Alternatif: Menjalankan Aplikasi melalui Browser

Jika ingin menjalankan aplikasi melalui browser, gunakan perintah:

```bash
flutter run -d chrome
```

Pastikan dukungan Flutter Web sudah tersedia pada instalasi Flutter yang digunakan.

## 8. Screenshot Aplikasi

Berikut merupakan dokumentasi tampilan aplikasi Case iPhone Caca.

### A. Halaman Beranda
![Halaman Beranda](screenshots/beranda.png)

### B. Halaman Katalog
![Halaman Katalog](screenshots/katalog.png)

### C. Halaman Detail Produk
![Halaman Detail Produk](screenshots/detail-produk.png)

### D. Halaman Pilih Model iPhone
![Halaman Pilih Model iPhone](screenshots/pilih-model.png)

### E. Halaman Keranjang
![Halaman Keranjang](screenshots/keranjang.png)

### F. Halaman Checkout
![Halaman Checkout](screenshots/checkout.png)

### G. Halaman Admin
![Halaman Admin](screenshots/admin-dashboard.png)

*Catatan: Screenshot di atas merupakan tempat untuk menampilkan dokumentasi aplikasi. Masukkan gambar hasil screenshot aplikasi ke dalam folder `screenshots` di repository dengan nama file yang sesuai.*

## 9. Video Demo Aplikasi

Video demonstrasi aplikasi Case iPhone Caca dapat dilihat melalui tautan berikut:

https://youtu.be/eZ7dYPxLWVA

---

**Case iPhone Caca**  
Developed by **Alysha Syafiya Maisaroh**  
NIM: 23.01.55.0001  
