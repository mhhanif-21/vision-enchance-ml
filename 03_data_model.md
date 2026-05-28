# 📐 Data Model — Lumina Restore

> Updated: 27 Mei 2026 (Hive NoSQL Migration)

---

## 1. Conceptual Data Model

Menggambarkan entitas dan struktur penyimpanan berbasis **Hive (NoSQL)**.

### Box `history_box`
Penyimpanan utama untuk riwayat restorasi.

**Model `RestorationModel` (HiveType 0):**
- `id` (String) — UUID unik untuk setiap restorasi (HiveField 0)
- `originalImagePath` (String) — Lokasi file gambar input asli (HiveField 1)
- `restoredImagePath` (String) — Lokasi file gambar hasil restorasi (HiveField 2)
- `modelType` (String) — Jenis model: 'low_light' atau 'deblurring' (HiveField 3)
- `createdAt` (DateTime) — Waktu restorasi dibuat (HiveField 4)

### Box `albums_box`
Penyimpanan untuk album pengguna.

**Model `AlbumModel` (HiveType 1):**
- `id` (String) — UUID unik untuk setiap album (HiveField 0)
- `name` (String) — Nama album (HiveField 1)
- `restorationIds` (List<String>) — Kumpulan ID restorasi yang masuk dalam album ini (HiveField 2)
- `createdAt` (DateTime) — Waktu album dibuat (HiveField 3)
- `updatedAt` (DateTime) — Waktu terakhir album dimodifikasi (HiveField 4)

### Box `settings_box`
Penyimpanan preferensi pengguna (Key-Value Store).
- `last_model_used` (String) -> default: 'low_light'
- `auto_save_to_gallery` (bool) -> default: true
- `show_onboarding` (bool) -> default: true

---

## 2. Catatan Implementasi

### Strategi Penyimpanan File

```
/data/data/com.example.vision_enchance_ml/
├── app_flutter/
│   ├── history_box.hive             ← File database Hive (History)
│   ├── albums_box.hive              ← File database Hive (Albums)
│   └── settings_box.hive            ← File database Hive (Settings)
├── lumina_restore/
│   ├── originals/                     ← Foto asli (copy)
│   │   └── {restoration_id}.jpg
│   ├── restored/                      ← Foto hasil restorasi
│   │   └── {restoration_id}_restored.jpg
│   └── thumbnails/                    ← Thumbnail 200px
│       └── {restoration_id}_thumb.jpg
```
