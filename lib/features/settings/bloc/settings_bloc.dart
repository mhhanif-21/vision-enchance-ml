// File ini mengatur state konfigurasi (tema) dan cache aplikasi.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/settings_entity.dart';
import '../../repositories/manage_settings_usecase.dart';

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

class ClearAppCache extends SettingsEvent {}

// --- States ---

class SettingsState extends Equatable {
  final SettingsEntity settings;
  final bool isLoading;
  final String? error;

  const SettingsState({
    required this.settings,
    this.isLoading = false,
    this.error,
  });

  factory SettingsState.initial() {
    return SettingsState(
      settings: SettingsEntity.initial(),
      isLoading: true,
    );
  }

  SettingsState copyWith({
    SettingsEntity? settings,
    bool? isLoading,
    String? error,
  }) {
    return SettingsState(
      settings: settings ?? this.settings,
      isLoading: isLoading ?? this.isLoading,
      error: error, // Error tidak di-copy secara default
    );
  }

  @override
  List<Object?> get props => [settings, isLoading, error];
}

// --- BLoC ---

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final ManageSettingsUseCase useCase;

  SettingsBloc({required this.useCase}) : super(SettingsState.initial()) {
    on<LoadSettings>(_onLoadSettings);
    on<ToggleTheme>(_onToggleTheme);
    on<ClearAppCache>(_onClearAppCache);
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
      emit(state.copyWith(error: 'Gagal memuat pengaturan: $e', isLoading: false));
    }
  }

  Future<void> _onToggleTheme(
    ToggleTheme event,
    Emitter<SettingsState> emit,
  ) async {
    try {
      await useCase.toggleDarkMode(event.isDarkMode);
      // Memperbarui state secara langsung agar UI segera berubah
      final newSettings = state.settings.copyWith(
        isDarkMode: event.isDarkMode,
        updatedAt: DateTime.now(),
      );
      emit(state.copyWith(settings: newSettings));
    } catch (e) {
      emit(state.copyWith(error: 'Gagal mengubah tema: $e'));
    }
  }

  Future<void> _onClearAppCache(
    ClearAppCache event,
    Emitter<SettingsState> emit,
  ) async {
    emit(state.copyWith(isLoading: true));
    try {
      await useCase.clearHistory();
      await useCase.clearAlbums();
      // Reload pengaturan kembali
      final settings = await useCase.getSettings();
      emit(state.copyWith(
        settings: settings,
        isLoading: false,
        error: 'Data Cache berhasil dihapus', // Menjadikan error string sbg notifikasi sukses (hack simpel)
      ));
    } catch (e) {
      emit(state.copyWith(error: 'Gagal menghapus data cache: $e', isLoading: false));
    }
  }
}
