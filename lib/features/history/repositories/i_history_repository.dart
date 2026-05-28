// File ini mendefinisikan antarmuka (interface) untuk repositori riwayat.
// Berada di layer domain, interface ini menjadi kontrak yang harus dipenuhi oleh layer data.
// Membantu memisahkan logika bisnis dari detail implementasi penyimpanan (seperti Hive).

import '../entities/restoration_entity.dart';

abstract class IHistoryRepository {
  // Mengambil semua riwayat restorasi yang tersimpan
  Future<List<RestorationEntity>> getAllHistory();
  
  // Menyimpan riwayat restorasi baru ke dalam penyimpanan
  Future<void> saveRestoration(RestorationEntity restoration);
  
  // Menghapus satu riwayat restorasi berdasarkan ID
  Future<void> deleteHistory(String id);
  
  // Menghapus beberapa riwayat sekaligus berdasarkan daftar ID
  Future<void> deleteMultipleHistory(List<String> ids);
}
