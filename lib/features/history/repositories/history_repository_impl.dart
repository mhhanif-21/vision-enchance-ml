// Implementasi repository untuk mengelola data riwayat restorasi di Hive.
// Berfungsi sebagai jembatan antara logika BLoC dan penyimpanan lokal.
import 'package:hive_flutter/hive_flutter.dart';
import '../models/restoration_model.dart';
import '../repositories/i_history_repository.dart';
import '../models/restoration_entity.dart';

class HistoryRepositoryImpl implements IHistoryRepository {
  // Nama box Hive yang digunakan untuk menyimpan riwayat.
  static const String boxName = 'history_box';

  // Menyimpan riwayat restorasi baru ke dalam Hive.
  @override
  Future<void> saveRestoration(RestorationEntity restoration) async {
    final box = Hive.box<RestorationModel>(boxName);
    final model = RestorationModel.fromEntity(restoration);
    await box.put(model.id, model);
  }

  // Mengambil semua riwayat restorasi, diurutkan dari yang terbaru ke terlama.
  @override
  Future<List<RestorationEntity>> getAllHistory() async {
    final box = Hive.box<RestorationModel>(boxName);
    final history = box.values.toList();
    
    // Mengurutkan data secara descending (terbaru di atas).
    history.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return history.map((model) => model.toEntity()).toList();
  }

  // Menghapus satu riwayat restorasi berdasarkan ID.
  @override
  Future<void> deleteHistory(String id) async {
    final box = Hive.box<RestorationModel>(boxName);
    await box.delete(id);
  }

  // Menghapus seluruh data riwayat restorasi di dalam box.
  @override
  Future<void> clearAllHistory() async {
    final box = Hive.box<RestorationModel>(boxName);
    await box.clear();
  }

  // Menghapus beberapa riwayat sekaligus berdasarkan daftar ID
  @override
  Future<void> deleteMultipleHistory(List<String> ids) async {
    final box = Hive.box<RestorationModel>(boxName);
    await box.deleteAll(ids);
  }
}
