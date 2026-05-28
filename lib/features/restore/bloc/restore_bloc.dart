/// File ini berisi logika BLoC untuk proses restorasi foto.
/// Menangani event dari UI untuk memulai proses AI, dan mengelola state proses (loading/sukses/gagal).
import 'dart:typed_data';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../models/restoration_result.dart';
import '../../repositories/restore_image_usecase.dart';
import '../../../../core/constants/model_config.dart';

// --- Events ---

abstract class RestoreEvent extends Equatable {
  const RestoreEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memulai pemrosesan inferensi ML pada sebuah gambar.
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

// Event untuk mereset kondisi layar kembali ke awal sebelum ada gambar yang diproses.
class ResetRestoration extends RestoreEvent {}

// --- States ---

abstract class RestoreState extends Equatable {
  const RestoreState();

  @override
  List<Object> get props => [];
}

// State awal: Belum ada pemrosesan.
class RestoreInitial extends RestoreState {}

// State pemrosesan: Menampilkan animasi loading dan progress di UI.
class RestoreProcessing extends RestoreState {}

// State berhasil: Inferensi selesai dan mengembalikan objek RestorationResult.
class RestoreSuccess extends RestoreState {
  final RestorationResult result;

  const RestoreSuccess(this.result);

  @override
  List<Object> get props => [result];
}

// State gagal: Terjadi error, model tidak dapat diload, atau kehabisan memori.
class RestoreFailure extends RestoreState {
  final String errorMessage;

  const RestoreFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

// --- BLoC ---

class RestoreBloc extends Bloc<RestoreEvent, RestoreState> {
  final RestoreImageUseCase useCase;

  RestoreBloc({required this.useCase}) : super(RestoreInitial()) {
    // Mendaftarkan event untuk memulai proses restorasi.
    on<StartRestoration>(_onStartRestoration);
    
    // Mendaftarkan event untuk mereset BLoC state.
    on<ResetRestoration>(_onResetRestoration);
  }

  // Menjalankan proses inferensi ONNX pada foto melalui UseCase.
  Future<void> _onStartRestoration(
    StartRestoration event,
    Emitter<RestoreState> emit,
  ) async {
    emit(RestoreProcessing());
    
    try {
      final result = await useCase.execute(
        event.imageBytes,
        event.modelType,
      );
      emit(RestoreSuccess(result));
    } catch (e) {
      emit(RestoreFailure('Proses restorasi gagal: $e'));
    }
  }

  // Mengembalikan state aplikasi ke mode pilih foto.
  void _onResetRestoration(ResetRestoration event, Emitter<RestoreState> emit) {
    emit(RestoreInitial());
  }
}
