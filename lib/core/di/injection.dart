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
import '../../features/album/domain/repositories/i_album_repository.dart';
import '../../features/album/data/repositories/album_repository_impl.dart';
import '../../features/settings/domain/repositories/i_settings_repository.dart';
import '../../features/settings/data/repositories/settings_repository_impl.dart';

// UseCases
import '../../features/history/domain/usecases/manage_history_usecase.dart';
import '../../features/restore/domain/usecases/restore_image_usecase.dart';
import '../../features/album/domain/usecases/manage_album_usecase.dart';
import '../../features/settings/domain/usecases/manage_settings_usecase.dart';

// Blocs
import '../../features/history/presentation/bloc/history_bloc.dart';
import '../../features/restore/presentation/bloc/restore_bloc.dart';
import '../../features/album/presentation/bloc/album_bloc.dart';
import '../../features/settings/presentation/bloc/settings_bloc.dart';

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
  sl.registerLazySingleton<IAlbumRepository>(() => AlbumRepositoryImpl());
  sl.registerLazySingleton<ISettingsRepository>(() => SettingsRepositoryImpl());

  // UseCases
  sl.registerLazySingleton<RestoreImageUseCase>(() => RestoreImageUseCase(sl<IRestoreRepository>()));
  sl.registerLazySingleton<ManageHistoryUseCase>(() => ManageHistoryUseCase(sl<IHistoryRepository>()));
  sl.registerLazySingleton<ManageAlbumUseCase>(() => ManageAlbumUseCase(sl<IAlbumRepository>()));
  sl.registerLazySingleton<ManageSettingsUseCase>(() => ManageSettingsUseCase(sl<ISettingsRepository>()));

  // BLoCs
  sl.registerFactory<RestoreBloc>(() => RestoreBloc(useCase: sl<RestoreImageUseCase>()));
  sl.registerFactory<HistoryBloc>(() => HistoryBloc(useCase: sl<ManageHistoryUseCase>()));
  sl.registerFactory<AlbumBloc>(() => AlbumBloc(useCase: sl<ManageAlbumUseCase>()));
  sl.registerFactory<SettingsBloc>(() => SettingsBloc(useCase: sl<ManageSettingsUseCase>()));
}
