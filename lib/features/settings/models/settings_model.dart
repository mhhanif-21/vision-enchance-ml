// Model data Hive untuk pengaturan aplikasi.
// Field storageUsedBytes ditambahkan di index 2 dengan nilai default 0.
import 'package:hive/hive.dart';
import '../models/settings_entity.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final DateTime updatedAt;

  // Field baru: ukuran penyimpanan yang digunakan (dalam byte).
  @HiveField(2, defaultValue: 0)
  final int storageUsedBytes;

  SettingsModel({
    required this.isDarkMode,
    required this.updatedAt,
    this.storageUsedBytes = 0,
  });

  // Mengubah model menjadi entitas domain.
  SettingsEntity toEntity() {
    return SettingsEntity(
      isDarkMode: isDarkMode,
      storageUsedBytes: storageUsedBytes,
      updatedAt: updatedAt,
    );
  }

  // Membuat model dari entitas domain.
  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      isDarkMode: entity.isDarkMode,
      storageUsedBytes: entity.storageUsedBytes,
      updatedAt: entity.updatedAt,
    );
  }
}
