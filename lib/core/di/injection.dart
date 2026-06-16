// Konfigurasi dependency injection menggunakan GetIt sebagai service locator.
// Seluruh dependensi didaftarkan di sini agar mudah diuji dan diganti.
import 'package:get_it/get_it.dart';

// Services
import '../../services/ml/image_preprocessor.dart';
import '../../services/ml/image_postprocessor.dart';
import '../../services/ml/onnx_inference_service.dart';
import '../../services/storage/file_storage_service.dart';

// Repositories & interfaces
import '../../features/history/repositories/i_history_repository.dart';
import '../../features/history/repositories/history_repository_impl.dart';
import '../../features/restore/repositories/i_restore_repository.dart';
import '../../features/settings/repositories/i_settings_repository.dart';
import '../../features/settings/repositories/settings_repository_impl.dart';

// UseCases
import '../../features/history/repositories/manage_history_usecase.dart';
import '../../features/restore/repositories/restore_image_usecase.dart';
import '../../features/restore/repositories/save_restoration_usecase.dart';
import '../../features/settings/repositories/manage_settings_usecase.dart';

// BLoCs
import '../../features/history/bloc/history_bloc.dart';
import '../../features/restore/bloc/restore_bloc.dart';
import '../../features/settings/bloc/settings_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // ML Services (singleton karena stateless).
  sl.registerLazySingleton<ImagePreprocessor>(() => ImagePreprocessor());
  sl.registerLazySingleton<ImagePostprocessor>(() => ImagePostprocessor());
  sl.registerLazySingleton<IRestoreRepository>(
    () => OnnxInferenceService(
      preprocessor: sl<ImagePreprocessor>(),
      postprocessor: sl<ImagePostprocessor>(),
    ),
  );

  // Storage service (singleton karena hanya kelola path).
  sl.registerLazySingleton<FileStorageService>(() => FileStorageService());

  // Repositories (singleton karena stateless, hanya akses database).
  sl.registerLazySingleton<IHistoryRepository>(() => HistoryRepositoryImpl());
  sl.registerLazySingleton<ISettingsRepository>(() => SettingsRepositoryImpl());

  // UseCases (singleton karena stateless).
  sl.registerLazySingleton<RestoreImageUseCase>(() => RestoreImageUseCase(sl<IRestoreRepository>()));
  sl.registerLazySingleton<SaveRestorationUseCase>(() => SaveRestorationUseCase(
        storageService: sl<FileStorageService>(),
        historyRepository: sl<IHistoryRepository>(),
      ));
  sl.registerLazySingleton<ManageHistoryUseCase>(() => ManageHistoryUseCase(sl<IHistoryRepository>()));
  sl.registerLazySingleton<ManageSettingsUseCase>(() => ManageSettingsUseCase(sl<ISettingsRepository>()));

  // BLoCs (factory karena perlu instance baru setiap dipakai).
  sl.registerFactory<RestoreBloc>(() => RestoreBloc(useCase: sl<RestoreImageUseCase>()));
  sl.registerFactory<HistoryBloc>(() => HistoryBloc(useCase: sl<ManageHistoryUseCase>()));
  sl.registerFactory<SettingsBloc>(() => SettingsBloc(useCase: sl<ManageSettingsUseCase>()));
}
