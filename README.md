# Lumina Restore

Lumina Restore adalah aplikasi Flutter berbasis kecerdasan buatan (AI) yang berfungsi untuk melakukan pemrosesan restorasi gambar (memperjelas gambar blur dan mencerahkan gambar gelap) secara lokal di dalam perangkat (*on-device*).

Aplikasi ini mendemonstrasikan implementasi *Machine Learning* di lingkungan seluler (Mobile) menggunakan ONNX Runtime tanpa memerlukan koneksi internet untuk pemrosesan citra.

## Fitur Utama

*   **Peningkatan Cahaya (Low-Light Enhancement):** Memperbaiki pencahayaan pada foto yang gelap menggunakan model Zero-DCE (79K parameter).
*   **Penghilangan Blur (Deblurring):** Memulihkan detail pada foto yang kabur akibat *motion blur* menggunakan model NAFNet (17M parameter).
*   **Pemrosesan Lokal (On-Device Inference):** Seluruh proses komputasi AI berjalan di memori perangkat. Gambar tidak diunggah ke server eksternal.
*   **Manajemen Memori Adaptif:** Menggunakan metode pemrosesan irisan (*tiled processing*) untuk memotong gambar menjadi kepingan 512x512 piksel guna mencegah insiden *Out Of Memory* (OOM) pada perangkat dengan RAM terbatas.
*   **Penyimpanan Riwayat Lokal:** Menggunakan basis data NoSQL (Hive) untuk menyimpan riwayat gambar yang telah direstorasi beserta metadata pemrosesannya.

## Teknologi yang Digunakan

*   **Framework UI:** Flutter
*   **Bahasa Pemrograman:** Dart
*   **Arsitektur Perangkat Lunak:** Clean Architecture
*   **State Management:** BLoC (Business Logic Component)
*   **Machine Learning Engine:** ONNX Runtime (`flutter_onnxruntime`)
*   **Database Lokal:** Hive NoSQL

## Struktur Proyek

Proyek ini disusun berdasarkan pola Clean Architecture dengan pemisahan lapisan logika sebagai berikut:

```text
lib/
├── core/           # Konfigurasi utama, utilitas (memory checker), dan setup Hive
├── features/       # Modul fitur fungsional (history, restore, settings)
│   └── [nama_fitur]/
│       ├── bloc/         # Manajemen status antarmuka (Presentation Layer)
│       ├── models/       # Struktur data (Domain Layer)
│       ├── repositories/ # Kontrak antarmuka data (Domain Layer)
│       ├── services/     # Implementasi API spesifik platform (Data Layer)
│       ├── ui/           # Halaman dan widget (Presentation Layer)
│       └── usecases/     # Logika bisnis (Domain Layer)
└── main.dart       # Titik inisialisasi aplikasi
```

## Persyaratan Sistem Pengembangan

Untuk menjalankan proyek ini, perangkat pengembangan Anda harus memiliki:
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (versi 3.11.5 atau lebih baru)
*   Android Studio atau VS Code dengan ekstensi Flutter terpasang
*   Perangkat fisik Android atau Emulator untuk pengujian komputasi gambar

## Panduan Instalasi dan Eksekusi

1. Salin (*clone*) repositori proyek ke mesin lokal Anda:
   ```bash
   git clone <tautan-repositori>
   cd vision-enchance-ml
   ```

2. Unduh seluruh dependensi pustaka yang dibutuhkan:
   ```bash
   flutter pub get
   ```

3. Hubungkan perangkat Anda dan jalankan aplikasi:
   ```bash
   flutter run
   ```

## Aset Model Machine Learning

Model kecerdasan buatan dalam aplikasi ini dikonversi ke format `.onnx` dan dikemas pada saat waktu kompilasi (*build-time*) di dalam folder `assets/models/`:
*   `zero_dce.onnx` (Model peningkatan cahaya)
*   `nafnet.onnx` (Model penghilangan blur)
