// File ini mendefinisikan entitas Settings.
// Berfungsi untuk menyimpan konfigurasi aplikasi pengguna.

class SettingsEntity {
  // Apakah tema gelap diaktifkan
  final bool isDarkMode;
  
  // Waktu pengaturan terakhir diperbarui
  final DateTime updatedAt;

  const SettingsEntity({
    required this.isDarkMode,
    required this.updatedAt,
  });

  // Nilai default untuk pengaturan awal aplikasi
  factory SettingsEntity.initial() {
    return SettingsEntity(
      isDarkMode: false,
      updatedAt: DateTime.now(),
    );
  }

  // Membuat salinan objek dengan field yang bisa diubah
  SettingsEntity copyWith({
    bool? isDarkMode,
    DateTime? updatedAt,
  }) {
    return SettingsEntity(
      isDarkMode: isDarkMode ?? this.isDarkMode,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
