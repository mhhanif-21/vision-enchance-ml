// BLoC untuk pengaturan aplikasi dengan state yang bersih dan proper.
// Menghilangkan anti-pattern penggunaan field error sebagai pesan sukses.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/settings_entity.dart';
import '../repositories/manage_settings_usecase.dart';

// --- Events ---

abstract class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

class LoadSettings extends SettingsEvent {}

class ToggleTheme extends SettingsEvent {
  final bool isDarkMode;
  const ToggleTheme(this.isDarkMode);

  @override
  List<Object> get props => [isDarkMode];
}

// Event untuk menghapus seluruh riwayat restorasi.
class ClearHistoryCache extends SettingsEvent {}

// Event untuk menghapus seluruh data album.
class ClearAlbumsCache extends SettingsEvent {}

// Event untuk memperbarui kalkulasi penggunaan storage.
class RefreshStorageUsage extends SettingsEvent {}

// --- State ---

class SettingsState extends Equatable {
  final SettingsEntity settings;
  final bool isLoading;
  final String? errorMessage;
  final String? successMessage;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.errorMessage,
    this.successMessage,
  });

  factory SettingsState.initial() {
    return SettingsState(settings: SettingsEntity.initial(), isLoading: true);
  }

  SettingsState copyWith({
    SettingsEntity? settings,
    bool? isLoading,
    String? errorMessage,
    String? successMessage,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      successMessage: successMessage,
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, errorMessage, successMessage];
}

// --- BLoC ---

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ManageSettingsUseCase useCase;

  SettingsBloc({required this.useCase}) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ClearHistoryCache>(_onClearHistoryCache);
    on<ClearAlbumsCache>(_onClearAlbumsCache);
    on<RefreshStorageUsage>(_onRefreshStorageUsage);
  }

  Future<void> _onLoadSettings(
    LoadSettings event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      final settings = await useCase.getSettings();
      emit(state.copyWith(settings: settings, isLoading: false));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal memuat pengaturan: $e', isLoading: false));
    }
  }

  Future<void> _onToggleTheme(ToggleTheme event, Emitter<SettingsState> emit) async {
    try {
      await useCase.toggleDarkMode(event.isDarkMode);
      final updated = state.settings.copyWith(isDarkMode: event.isDarkMode, updatedAt: DateTime.now());
      emit(state.copyWith(settings: updated));
    } catch (e) {
      emit(state.copyWith(errorMessage: 'Gagal mengubah tema: $e'));
    }
  }

  Future<void> _onClearHistoryCache(
    ClearHistoryCache event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await useCase.clearHistory();
      emit(state.copyWith(isLoading: false, successMessage: 'Riwayat berhasil dihapus.'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Gagal menghapus riwayat: $e'));
    }
  }

  Future<void> _onClearAlbumsCache(
    ClearAlbumsCache event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await useCase.clearAlbums();
      emit(state.copyWith(isLoading: false, successMessage: 'Album berhasil dihapus.'));
    } catch (e) {
      emit(state.copyWith(isLoading: false, errorMessage: 'Gagal menghapus album: $e'));
    }
  }

  // Menghitung ulang ukuran folder penyimpanan aplikasi.
  Future<void> _onRefreshStorageUsage(
    RefreshStorageUsage event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      final bytes = await useCase.calculateStorageUsed();
      final updated = state.settings.copyWith(storageUsedBytes: bytes, updatedAt: DateTime.now());
      emit(state.copyWith(settings: updated));
    } catch (_) {
      // Gagal kalkulasi storage bukan error kritis, abaikan saja.
    }
  }
}
