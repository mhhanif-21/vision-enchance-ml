/// Implementasi repository untuk mengelola data riwayat restorasi di Hive.
/// Berfungsi sebagai jembatan antara logika BLoC dan penyimpanan lokal.
import 'package:hive_flutter/hive_flutter.dart';
import '../models/restoration_model.dart';

class HistoryRepositoryImpl {
  // Nama box Hive yang digunakan untuk menyimpan riwayat.
  static const String boxName = 'history_box';

  // Menyimpan riwayat restorasi baru ke dalam Hive.
  Future<void> saveRestoration(RestorationModel restoration) async {
    final box = Hive.box<RestorationModel>(boxName);
    await box.put(restoration.id, restoration);
  }

  // Mengambil semua riwayat restorasi, diurutkan dari yang terbaru ke terlama.
  Future<List<RestorationModel>> getAllHistory() async {
    final box = Hive.box<RestorationModel>(boxName);
    final history = box.values.toList();
    
    // Mengurutkan data secara descending (terbaru di atas).
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return history;
  }

  // Menghapus satu riwayat restorasi berdasarkan ID.
  Future<void> deleteHistory(String id) async {
    final box = Hive.box<RestorationModel>(boxName);
    await box.delete(id);
  }

  // Menghapus seluruh data riwayat restorasi di dalam box.
  Future<void> clearAllHistory() async {
    final box = Hive.box<RestorationModel>(boxName);
    await box.clear();
  }
}
