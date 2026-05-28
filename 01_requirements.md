# 📋 Spesifikasi Kebutuhan Perangkat Lunak — Lumina Restore

> **Proyek:** Lumina Restore — AI Photo Restorer  
> **Versi:** 1.0.0 | **Tanggal:** 20 Mei 2026  
> **Platform:** Flutter (Android-first)  

---

## 1. Pendahuluan

### 1.1 Tujuan Dokumen

Dokumen ini mendefinisikan kebutuhan fungsional dan non-fungsional untuk aplikasi mobile **Lumina Restore**, aplikasi restorasi foto berbasis AI yang berjalan sepenuhnya secara *on-device* menggunakan ONNX Runtime.

### 1.2 Ruang Lingkup

Dua fitur utama:
1. **Peningkatan Cahaya Rendah** — Model Zero-DCE (FP16, ~174 KB)
2. **Penghilangan Blur** — Model NAFNet (FP16, ~83 MB)

Seluruh inferensi dilakukan lokal, menjamin privasi data pengguna.

### 1.3 Akronim

| Istilah | Definisi |
|---------|---------|
| ONNX | Open Neural Network Exchange |
| FP16 | Float Point 16-bit |
| OOM | Out of Memory |
| BLoC | Business Logic Component |

---

## 2. Kebutuhan Fungsional (FR)

### 2.1 Modul Beranda

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-HOME-01 | Menampilkan halaman beranda dengan dua kartu jenis restorasi | P0 |
| FR-HOME-02 | Menyediakan navigasi ke Riwayat, Album, dan Pengaturan | P0 |
| FR-HOME-03 | Menampilkan jumlah total restorasi yang telah dilakukan | P1 |

### 2.2 Modul Pemilihan Foto

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-UPLOAD-01 | Memilih foto dari galeri perangkat | P0 |
| FR-UPLOAD-02 | Mengambil foto langsung dari kamera | P0 |
| FR-UPLOAD-03 | Menampilkan pratinjau foto sebelum proses restorasi | P0 |
| FR-UPLOAD-04 | Memvalidasi format gambar (JPEG, PNG, WebP) | P0 |
| FR-UPLOAD-05 | Memvalidasi ukuran file (maks 20 MB) dan resolusi (maks 4096×4096) | P0 |

### 2.3 Modul Restorasi

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-RESTORE-01 | Menjalankan inferensi Zero-DCE FP16 untuk peningkatan cahaya rendah | P0 |
| FR-RESTORE-02 | Menjalankan inferensi NAFNet FP16 untuk penghilangan blur | P0 |
| FR-RESTORE-03 | Menampilkan animasi progres selama inferensi (pra-proses, inferensi, pasca-proses) | P0 |
| FR-RESTORE-04 | Membatalkan proses restorasi yang sedang berjalan | P1 |
| FR-RESTORE-05 | Menyesuaikan resolusi gambar secara otomatis (maks 512px, kelipatan 32) untuk performa | P0 |
| FR-RESTORE-06 | Menampilkan pesan kesalahan informatif jika inferensi gagal | P0 |

### 2.4 Modul Hasil

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-RESULT-01 | Menampilkan slider interaktif perbandingan sebelum/sesudah | P0 |
| FR-RESULT-02 | Mendukung zoom (pinch) dan pan pada foto hasil | P1 |
| FR-RESULT-03 | Menyimpan foto hasil ke galeri perangkat dengan kualitas penuh | P0 |
| FR-RESULT-04 | Membagikan foto hasil ke aplikasi lain via share sheet OS | P1 |
| FR-RESULT-05 | Menyimpan hasil ke album internal aplikasi | P1 |
| FR-RESULT-06 | Menampilkan metadata restorasi (model, waktu proses, resolusi) | P1 |

### 2.5 Modul Riwayat

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-HISTORY-01 | Menyimpan dan menampilkan seluruh restorasi, diurutkan terbaru | P1 |
| FR-HISTORY-02 | Menampilkan thumbnail, jenis restorasi, dan tanggal per item | P1 |
| FR-HISTORY-03 | Memfilter riwayat berdasarkan jenis restorasi | P2 |
| FR-HISTORY-04 | Menghapus item riwayat secara individual atau massal | P1 |
| FR-HISTORY-05 | Membuka kembali hasil restorasi dari riwayat | P1 |

### 2.6 Modul Album

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-ALBUM-01 | Membuat album baru dengan nama kustom | P1 |
| FR-ALBUM-02 | Menampilkan daftar album dengan gambar sampul dan jumlah item | P1 |
| FR-ALBUM-03 | Melihat seluruh foto restorasi dalam sebuah album | P1 |
| FR-ALBUM-04 | Menghapus album (foto restorasi tidak ikut terhapus) | P2 |
| FR-ALBUM-05 | Mengubah nama album yang sudah ada | P2 |

### 2.7 Modul Pengaturan

| ID | Kebutuhan | Prioritas |
|----|-----------|-----------|
| FR-SETTINGS-01 | Menampilkan informasi penggunaan penyimpanan | P1 |
| FR-SETTINGS-02 | Menghapus cache dan file sementara | P2 |
| FR-SETTINGS-03 | Menampilkan informasi detail model (nama, ukuran, versi) | P1 |
| FR-SETTINGS-04 | Menampilkan informasi versi aplikasi dan lisensi | P2 |

