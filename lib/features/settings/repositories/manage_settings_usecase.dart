// Use case untuk seluruh operasi pengaturan aplikasi.
import '../models/settings_entity.dart';
import '../repositories/i_settings_repository.dart';

class ManageSettingsUseCase {
  final ISettingsRepository repository;

  ManageSettingsUseCase(this.repository);

  Future<SettingsEntity> getSettings() => repository.getSettings();
  Future<void> saveSettings(SettingsEntity settings) => repository.saveSettings(settings);
  Future<void> clearHistory() => repository.clearHistory();
  Future<void> clearAlbums() => repository.clearAlbums();
  Future<int> calculateStorageUsed() => repository.calculateStorageUsed();

  // Mengubah tema dan menyimpannya secara atomik.
  Future<void> toggleDarkMode(bool isDarkMode) async {
    final current = await repository.getSettings();
    await repository.saveSettings(
      current.copyWith(isDarkMode: isDarkMode, updatedAt: DateTime.now()),
    );
  }
}
