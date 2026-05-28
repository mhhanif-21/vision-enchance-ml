// File ini mendefinisikan UseCase untuk memproses restorasi gambar.
// BLoC memanggil UseCase ini untuk menjalankan logika AI melalui IRestoreRepository.
import 'dart:typed_data';
import '../../../../core/constants/model_config.dart';
import '../repositories/i_restore_repository.dart';
import '../models/restoration_result.dart';

class RestoreImageUseCase {
  final IRestoreRepository repository;

  RestoreImageUseCase(this.repository);

  // Fungsi utama untuk memproses restorasi gambar berdasarkan tipe model
  Future<RestorationResult> execute(Uint8List imageBytes, ModelType modelType) {
    return repository.restoreImage(imageBytes, modelType);
  }
}
