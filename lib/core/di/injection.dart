import 'package:get_it/get_it.dart';
import '../../services/ml/model_manager.dart';
import '../../services/ml/image_preprocessor.dart';
import '../../services/ml/image_postprocessor.dart';
import '../../services/ml/onnx_inference_service.dart';
import '../../services/storage/file_storage_service.dart';

// Repositories
import '../../features/history/repositories/i_history_repository.dart';
import '../../features/history/repositories/history_repository_impl.dart';
import '../../features/restore/repositories/i_restore_repository.dart';
import '../../features/album/repositories/i_album_repository.dart';
import '../../features/album/repositories/album_repository_impl.dart';
import '../../features/settings/repositories/i_settings_repository.dart';
import '../../features/settings/repositories/settings_repository_impl.dart';

// UseCases
import '../../features/history/repositories/manage_history_usecase.dart';
import '../../features/restore/repositories/restore_image_usecase.dart';
import '../../features/album/repositories/manage_album_usecase.dart';
import '../../features/settings/repositories/manage_settings_usecase.dart';

// Blocs
import '../../features/history/bloc/history_bloc.dart';
import '../../features/restore/bloc/restore_bloc.dart';
import '../../features/album/bloc/album_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';

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
