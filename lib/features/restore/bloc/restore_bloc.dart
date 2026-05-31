// BLoC untuk mengorkestrasi alur restorasi foto secara bertahap.
// Mengelola state: initial → preprocessing → inferencing → postprocessing → success/failure.
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/restoration_result.dart';
import '../repositories/restore_image_usecase.dart';
import '../../../../core/constants/model_config.dart';

// Tahapan proses restorasi yang digunakan untuk menampilkan progress di UI.
enum RestorationStep { preprocessing, inferencing, postprocessing }

// --- Events ---

abstract class RestoreEvent extends Equatable {
  const RestoreEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memulai proses restorasi foto dengan model AI tertentu.
class StartRestoration extends RestoreEvent {
  final Uint8List imageBytes;
  final ModelType modelType;

  const StartRestoration({
    required this.imageBytes,
    required this.modelType,
  });

  @override
  List<Object> get props => [imageBytes, modelType];
}

// Event untuk membatalkan proses restorasi yang sedang berjalan.
class CancelRestoration extends RestoreEvent {}

// Event untuk mereset BLoC ke state awal.
class ResetRestoration extends RestoreEvent {}

// --- States ---

abstract class RestoreState extends Equatable {
  const RestoreState();

  @override
  List<Object> get props => [];
}

// State awal sebelum ada proses yang dimulai.
class RestoreInitial extends RestoreState {}

// State saat proses sedang berjalan, dengan informasi tahap aktif.
class RestoreProcessing extends RestoreState {
  final RestorationStep step;

  const RestoreProcessing(this.step);

  @override
  List<Object> get props => [step];
}

// State ketika proses selesai dan hasil tersedia.
class RestoreSuccess extends RestoreState {
  final RestorationResult result;

  const RestoreSuccess(this.result);

  @override
  List<Object> get props => [result];
}

// State ketika proses gagal disertai pesan error yang informatif.
class RestoreFailure extends RestoreState {
  final String errorMessage;

  const RestoreFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

// State ketika pengguna membatalkan proses sebelum selesai.
class RestoreCancelled extends RestoreState {}

// --- BLoC ---

class RestoreBloc extends Bloc<RestoreEvent, RestoreState> {
  final RestoreImageUseCase useCase;

  // Flag untuk menandai pembatalan proses secara kooperatif.
  bool _isCancelled = false;

  RestoreBloc({required this.useCase}) : super(RestoreInitial()) {
    on<StartRestoration>(_onStartRestoration);
    on<CancelRestoration>(_onCancelRestoration);
    on<ResetRestoration>(_onResetRestoration);
  }

  // Mengorkestrasi 3 tahap proses restorasi dengan update progress di setiap transisi.
  Future<void> _onStartRestoration(
    StartRestoration event,
    Emitter<RestoreState> emit,
  ) async {
    _isCancelled = false;

    try {
      // Tahap 1: pra-proses (cepat, di main thread).
      emit(const RestoreProcessing(RestorationStep.preprocessing));
      if (_isCancelled) { emit(RestoreCancelled()); return; }

      // Tahap 2: inferensi AI (berat, di background isolate via compute).
      emit(const RestoreProcessing(RestorationStep.inferencing));
      if (_isCancelled) { emit(RestoreCancelled()); return; }

      final result = await useCase.execute(
        event.imageBytes,
        event.modelType,
        onStepChanged: (step) {
          // Callback dipanggil dari dalam use case saat tahap berubah.
          if (!_isCancelled && !emit.isDone) {
            emit(RestoreProcessing(step));
          }
        },
      );

      if (_isCancelled) { emit(RestoreCancelled()); return; }

      // Tahap 3: pasca-proses selesai, emit hasil.
      emit(RestoreSuccess(result));
    } catch (e) {
      emit(RestoreFailure('Proses restorasi gagal: $e'));
    }
  }

  // Menandai proses sebagai dibatalkan agar loop inferensi kooperatif berhenti.
  void _onCancelRestoration(
    CancelRestoration event,
    Emitter<RestoreState> emit,
  ) {
    _isCancelled = true;
  }

  // Mereset BLoC ke state awal dan membersihkan flag pembatalan.
  void _onResetRestoration(ResetRestoration event, Emitter<RestoreState> emit) {
    _isCancelled = false;
    emit(RestoreInitial());
  }
}
