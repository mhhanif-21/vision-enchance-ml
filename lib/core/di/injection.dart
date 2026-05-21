import 'package:get_it/get_it.dart';
import '../../services/ml/model_manager.dart';
import '../../services/ml/image_preprocessor.dart';
import '../../services/ml/image_postprocessor.dart';
import '../../services/ml/onnx_inference_service.dart';
import '../../services/ml/tile_processor.dart';
import '../../services/storage/file_storage_service.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ML Services
  sl.registerLazySingleton<ModelManager>(() => ModelManager());
  sl.registerLazySingleton<ImagePreprocessor>(() => ImagePreprocessor());
  sl.registerLazySingleton<ImagePostprocessor>(() => ImagePostprocessor());
  sl.registerLazySingleton<TileProcessor>(() => TileProcessor());
  sl.registerLazySingleton<OnnxInferenceService>(
    () => OnnxInferenceService(
      modelManager: sl<ModelManager>(),
      preprocessor: sl<ImagePreprocessor>(),
      postprocessor: sl<ImagePostprocessor>(),
      tileProcessor: sl<TileProcessor>(),
    ),
  );

  // Storage
  sl.registerLazySingleton<FileStorageService>(() => FileStorageService());
}