---

## 3. Kebutuhan Non-Fungsional (NFR)

### 3.1 Performa

| ID | Kebutuhan | Target |
|----|-----------|--------|
| NFR-PERF-01 | Waktu inferensi Low-Light (720p) | ≤ 10 detik |
| NFR-PERF-02 | Waktu inferensi Deblurring | ≤ 30 detik |
| NFR-PERF-03 | Waktu muat model | ≤ 3 detik |
| NFR-PERF-04 | Cold start aplikasi | ≤ 3 detik |
| NFR-PERF-05 | Frame rate UI idle / saat inferensi | ≥ 60 FPS / ≥ 30 FPS |
| NFR-PERF-06 | UI tidak freeze selama inferensi | Isolate-based processing |

### 3.2 Manajemen Memori

| ID | Kebutuhan | Target |
|----|-----------|--------|
| NFR-MEM-01 | Puncak RAM NAFNet | ≤ 500 MB |
| NFR-MEM-02 | Puncak RAM Zero-DCE | ≤ 100 MB |
| NFR-MEM-03 | Model dimuat di memori | Maksimal 1 model dalam satu waktu |
| NFR-MEM-04 | Pengecekan RAM sebelum inferensi | Wajib runtime check |
| NFR-MEM-05 | Resize gambar otomatis | Jika resolusi > 512px, resize ke kelipatan 32 terdekat dengan rasio yang sama |
| NFR-MEM-06 | Tidak boleh crash karena OOM | Dalam kondisi apapun |

### 3.3 Ukuran dan Distribusi

| ID | Kebutuhan | Target |
|----|-----------|--------|
| NFR-SIZE-01 | Ukuran APK tanpa model NAFNet | ≤ 30 MB |
| NFR-SIZE-02 | Ukuran total dengan model | ≤ 120 MB |

### 3.4 Kompatibilitas

| ID | Kebutuhan | Target |
|----|-----------|--------|
| NFR-COMPAT-01 | Android minimum | Android 8.0 (API 26) |
| NFR-COMPAT-02 | Arsitektur CPU | ARM64 (arm64-v8a) |
| NFR-COMPAT-03 | RAM minimum perangkat | 3 GB |
| NFR-COMPAT-04 | Penyimpanan minimum | 200 MB ruang kosong |

### 3.5 Keamanan dan Privasi

| ID | Kebutuhan |
|----|-----------|
| NFR-SEC-01 | Seluruh inferensi dilakukan on-device tanpa kirim data ke server |
| NFR-SEC-02 | Tidak memerlukan registrasi atau login |
| NFR-SEC-03 | Hanya meminta izin yang diperlukan (kamera, penyimpanan) |
| NFR-SEC-04 | Tidak mengirim foto atau metadata ke pihak ketiga |

### 3.6 Kegunaan

| ID | Kebutuhan |
|----|-----------|
| NFR-USE-01 | Pengguna baru menyelesaikan alur restorasi pertama ≤ 60 detik |
| NFR-USE-02 | Umpan balik visual untuk setiap aksi ≤ 200 ms |
| NFR-USE-03 | Pesan kesalahan dengan bahasa mudah dipahami |
| NFR-USE-04 | Ukuran sentuh minimum 48×48 dp |

### 3.7 Keandalan

| ID | Kebutuhan | Target |
|----|-----------|--------|
| NFR-REL-01 | Tingkat keberhasilan restorasi | ≥ 95% pada foto JPEG/PNG |
| NFR-REL-02 | Crash rate | ≤ 1% sesi |
| NFR-REL-03 | Pemulihan graceful dari kesalahan | Tanpa kehilangan data |

### 3.8 Pemeliharaan

| ID | Kebutuhan |
|----|-----------|
| NFR-MAIN-01 | Clean Architecture (Presentasi, Domain, Data) |
| NFR-MAIN-02 | Pola BLoC untuk manajemen state |
| NFR-MAIN-03 | Minimum 80% cakupan unit test pada BLoC dan UseCase |
| NFR-MAIN-04 | Dokumentasi dartdoc pada kelas publik |

---

## 4. Matriks Ketertelusuran

| FR | NFR Terkait | Screen Stitch |
|----|-------------|---------------|
| FR-HOME-01/02 | NFR-USE-*, NFR-PERF-04 | Dashboard - Vertical Types |
| FR-UPLOAD-01~05 | NFR-SEC-03, NFR-USE-01 | Upload Photo |
| FR-RESTORE-01~06 | NFR-PERF-01/02, NFR-MEM-* | Restoration in Progress |
| FR-RESULT-01~06 | NFR-USE-02, NFR-PERF-05 | Restoration Result, Details |
| FR-HISTORY-01~05 | NFR-REL-03 | History Gallery with Filters |
| FR-ALBUM-01~05 | NFR-REL-03 | Albums Overview, Save to Album |
| FR-SETTINGS-01~04 | NFR-SIZE-01 | Offline App Settings |
