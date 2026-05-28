// File ini mengimplementasikan logika penyimpanan pengaturan di Hive.
import 'package:hive_flutter/hive_flutter.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/entities/settings_entity.dart';
import '../models/settings_model.dart';
import '../../../history/data/models/restoration_model.dart';
import '../../../album/data/models/album_model.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  // Nama box Hive yang digunakan
  static const String settingsBoxName = 'settings_box';
  static const String historyBoxName = 'history_box';
  static const String albumsBoxName = 'albums_box';

  @override
  Future<SettingsEntity> getSettings() async {
    final box = Hive.box<SettingsModel>(settingsBoxName);
    final model = box.get('app_settings');
    
    // Jika belum ada, kembalikan default
    if (model == null) {
      return SettingsEntity.initial();
    }
    
    return model.toEntity();
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    final box = Hive.box<SettingsModel>(settingsBoxName);
    final model = SettingsModel.fromEntity(settings);
    await box.put('app_settings', model);
  }

  @override
  Future<void> clearHistory() async {
    final box = Hive.box<RestorationModel>(historyBoxName);
    await box.clear();
  }

  @override
  Future<void> clearAlbums() async {
    final box = Hive.box<AlbumModel>(albumsBoxName);
    await box.clear();
  }
}
