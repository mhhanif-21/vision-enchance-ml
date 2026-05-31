// Model data Hive untuk riwayat restorasi foto.
// Field baru ditambahkan di index berikutnya (5–9) agar backward-compatible.
import 'package:hive/hive.dart';
import '../models/restoration_entity.dart';

part 'restoration_model.g.dart';

@HiveType(typeId: 0)
class RestorationModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String originalImagePath;

  @HiveField(2)
  final String restoredImagePath;

  @HiveField(3)
  final String modelType;

  @HiveField(4)
  final DateTime createdAt;

  // Field baru (index 5–8): menambah metadata tanpa merusak data lama.
  @HiveField(5, defaultValue: '')
  final String thumbnailPath;

  @HiveField(6, defaultValue: 0)
  final int processingTimeMs;

  @HiveField(7, defaultValue: 0)
  final int outputWidth;

  @HiveField(8, defaultValue: 0)
  final int outputHeight;

  RestorationModel({
    required this.id,
    required this.originalImagePath,
    required this.restoredImagePath,
    required this.modelType,
    required this.createdAt,
    this.thumbnailPath = '',
    this.processingTimeMs = 0,
    this.outputWidth = 0,
    this.outputHeight = 0,
  });

  // Mengonversi model Hive menjadi entitas domain.
  RestorationEntity toEntity() {
    return RestorationEntity(
      id: id,
      originalImagePath: originalImagePath,
      restoredImagePath: restoredImagePath,
      thumbnailPath: thumbnailPath,
      modelType: modelType,
      createdAt: createdAt,
      processingTimeMs: processingTimeMs,
      outputWidth: outputWidth,
      outputHeight: outputHeight,
    );
  }

  // Membuat model Hive dari entitas domain.
  factory RestorationModel.fromEntity(RestorationEntity entity) {
    return RestorationModel(
      id: entity.id,
      originalImagePath: entity.originalImagePath,
      restoredImagePath: entity.restoredImagePath,
      thumbnailPath: entity.thumbnailPath,
      modelType: entity.modelType,
      createdAt: entity.createdAt,
      processingTimeMs: entity.processingTimeMs,
      outputWidth: entity.outputWidth,
      outputHeight: entity.outputHeight,
    );
  }
}
