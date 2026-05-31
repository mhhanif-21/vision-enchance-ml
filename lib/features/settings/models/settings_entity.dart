// Entitas domain untuk pengaturan aplikasi.
// Menyimpan preferensi pengguna dan informasi storage yang ditampilkan di Settings screen.

class SettingsEntity {
  final bool isDarkMode;
  final int storageUsedBytes;
  final DateTime updatedAt;

  const SettingsEntity({
    required this.isDarkMode,
    required this.storageUsedBytes,
    required this.updatedAt,
  });

  // Nilai default saat pertama kali aplikasi dijalankan.
  factory SettingsEntity.initial() {
    return SettingsEntity(
      isDarkMode: false,
      storageUsedBytes: 0,
      updatedAt: DateTime.now(),
    );
  }

  SettingsEntity copyWith({
    bool? isDarkMode,
    int? storageUsedBytes,
    DateTime? updatedAt,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      storageUsedBytes: storageUsedBytes ?? this.storageUsedBytes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
