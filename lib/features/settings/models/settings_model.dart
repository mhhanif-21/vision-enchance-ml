// Model data Hive untuk pengaturan aplikasi.
import 'package:hive/hive.dart';
import '../models/settings_entity.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final DateTime updatedAt;

  @HiveField(2, defaultValue: 0)
  final int storageUsedBytes;

  @HiveField(3, defaultValue: true)
  final bool isAutoSave;

  SettingsModel({
    required this.isDarkMode,
    required this.updatedAt,
    this.storageUsedBytes = 0,
    this.isAutoSave = true,
  });

  SettingsEntity toEntity() {
    return SettingsEntity(
      isDarkMode: isDarkMode,
      isAutoSave: isAutoSave,
      storageUsedBytes: storageUsedBytes,
      updatedAt: updatedAt,
    );
  }

  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      isDarkMode: entity.isDarkMode,
      isAutoSave: entity.isAutoSave,
      storageUsedBytes: entity.storageUsedBytes,
      updatedAt: entity.updatedAt,
    );
  }
}
