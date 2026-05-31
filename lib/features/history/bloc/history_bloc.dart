// BLoC untuk riwayat restorasi dengan dukungan filter berdasarkan jenis model.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/restoration_entity.dart';
import '../repositories/manage_history_usecase.dart';

// --- Events ---

abstract class HistoryEvent extends Equatable {
  const HistoryEvent();

  @override
  List<Object> get props => [];
}

class LoadHistory extends HistoryEvent {}

class DeleteHistory extends HistoryEvent {
  final String id;
  const DeleteHistory(this.id);

  @override
  List<Object> get props => [id];
}

// Event untuk menghapus banyak riwayat sekaligus (bulk delete).
class DeleteMultipleHistory extends HistoryEvent {
  final List<String> ids;
  const DeleteMultipleHistory(this.ids);

  @override
  List<Object> get props => [ids];
}

class SaveHistory extends HistoryEvent {
  final RestorationEntity restoration;
  const SaveHistory(this.restoration);

  @override
  List<Object> get props => [restoration];
}

// Event untuk memfilter riwayat berdasarkan tipe model (null = tampilkan semua).
class FilterHistory extends HistoryEvent {
  final String? modelTypeFilter;
  const FilterHistory(this.modelTypeFilter);

  @override
  List<Object> get props => [modelTypeFilter ?? ''];
}

// --- States ---

abstract class HistoryState extends Equatable {
  const HistoryState();

  @override
  List<Object> get props => [];
}

class HistoryLoading extends HistoryState {}

class HistoryLoaded extends HistoryState {
  final List<RestorationEntity> allItems;
  final List<RestorationEntity> filteredItems;
  final String? activeFilter;

  const HistoryLoaded({
    required this.allItems,
    required this.filteredItems,
    this.activeFilter,
  });

  @override
  List<Object> get props => [allItems, filteredItems, activeFilter ?? ''];
}

class HistoryError extends HistoryState {
  final String message;
  const HistoryError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BLoC ---

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final ManageHistoryUseCase useCase;

  HistoryBloc({required this.useCase}) : super(HistoryLoading()) {
    on<LoadHistory>(_onLoadHistory);
    on<SaveHistory>(_onSaveHistory);
    on<DeleteHistory>(_onDeleteHistory);
    on<DeleteMultipleHistory>(_onDeleteMultipleHistory);
    on<FilterHistory>(_onFilterHistory);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(HistoryLoading());
    try {
      final history = await useCase.getAllHistory();
      emit(HistoryLoaded(allItems: history, filteredItems: history));
    } catch (e) {
      emit(HistoryError('Gagal memuat riwayat: $e'));
    }
  }

  Future<void> _onSaveHistory(SaveHistory event, Emitter<HistoryState> emit) async {
    try {
      await useCase.saveRestoration(event.restoration);
      add(LoadHistory());
    } catch (e) {
      emit(HistoryError('Gagal menyimpan riwayat: $e'));
    }
  }

  Future<void> _onDeleteHistory(DeleteHistory event, Emitter<HistoryState> emit) async {
    try {
      await useCase.deleteHistory(event.id);
      add(LoadHistory());
    } catch (e) {
      emit(HistoryError('Gagal menghapus riwayat: $e'));
    }
  }

  // Menghapus banyak item sekaligus lalu memuat ulang daftar.
  Future<void> _onDeleteMultipleHistory(
    DeleteMultipleHistory event,
    Emitter<HistoryState> emit,
  ) async {
    try {
      await useCase.deleteMultipleHistory(event.ids);
      add(LoadHistory());
    } catch (e) {
      emit(HistoryError('Gagal menghapus riwayat: $e'));
    }
  }

  // Memfilter daftar riwayat secara lokal berdasarkan tipe model tanpa re-fetch.
  void _onFilterHistory(FilterHistory event, Emitter<HistoryState> emit) {
    final current = state;
    if (current is! HistoryLoaded) return;

    final filtered = event.modelTypeFilter == null
        ? current.allItems
        : current.allItems
            .where((e) => e.modelType == event.modelTypeFilter)
            .toList();

    emit(HistoryLoaded(
      allItems: current.allItems,
      filteredItems: filtered,
      activeFilter: event.modelTypeFilter,
    ));
  }
}
