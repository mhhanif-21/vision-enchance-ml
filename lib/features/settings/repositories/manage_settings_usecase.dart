// File ini mendefinisikan UseCase untuk modul Pengaturan (Settings).
// Berperan sebagai perantara BLoC dengan Repository layer.
import '../models/settings_entity.dart';
import '../repositories/i_settings_repository.dart';

class ManageSettingsUseCase {
  final ISettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  // Mengambil pengaturan yang tersimpan
  Future<SettingsEntity> getSettings() {
    return repository.getSettings();
  }

  // Menyimpan pengaturan baru
  Future<void> saveSettings(SettingsEntity settings) {
    return repository.saveSettings(settings);
  }

  // Mengubah mode tema
  Future<void> toggleDarkMode(bool isDarkMode) async {
    final currentSettings = await repository.getSettings();
    final newSettings = currentSettings.copyWith(
      isDarkMode: isDarkMode,
      updatedAt: DateTime.now(),
    );
    await repository.saveSettings(newSettings);
  }

  // Menghapus semua riwayat pengguna
  Future<void> clearHistory() {
    return repository.clearHistory();
  }

  // Menghapus semua album pengguna
  Future<void> clearAlbums() {
    return repository.clearAlbums();
  }
}
