// File ini mendefinisikan entitas Restoration (Riwayat Restorasi).
// Entitas ini berada di layer domain dan independen dari framework atau database eksternal.
// Digunakan untuk merepresentasikan data restorasi dalam logika bisnis.

class RestorationEntity {
  // ID unik untuk setiap restorasi
  final String id;
  
  // Lokasi file gambar asli yang diunggah pengguna
  final String originalImagePath;
  
  // Lokasi file gambar hasil setelah direstorasi
  final String restoredImagePath;
  
  // Jenis model yang digunakan (low_light atau deblurring)
  final String modelType;
  
  // Waktu kapan restorasi ini dilakukan
  final DateTime createdAt;

  // Konstruktor untuk membuat objek RestorationEntity
  const RestorationEntity({
    required this.id,
    required this.originalImagePath,
    required this.restoredImagePath,
    required this.modelType,
    required this.createdAt,
  });
}
