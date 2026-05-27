import 'package:get_it/get_it.dart';
import '../../services/ml/model_manager.dart';
import '../../services/ml/image_preprocessor.dart';
import '../../services/ml/image_postprocessor.dart';
import '../../services/ml/onnx_inference_service.dart';
import '../../services/storage/file_storage_service.dart';

// Repositories
import '../../features/history/domain/repositories/i_history_repository.dart';
import '../../features/history/data/repositories/history_repository_impl.dart';
import '../../features/restore/domain/repositories/i_restore_repository.dart';

// UseCases
import '../../features/history/domain/usecases/manage_history_usecase.dart';
import '../../features/restore/domain/usecases/restore_image_usecase.dart';

// Blocs
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/restore/presentation/bloc/restore_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ML Services
  sl.registerLazySingleton<ModelManager>(() => ModelManager());
  sl.registerLazySingleton<ImagePreprocessor>(() => ImagePreprocessor());
  sl.registerLazySingleton<ImagePostprocessor>(() => ImagePostprocessor());
  sl.registerLazySingleton<IRestoreRepository>(
    () => OnnxInferenceService(
      modelManager: sl<ModelManager>(),
      preprocessor: sl<ImagePreprocessor>(),
      postprocessor: sl<ImagePostprocessor>(),
    ),
  );

  // Storage Services
  sl.registerLazySingleton<FileStorageService>(() => FileStorageService());

  // Repositories
  sl.registerLazySingleton<IHistoryRepository>(() => HistoryRepositoryImpl());

  // UseCases
  sl.registerLazySingleton<RestoreImageUseCase>(() => RestoreImageUseCase(sl<IRestoreRepository>()));
  sl.registerLazySingleton<ManageHistoryUseCase>(() => ManageHistoryUseCase(sl<IHistoryRepository>()));

  // BLoCs
  sl.registerFactory<RestoreBloc>(() => RestoreBloc(useCase: sl<RestoreImageUseCase>()));
  sl.registerFactory<HistoryBloc>(() => HistoryBloc(useCase: sl<ManageHistoryUseCase>()));
}
