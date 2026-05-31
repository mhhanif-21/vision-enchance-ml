// Kontrak antarmuka untuk repositori riwayat restorasi.
import '../models/restoration_entity.dart';

abstract class IHistoryRepository {
  Future<List<RestorationEntity>> getAllHistory();
  Future<void> saveRestoration(RestorationEntity restoration);
  Future<void> deleteHistory(String id);
  Future<void> deleteMultipleHistory(List<String> ids);
  // Menghapus seluruh data riwayat (diperlukan oleh Settings).
  Future<void> clearAllHistory();
}
