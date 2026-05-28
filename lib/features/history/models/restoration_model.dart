/// Model data untuk riwayat restorasi foto yang disimpan ke dalam Hive.
/// Model ini menggunakan HiveObject agar mudah diperbarui atau dihapus.
import 'package:hive/hive.dart';
import '../models/restoration_entity.dart';

part 'restoration_model.g.dart';

@HiveType(typeId: 0)
class RestorationModel extends HiveObject {
  // ID unik untuk setiap riwayat restorasi.
  @HiveField(0)
  final String id;

  // Path lokal ke gambar asli (sebelum direstorasi).
  @HiveField(1)
  final String originalImagePath;

  // Path lokal ke gambar hasil (setelah direstorasi).
  @HiveField(2)
  final String restoredImagePath;

  // Jenis model yang digunakan (contoh: 'low_light' atau 'deblur').
  @HiveField(3)
  final String modelType;

  // Waktu pembuatan riwayat restorasi ini.
  @HiveField(4)
  final DateTime createdAt;

  RestorationModel({
    required this.id,
    required this.originalImagePath,
    required this.restoredImagePath,
    required this.modelType,
    required this.createdAt,
  });

  // Mengubah model data ini menjadi entitas domain (RestorationEntity)
  RestorationEntity toEntity() {
    return RestorationEntity(
      id: id,
      originalImagePath: originalImagePath,
      restoredImagePath: restoredImagePath,
      modelType: modelType,
      createdAt: createdAt,
    );
  }

  // Membuat model data dari entitas domain (RestorationEntity)
  factory RestorationModel.fromEntity(RestorationEntity entity) {
    return RestorationModel(
      id: entity.id,
      originalImagePath: entity.originalImagePath,
      restoredImagePath: entity.restoredImagePath,
      modelType: entity.modelType,
      createdAt: entity.createdAt,
    );
  }
}
