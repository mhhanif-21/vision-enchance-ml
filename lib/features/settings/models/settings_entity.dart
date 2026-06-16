// Entitas domain untuk pengaturan aplikasi.
// Menyimpan preferensi pengguna dan informasi storage.

class SettingsEntity {
  final bool isDarkMode;
  final bool isAutoSave;
  final int storageUsedBytes;
  final DateTime updatedAt;

  const SettingsEntity({
    required this.isDarkMode,
    required this.isAutoSave,
    required this.storageUsedBytes,
    required this.updatedAt,
  });

  factory SettingsEntity.initial() {
    return SettingsEntity(
      isDarkMode: false,
      isAutoSave: true,
      storageUsedBytes: 0,
      updatedAt: DateTime.now(),
    );
  }

  SettingsEntity copyWith({
    bool? isDarkMode,
    bool? isAutoSave,
    int? storageUsedBytes,
    DateTime? updatedAt,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isAutoSave: isAutoSave ?? this.isAutoSave,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
