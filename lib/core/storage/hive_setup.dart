/// File konfigurasi utama untuk inisialisasi Hive database saat aplikasi dimulai.
/// Memastikan direktori dan box siap digunakan sebelum UI ditampilkan.
import 'package:hive_flutter/hive_flutter.dart';
import '../../features/history/data/models/restoration_model.dart';

class HiveSetup {
  // Melakukan inisialisasi Hive dan mendaftarkan adapter yang dibutuhkan.
  static Future<void> init() async {
    // Inisialisasi direktori penyimpanan Hive untuk aplikasi Flutter.
    await Hive.initFlutter();
    
    // Mendaftarkan adapter untuk model RestorationModel.
    Hive.registerAdapter(RestorationModelAdapter());
    
    // Membuka box yang akan digunakan untuk menyimpan history.
    await Hive.openBox<RestorationModel>('history_box');
  }
}
