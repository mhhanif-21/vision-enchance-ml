// File ini merupakan struktur data Hive untuk pengaturan aplikasi.
import 'package:hive/hive.dart';
import '../models/settings_entity.dart';

part 'settings_model.g.dart';

@HiveType(typeId: 2)
class SettingsModel extends HiveObject {
  @HiveField(0)
  final bool isDarkMode;

  @HiveField(1)
  final DateTime updatedAt;

  SettingsModel({
    required this.isDarkMode,
    required this.updatedAt,
  });

  // Mengubah model menjadi entitas domain
  SettingsEntity toEntity() {
    return SettingsEntity(
      isDarkMode: isDarkMode,
      updatedAt: updatedAt,
    );
  }

  // Membuat model dari entitas domain
  factory SettingsModel.fromEntity(SettingsEntity entity) {
    return SettingsModel(
      isDarkMode: entity.isDarkMode,
      updatedAt: entity.updatedAt,
    );
  }
}
