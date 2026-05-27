/// Entry point aplikasi Lumina Restore.
/// Menginisialisasi service, repository, dan BLoC Provider sebelum UI dijalankan.
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'core/storage/hive_setup.dart';
import 'features/history/data/repositories/history_repository_impl.dart';
import 'services/ml/onnx_inference_service.dart';
import 'services/ml/model_manager.dart';
import 'services/ml/image_preprocessor.dart';
import 'services/ml/image_postprocessor.dart';
import 'services/ml/tile_processor.dart';
import 'features/history/presentation/bloc/history_bloc.dart';
import 'features/restore/presentation/bloc/restore_bloc.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Menginisialisasi penyimpanan lokal (Hive)
  await HiveSetup.init();
  
  // Menginisialisasi service ML
  final modelManager = ModelManager();
  final preprocessor = ImagePreprocessor();
  final postprocessor = ImagePostprocessor();
  final tileProcessor = TileProcessor();
  
  final onnxService = OnnxInferenceService(
    modelManager: modelManager,
    preprocessor: preprocessor,
    postprocessor: postprocessor,
    tileProcessor: tileProcessor,
  );

  final historyRepo = HistoryRepositoryImpl();

  // Menjalankan aplikasi dengan MultiBlocProvider agar state dapat diakses secara global
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (_) => HistoryBloc(repository: historyRepo)..add(LoadHistory()),
        ),
        BlocProvider(
          create: (_) => RestoreBloc(inferenceService: onnxService),
        ),
      ],
      child: const LuminaRestoreApp(),
    ),
  );
}
