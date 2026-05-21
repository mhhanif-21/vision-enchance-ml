import 'dart:io';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../services/ml/onnx_inference_service.dart';
import 'restore_event.dart';
import 'restore_state.dart';

class RestoreBloc extends Bloc<RestoreEvent, RestoreState> {
  final OnnxInferenceService _inferenceService;
  String? _selectedImagePath;
  ModelType? _selectedModelType;

  RestoreBloc({required OnnxInferenceService inferenceService})
      : _inferenceService = inferenceService,
        super(const RestoreInitial()) {
    on<RestoreImageSelected>(_onImageSelected);
    on<RestoreStarted>(_onStarted);
    on<RestoreCancelled>(_onCancelled);
    on<RestoreReset>(_onReset);
  }

  void _onImageSelected(RestoreImageSelected event, Emitter<RestoreState> emit) {
    _selectedImagePath = event.imagePath;
    _selectedModelType = event.modelType;
    emit(RestoreImageReady(imagePath: event.imagePath, modelType: event.modelType));
  }

  Future<void> _onStarted(RestoreStarted event, Emitter<RestoreState> emit) async {
    if (_selectedImagePath == null || _selectedModelType == null) return;

    try {
      emit(const RestoreProcessing(
        phase: RestorePhase.preprocessing,
        message: 'Mempersiapkan gambar...',
      ));

      final imageBytes = await File(_selectedImagePath!).readAsBytes();

      emit(const RestoreProcessing(
        phase: RestorePhase.inference,
        message: 'Menjalankan AI...',
      ));

      final result = await _inferenceService.restore(
        imageBytes: imageBytes,
        modelType: _selectedModelType!,
      );

      emit(const RestoreProcessing(
        phase: RestorePhase.postprocessing,
        message: 'Menyimpan hasil...',
      ));

      emit(RestoreSuccess(
        originalBytes: result.originalBytes,
        restoredBytes: result.restoredBytes,
        modelType: _selectedModelType!,
        processingTimeMs: result.processingTimeMs,
        inputWidth: result.inputWidth,
        inputHeight: result.inputHeight,
      ));
    } on InsufficientMemoryException {
      emit(const RestoreFailure(
        message: 'Memori tidak cukup. Tutup aplikasi lain dan coba lagi.',
        actionLabel: 'Coba Lagi',
      ));
    } on ModelLoadException {
      emit(const RestoreFailure(
        message: 'Gagal memuat model AI. Pastikan aplikasi terinstal dengan benar.',
      ));
    } on ImageProcessingException {
      emit(const RestoreFailure(
        message: 'Format gambar tidak didukung atau file rusak.',
        actionLabel: 'Pilih Foto Lain',
      ));
    } on InferenceException {
      emit(const RestoreFailure(
        message: 'Terjadi kesalahan saat memproses foto. Silakan coba lagi.',
        actionLabel: 'Coba Lagi',
      ));
    } catch (e) {
      emit(RestoreFailure(
        message: 'Terjadi kesalahan tak terduga: $e',
        actionLabel: 'Kembali',
      ));
    }
  }

  void _onCancelled(RestoreCancelled event, Emitter<RestoreState> emit) {
    if (_selectedImagePath != null && _selectedModelType != null) {
      emit(RestoreImageReady(
        imagePath: _selectedImagePath!,
        modelType: _selectedModelType!,
      ));
    } else {
      emit(const RestoreInitial());
    }
  }

  void _onReset(RestoreReset event, Emitter<RestoreState> emit) {
    _selectedImagePath = null;
    _selectedModelType = null;
    emit(const RestoreInitial());
  }
}
