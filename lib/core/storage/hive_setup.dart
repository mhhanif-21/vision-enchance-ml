// File konfigurasi utama untuk inisialisasi Hive database saat aplikasi dimulai.
// Memastikan direktori dan box siap digunakan sebelum UI ditampilkan.
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/history/models/restoration_model.dart';
import '../../features/album/models/album_model.dart';
import '../../features/settings/models/settings_model.dart';

class HiveSetup {
  // Melakukan inisialisasi Hive dan mendaftarkan adapter yang dibutuhkan.
  static Future<void> init() async {
    // Inisialisasi direktori penyimpanan Hive untuk aplikasi Flutter.
    await Hive.initFlutter();
    
    // Mendaftarkan adapter untuk model RestorationModel, AlbumModel, dan SettingsModel.
    Hive.registerAdapter(RestorationModelAdapter());
    Hive.registerAdapter(AlbumModelAdapter());
    Hive.registerAdapter(SettingsModelAdapter());
    
    // Membuka box yang akan digunakan untuk menyimpan history, albums, dan settings.
    await Hive.openBox<RestorationModel>('history_box');
    await Hive.openBox<AlbumModel>('albums_box');
    await Hive.openBox<SettingsModel>('settings_box');
  }
}
