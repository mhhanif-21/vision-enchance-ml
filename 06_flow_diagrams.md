# 🔀 Diagram Alur — Lumina Restore

> Diagram di bawah menggunakan format Mermaid dan dapat di-render langsung di GitHub, VS Code, atau [mermaid.live](https://mermaid.live).

---

## 1. Screen Flow (Alur Navigasi Layar)

```mermaid
stateDiagram-v2
    direction TB

    [*] --> Beranda

    state "🏠 Beranda" as Beranda {
        direction LR
        state "Kartu Peningkatan\nCahaya Rendah" as KartuLowLight
        state "Kartu Penghilangan\nBlur" as KartuDeblur
    }

    state "📷 Upload Foto" as Upload {
        direction TB
        state "Pilih dari\nGaleri" as PilihGaleri
        state "Ambil dari\nKamera" as AmbilKamera
        state "Pratinjau &\nValidasi Foto" as Pratinjau
        state "Konfirmasi\n& Mulai" as Konfirmasi

        PilihGaleri --> Pratinjau
        AmbilKamera --> Pratinjau
        Pratinjau --> Konfirmasi
    }

    state "⏳ Proses Restorasi" as Proses {
        direction TB
        state "Pra-proses\n(Resize, Normalisasi)" as TahapPra
        state "Inferensi AI\n(ONNX Runtime)" as TahapInferensi
        state "Pasca-proses\n(Denormalisasi, Simpan)" as TahapPasca

        TahapPra --> TahapInferensi
        TahapInferensi --> TahapPasca
    }

    state "✅ Hasil Restorasi" as Hasil {
        direction LR
        state "Slider\nSebelum/Sesudah" as Slider
        state "Metadata\nRestorasi" as Metadata
    }

    state "💾 Simpan ke Album" as SimpanAlbum {
        direction TB
        state "Pilih Album\nyang Ada" as PilihAlbum
        state "Buat Album\nBaru" as BuatAlbum
    }

    state "📁 Daftar Album" as DaftarAlbum
    state "📂 Isi Album" as IsiAlbum
    state "🕐 Riwayat Restorasi" as Riwayat
    state "⚙️ Pengaturan" as Pengaturan
    state "❌ Dialog Error" as DialogError

    Beranda --> Upload : Ketuk kartu restorasi
    Beranda --> Riwayat : Navigasi tab Riwayat
    Beranda --> DaftarAlbum : Navigasi tab Album
    Beranda --> Pengaturan : Ikon pengaturan

    Upload --> Proses : Konfirmasi mulai restorasi
    Upload --> Beranda : Tombol kembali

    Proses --> Hasil : Inferensi berhasil
    Proses --> DialogError : Inferensi gagal / OOM
    Proses --> Upload : Pengguna membatalkan

    DialogError --> Upload : Coba lagi
    DialogError --> Beranda : Kembali ke beranda

    Hasil --> SimpanAlbum : Tombol simpan ke album
    Hasil --> Beranda : Tombol selesai
    Hasil --> Upload : Restorasi foto lain

    SimpanAlbum --> Hasil : Berhasil disimpan

    Riwayat --> Hasil : Ketuk item riwayat
    Riwayat --> Beranda : Navigasi tab Beranda

    DaftarAlbum --> IsiAlbum : Ketuk album
    DaftarAlbum --> Beranda : Navigasi tab Beranda
    IsiAlbum --> Hasil : Ketuk foto dalam album

    Pengaturan --> Beranda : Tombol kembali
```

---

## 2. Memory Management Flow (Alur Manajemen Memori)

```mermaid
flowchart TB
    Start(["🚀 Permintaan Restorasi Diterima"])
    Start --> CheckModel{"Jenis Model\nyang Diminta?"}

    CheckModel -->|"Zero-DCE\n(Low-Light)"| LowLightPath
    CheckModel -->|"NAFNet\n(Deblurring)"| DeblurPath

    subgraph LowLightPath["🟢 Jalur Low-Light (Model Ringan: ~174 KB)"]
        direction TB
        LL_CheckRAM{"RAM Tersedia\n≥ 100 MB?"}
        LL_CheckRAM -->|Ya| LL_CheckRes{"Resolusi\nGambar Input?"}
        LL_CheckRAM -->|Tidak| LL_Error["❌ Tampilkan Error:\nMemori Tidak Cukup"]

        LL_CheckRes -->|"≤ 1080p"| LL_Direct["✅ Inferensi Langsung\n(Direct Inference)"]
        LL_CheckRes -->|"> 1080p"| LL_Resize["📐 Resize ke 1080p\nlalu Inferensi Langsung"]
    end

    subgraph DeblurPath["🔵 Jalur Deblurring (Model Besar: ~83 MB)"]
        direction TB
        DB_UnloadPrev{"Model Lain\nSedang Dimuat?"}
        DB_UnloadPrev -->|Ya| DB_Unload["🗑️ Unload Model Sebelumnya\n(Release Session + GC)"]
        DB_UnloadPrev -->|Tidak| DB_CheckRAM

        DB_Unload --> DB_CheckRAM{"RAM Tersedia\n≥ 500 MB?"}
        DB_CheckRAM -->|Tidak| DB_Error["❌ Tampilkan Error:\nMemori Tidak Cukup\nuntuk Model Deblurring"]

        DB_CheckRAM -->|Ya| DB_LoadModel["📥 Muat Model NAFNet FP16\n(~83 MB ke memori)"]
        DB_LoadModel --> DB_DetectTier{"Deteksi Tier\nPerangkat"}

        DB_DetectTier -->|"Semua Tier"| DB_Resize

        subgraph DB_Resize["📐 Resize Resolusi"]
            direction TB
            TR_Cap["Cap Resolusi Maksimum\n512px (kelipatan 32)\nuntuk performa cepat"]
            TR_Cap --> TR_Direct["✅ Inferensi Langsung"]
        end
    end

    LL_Direct --> PostProcess
    LL_Resize --> PostProcess
    TR_Direct --> PostProcess

    PostProcess(["✅ Pasca-proses & Simpan Hasil"])
    PostProcess --> Cleanup["🧹 Pembersihan:\n- Hapus file tile sementara\n- Unload model (opsional)\n- GC hint"]

    style LowLightPath fill:#f0fdf4,stroke:#456462
    style DeblurPath fill:#eff6ff,stroke:#5e5f5c
    style DB_Resize fill:#f0fdf4,stroke:#166534
```

---

## 3. Inference Pipeline (Pipeline Inferensi)

```mermaid
flowchart LR
    subgraph Input["📥 Input"]
        direction TB
        A1["Foto Asli\n(JPEG/PNG/WebP)"]
        A2["Jenis Model\n(Low-Light / Deblurring)"]
    end

    subgraph PreProcess["🔧 Pra-proses"]
        direction TB
        B1["Decode Gambar\n(bytes → pixel array)"]
        B2["Resize ke Resolusi\nMaksimal Sesuai Tier"]
        B4["Konversi ke Tensor\n[1, H, W, 3] float32"]

        B1 --> B2 --> B3 --> B4
    end

    subgraph DirectPath["⚡ Jalur Langsung"]
        direction TB
        C1["Kirim tensor penuh\nke ONNX Runtime"]
        C2["Terima output tensor\n[1, H, W, 3]"]
        C1 --> C2
    end

    subgraph Inference["🧠 Mesin ONNX Runtime"]
        direction TB
        E1["Muat Model FP16\ndari Assets"]
        E2["Jalankan Session.run\ndengan input tensor"]
        E3["Output tensor\n[1, H, W, 3] float32"]

        E1 --> E2 --> E3
    end

    subgraph PostProcess["📤 Pasca-proses"]
        direction TB
        F1["Denormalisasi Piksel\n[0.0, 1.0] → [0, 255]"]
        F2["Clip Nilai ke\nRentang Valid [0, 255]"]
        F3["Resize ke Ukuran\nAsli (jika perlu)"]
        F4["Encode ke JPEG\n(Kualitas 95%)"]

        F1 --> F2 --> F3 --> F4
    end

    subgraph Output["💾 Output"]
        direction TB
        G1["Simpan ke\nFile Storage"]
        G2["Generate\nThumbnail 200px"]
        G3["Catat di\nDatabase SQLite"]
        G4["Tampilkan Hasil\ndi Halaman"]

        G1 --> G2 --> G3 --> G4
    end

    PreProcess --> DirectPath
    DirectPath --> Inference
    Inference --> PostProcess

    PostProcess --> Output

    style Input fill:#FDFCF8,stroke:#5e5f5c
    style PreProcess fill:#E5E1E6,stroke:#5e5f5c
    style DirectPath fill:#C7E9E7,stroke:#456462
    style Inference fill:#98B9B7,stroke:#456462,color:#fff
    style PostProcess fill:#E5E1E6,stroke:#5e5f5c
    style Output fill:#FDFCF8,stroke:#5e5f5c
```
