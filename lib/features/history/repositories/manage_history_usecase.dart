// Use case untuk mengelola seluruh operasi pada riwayat restorasi.
import '../models/restoration_entity.dart';
import '../repositories/i_history_repository.dart';

class ManageHistoryUseCase {
  final IHistoryRepository repository;

  ManageHistoryUseCase(this.repository);

  Future<List<RestorationEntity>> getAllHistory() => repository.getAllHistory();
  Future<void> saveRestoration(RestorationEntity restoration) => repository.saveRestoration(restoration);
  Future<void> deleteHistory(String id) => repository.deleteHistory(id);
  Future<void> deleteMultipleHistory(List<String> ids) => repository.deleteMultipleHistory(ids);
  Future<void> clearAllHistory() => repository.clearAllHistory();
}
