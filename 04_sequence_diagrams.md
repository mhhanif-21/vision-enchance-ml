# 🔄 Sequence Diagrams — Lumina Restore

> Kode PlantUML di bawah ini dapat di-render di [plantuml.com](https://www.plantuml.com/plantuml/uml/).  
> Terdapat 3 diagram untuk proses-proses kompleks dalam sistem.

---

## 1. Alur Restorasi Foto End-to-End

Menggambarkan alur lengkap dari pemilihan foto hingga penyimpanan hasil, termasuk penanganan kesalahan.

```plantuml
@startuml Seq_RestorasiFoto
!theme cerulean
skinparam sequenceMessageAlign center
skinparam responseMessageBelowArrow true
skinparam maxMessageSize 200

title Diagram Sekuens — Alur Restorasi Foto End-to-End

actor "Pengguna" as User
participant "HalamanUpload" as UploadPage
participant "RestoreBloc" as Bloc
participant "RestoreImageUseCase" as UseCase
participant "ModelManager" as ModelMgr
participant "MemoryUtils" as MemUtils
participant "ImagePreprocessor" as PreProc
participant "OnnxInferenceService" as MLService
participant "ImagePostprocessor" as PostProc
participant "HistoryRepository" as HistoryRepo
database "SQLite" as DB
participant "FileStorage" as FileStore

== Fase 1: Pemilihan & Validasi Foto ==

User -> UploadPage : Memilih foto dari galeri/kamera
activate UploadPage

UploadPage -> UploadPage : Validasi format (JPEG/PNG/WebP)
alt Format tidak didukung
    UploadPage --> User : Tampilkan pesan error format
else Format valid
    UploadPage -> UploadPage : Validasi ukuran (≤20 MB, ≤4096px)
    alt Ukuran melebihi batas
        UploadPage --> User : Tampilkan pesan error ukuran
    else Ukuran valid
        UploadPage --> User : Tampilkan pratinjau foto
        User -> UploadPage : Memilih jenis restorasi\n& konfirmasi "Mulai"
    end
end

== Fase 2: Persiapan Inferensi ==

UploadPage -> Bloc : RestorationRequested(\n  imagePath, modelType)
activate Bloc

Bloc -> Bloc : Emit(RestorationProcessing\n  tahap: "Mempersiapkan...")

Bloc -> UseCase : execute(imagePath, modelType)
activate UseCase

UseCase -> MemUtils : getAvailableRAM()
activate MemUtils
MemUtils --> UseCase : availableRAM (MB)
deactivate MemUtils

UseCase -> UseCase : Tentukan strategi resolusi:\n- Resize ke maks 512px (kelipatan 32) jika melebihi batas\n- Untuk memastikan performa dan mencegah OOM

UseCase -> ModelMgr : getSession(modelType)
activate ModelMgr
ModelMgr -> ModelMgr : Cek apakah model\nsudah dimuat
alt Model lain sedang dimuat
    ModelMgr -> ModelMgr : Unload model sebelumnya\n(release session + GC hint)
end
ModelMgr -> ModelMgr : Load model ONNX FP16\ndari assets
ModelMgr --> UseCase : OrtSession
deactivate ModelMgr

== Fase 3: Pra-proses Gambar ==

Bloc -> Bloc : Emit(RestorationProcessing\n  tahap: "Memproses gambar...")

UseCase -> PreProc : preprocess(imageBytes,\n  maxResolution, modelType)
activate PreProc
PreProc -> PreProc : Decode gambar
PreProc -> PreProc : Resize ke resolusi maksimal\n(tetap menjaga aspek rasio)
PreProc -> PreProc : Normalisasi nilai piksel\nke rentang [0.0, 1.0]
PreProc -> PreProc : Konversi ke tensor\n[1, H, W, 3] float32
PreProc --> UseCase : InputTensor, originalSize
deactivate PreProc

== Fase 4: Inferensi AI ==

Bloc -> Bloc : Emit(RestorationProcessing\n  tahap: "Menjalankan AI...",\n  progress: 30%)

UseCase -> MLService : runInference(\n  session, inputTensor)
activate MLService
MLService -> MLService : OrtSession.run(\n  inputTensor)
MLService --> UseCase : outputTensor
deactivate MLService

== Fase 5: Pasca-proses & Simpan ==

Bloc -> Bloc : Emit(RestorationProcessing\n  tahap: "Menyimpan hasil...",\n  progress: 80%)

UseCase -> PostProc : postprocess(outputTensor,\n  originalSize)
activate PostProc
PostProc -> PostProc : Denormalisasi nilai\npiksel [0.0,1.0] → [0,255]
PostProc -> PostProc : Clip nilai ke rentang valid
PostProc -> PostProc : Resize ke ukuran asli\n(jika perlu)
PostProc -> PostProc : Encode ke format JPEG\n(kualitas 95%)
PostProc --> UseCase : restoredImageBytes
deactivate PostProc

UseCase -> FileStore : saveRestoredImage(\n  restoredImageBytes, id)
activate FileStore
FileStore -> FileStore : Simpan ke\n/files/restored/{id}.jpg
FileStore -> FileStore : Generate thumbnail 200px\nke /files/thumbnails/{id}.jpg
FileStore --> UseCase : savedPaths
deactivate FileStore

UseCase -> HistoryRepo : saveRestoration(\n  restorationEntity)
activate HistoryRepo
HistoryRepo -> DB : INSERT INTO restorations\n  (id, model_type, paths, ...)
DB --> HistoryRepo : success
HistoryRepo --> UseCase : saved
deactivate HistoryRepo

UseCase --> Bloc : RestorationResult(\n  originalPath, restoredPath,\n  metadata)
deactivate UseCase

== Fase 6: Tampilkan Hasil ==

Bloc -> Bloc : Emit(RestorationSuccess(\n  result))
Bloc --> UploadPage : State: Success
deactivate Bloc

UploadPage -> User : Navigasi ke HalamanHasil\ndengan slider sebelum/sesudah
deactivate UploadPage

@enduml
```



---

## 3. Siklus Hidup Model ONNX (Model Lifecycle)

Menggambarkan manajemen pemuatan dan pembongkaran model untuk memastikan hanya satu model aktif di memori.

```plantuml
@startuml Seq_ModelLifecycle
!theme cerulean
skinparam sequenceMessageAlign center

title Diagram Sekuens — Siklus Hidup Model ONNX

participant "RestoreBloc" as Bloc
participant "ModelManager" as Manager
participant "OnnxRuntime" as ORT
participant "AssetBundle" as Assets
participant "MemoryUtils" as MemUtils

== Skenario 1: Pemuatan Model Pertama (Cold Start) ==

Bloc -> Manager : getSession(ModelType.lowLight)
activate Manager

Manager -> Manager : Cek _activeSession == null\n_loadedModel == null
Manager -> Manager : Status: Belum ada model dimuat

Manager -> MemUtils : getAvailableRAM()
MemUtils --> Manager : 2048 MB tersedia

Manager -> Assets : load("models/low_light_enhancement_fp16.onnx")
activate Assets
Assets --> Manager : modelBytes (174 KB)
deactivate Assets

Manager -> ORT : createSession(modelBytes,\n  sessionOptions)
activate ORT
note right of ORT
  SessionOptions:
  - intraOpNumThreads: 2
  - graphOptimizationLevel: ALL
  - enableCpuMemArena: true
end note
ORT --> Manager : OrtSession
deactivate ORT

Manager -> Manager : _activeSession = session\n_loadedModel = lowLight
Manager --> Bloc : OrtSession (siap pakai)
deactivate Manager

== Skenario 2: Pergantian Model (Swap) ==

Bloc -> Manager : getSession(ModelType.deblurring)
activate Manager

Manager -> Manager : Cek _loadedModel == lowLight\n≠ deblurring
Manager -> Manager : Perlu pergantian model

note over Manager
  ⚠️ KRITIS: Hanya 1 model
  boleh aktif di memori.
  Wajib unload model lama
  sebelum load model baru.
end note

Manager -> ORT : _activeSession.release()
activate ORT
ORT -> ORT : Bebaskan semua\nalokasi memori model
ORT --> Manager : released
deactivate ORT

Manager -> Manager : _activeSession = null\n_loadedModel = null\nGC hint (System.gc)

Manager -> MemUtils : getAvailableRAM()
MemUtils --> Manager : 1800 MB tersedia

alt RAM cukup (≥ 500 MB)
    Manager -> Assets : load("models/deblurring_nafnet_fp16.onnx")
    activate Assets
    Assets --> Manager : modelBytes (83 MB)
    deactivate Assets

    Manager -> ORT : createSession(modelBytes,\n  sessionOptions)
    activate ORT
    ORT --> Manager : OrtSession
    deactivate ORT

    Manager -> Manager : _activeSession = session\n_loadedModel = deblurring
    Manager --> Bloc : OrtSession (siap pakai)
else RAM tidak cukup (< 500 MB)
    Manager --> Bloc : throw InsufficientMemoryException(\n  "Memori tidak cukup untuk\n  memuat model deblurring.\n  Tutup aplikasi lain dan coba lagi.")
end
deactivate Manager

== Skenario 3: Pembersihan (App Lifecycle) ==

Bloc -> Manager : dispose()
activate Manager
Manager -> ORT : _activeSession?.release()
ORT --> Manager : released
Manager -> Manager : _activeSession = null\n_loadedModel = null
Manager --> Bloc : disposed
deactivate Manager

@enduml
```
