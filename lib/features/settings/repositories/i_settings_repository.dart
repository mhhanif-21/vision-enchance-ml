// File ini mendefinisikan antarmuka (interface) untuk pengaturan aplikasi.
import '../entities/settings_entity.dart';

abstract class ISettingsRepository {
  // Mengambil konfigurasi aplikasi saat ini
  Future<SettingsEntity> getSettings();

  // Menyimpan pembaruan konfigurasi aplikasi
  Future<void> saveSettings(SettingsEntity settings);

  // Menghapus semua riwayat restorasi (History) dari perangkat
  Future<void> clearHistory();

  // Menghapus semua daftar album yang telah dibuat
  Future<void> clearAlbums();
}
