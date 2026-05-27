/// File ini berisi logika BLoC untuk mengelola riwayat restorasi foto.
/// BLoC ini mengambil data dari HistoryRepositoryImpl dan menyediakannya ke UI.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../data/models/restoration_model.dart';
import '../../data/repositories/history_repository_impl.dart';

// --- Events ---

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memuat semua riwayat dari database lokal.
class LoadHistory extends HistoryEvent {}

// Event untuk menghapus satu riwayat berdasarkan ID-nya.
class DeleteHistory extends HistoryEvent {
  final String id;
  const DeleteHistory(this.id);

  @override
  List<Object> get props => [id];
}

// --- States ---

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

// State saat riwayat sedang dimuat.
class HistoryLoading extends HistoryState {}

// State saat riwayat berhasil dimuat dan siap ditampilkan.
class HistoryLoaded extends HistoryState {
  final List<RestorationModel> historyList;

  const HistoryLoaded(this.historyList);

  @override
  List<Object> get props => [historyList];
}

// State jika terjadi error saat memuat data riwayat.
class HistoryError extends HistoryState {
  final String message;

  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BLoC ---

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final HistoryRepositoryImpl repository;

  HistoryBloc({required this.repository}) : super(HistoryLoading()) {
    // Mendaftarkan handler untuk event pemuatan data.
    on<LoadHistory>(_onLoadHistory);
    
    // Mendaftarkan handler untuk event penghapusan data.
    on<DeleteHistory>(_onDeleteHistory);
  }

  // Fungsi untuk menangani pemuatan data riwayat dari repository lokal.
  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await repository.getAllHistory();
      emit(HistoryLoaded(history));
    } catch (e) {
      emit(HistoryError('Gagal memuat riwayat: $e'));
    }
  }

  // Fungsi untuk menghapus riwayat dari database Hive.
  Future<void> _onDeleteHistory(DeleteHistory event, Emitter<HistoryState> emit) async {
    try {
      await repository.deleteHistory(event.id);
      // Memuat ulang data setelah penghapusan sukses.
      add(LoadHistory());
    } catch (e) {
      emit(HistoryError('Gagal menghapus riwayat: $e'));
    }
  }
}
