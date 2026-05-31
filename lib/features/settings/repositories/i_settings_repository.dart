// Kontrak antarmuka untuk repositori pengaturan aplikasi.
import '../models/settings_entity.dart';

abstract class ISettingsRepository {
  Future<SettingsEntity> getSettings();
  Future<void> saveSettings(SettingsEntity settings);
  Future<void> clearHistory();
  Future<void> clearAlbums();
  // Menghitung total ukuran folder penyimpanan aplikasi dalam byte.
  Future<int> calculateStorageUsed();
}
