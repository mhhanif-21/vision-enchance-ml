// File ini mendefinisikan UseCase untuk mengelola riwayat restorasi.
// Berisi logika bisnis spesifik terkait fitur riwayat.
// UseCase ini bertindak sebagai perantara antara Presentation Layer (BLoC) dan Data Layer.

import '../entities/restoration_entity.dart';
import '../repositories/i_history_repository.dart';

class ManageHistoryUseCase {
  // Referensi ke abstraksi repositori riwayat
  final IHistoryRepository repository;

  // Injeksi dependensi melalui konstruktor
  ManageHistoryUseCase(this.repository);

  // Mengambil semua riwayat dari repositori
  Future<List<RestorationEntity>> getAllHistory() {
    return repository.getAllHistory();
  }

  // Menyimpan entitas restorasi baru
  Future<void> saveRestoration(RestorationEntity restoration) {
    return repository.saveRestoration(restoration);
  }

  // Menghapus satu riwayat berdasarkan ID
  Future<void> deleteHistory(String id) {
    return repository.deleteHistory(id);
  }

  // Menghapus banyak riwayat secara massal
  Future<void> deleteMultipleHistory(List<String> ids) {
    return repository.deleteMultipleHistory(ids);
  }
}
