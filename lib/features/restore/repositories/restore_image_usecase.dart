// Use case sebagai perantara antara RestoreBloc dan IRestoreRepository.
// Meneruskan callback progress agar BLoC dapat memperbarui UI secara bertahap.
import 'dart:typed_data';
import '../../../../core/constants/model_config.dart';
import '../repositories/i_restore_repository.dart';
import '../models/restoration_result.dart';
import '../../restore/bloc/restore_bloc.dart';

class RestoreImageUseCase {
  final IRestoreRepository repository;

  RestoreImageUseCase(this.repository);

  // Menjalankan restorasi dan meneruskan callback tahap ke repository.
  Future<RestorationResult> execute(
    Uint8List imageBytes,
    ModelType modelType, {
    void Function(RestorationStep step)? onStepChanged,
  }) {
    return repository.restoreImage(
      imageBytes,
      modelType,
      onStepChanged: onStepChanged,
    );
  }
}
