// Implementasi ISettingsRepository menggunakan Hive dan FileSystem.
import 'dart:io';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import '../repositories/i_settings_repository.dart';
import '../models/settings_entity.dart';
import '../models/settings_model.dart';
import '../../history/models/restoration_model.dart';
import '../../album/models/album_model.dart';

class SettingsRepositoryImpl implements ISettingsRepository {
  static const String _settingsBoxName = 'settings_box';
  static const String _historyBoxName = 'history_box';
  static const String _albumsBoxName = 'albums_box';

  @override
  Future<SettingsEntity> getSettings() async {
    final box = Hive.box<SettingsModel>(_settingsBoxName);
    return box.get('app_settings')?.toEntity() ?? SettingsEntity.initial();
  }

  @override
  Future<void> saveSettings(SettingsEntity settings) async {
    final box = Hive.box<SettingsModel>(_settingsBoxName);
    await box.put('app_settings', SettingsModel.fromEntity(settings));
  }

  @override
  Future<void> clearHistory() async {
    final box = Hive.box<RestorationModel>(_historyBoxName);
    await box.clear();
  }

  @override
  Future<void> clearAlbums() async {
    final box = Hive.box<AlbumModel>(_albumsBoxName);
    await box.clear();
  }

  // Menghitung total ukuran folder lumina_restore/ secara rekursif.
  @override
  Future<int> calculateStorageUsed() async {
    try {
      final baseDir = await getApplicationDocumentsDirectory();
      final appFolder = Directory(p.join(baseDir.path, 'lumina_restore'));
      if (!await appFolder.exists()) return 0;

      int totalBytes = 0;
      await for (final entity in appFolder.list(recursive: true)) {
        if (entity is File) {
          totalBytes += await entity.length();
        }
      }
      return totalBytes;
    } catch (_) {
      return 0;
    }
  }
}
