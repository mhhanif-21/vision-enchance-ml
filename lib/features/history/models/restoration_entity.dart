// Entitas domain untuk riwayat restorasi foto.
// Menyimpan semua metadata yang diperlukan untuk screen History dan Restoration Details.

class RestorationEntity {
  final String id;
  final String originalImagePath;
  final String restoredImagePath;
  final String thumbnailPath;
  final String modelType;
  final DateTime createdAt;
  final int processingTimeMs;
  final int outputWidth;
  final int outputHeight;

  const RestorationEntity({
    required this.id,
    required this.originalImagePath,
    required this.restoredImagePath,
    required this.thumbnailPath,
    required this.modelType,
    required this.createdAt,
    required this.processingTimeMs,
    required this.outputWidth,
    required this.outputHeight,
  });
}
