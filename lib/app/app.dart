/// Mengatur navigasi (Routing) dan Tema Utama aplikasi.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'theme/app_theme.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/restore/presentation/pages/upload_page.dart';
import '../features/restore/presentation/pages/processing_page.dart';
import '../features/restore/presentation/pages/result_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../services/ml/onnx_inference_service.dart';
import '../core/constants/model_config.dart';

class LuminaRestoreApp extends StatelessWidget {
  const LuminaRestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Lumina Restore',
      theme: AppTheme.lightTheme,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// Konfigurasi GoRouter untuk menangani perpindahan halaman
final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/upload',
      builder: (context, state) {
        final modelType = state.extra as ModelType;
        return UploadPage(modelType: modelType);
      },
    ),
    GoRoute(
      path: '/processing',
      builder: (context, state) {
        final data = state.extra as Map<String, dynamic>;
        return ProcessingPage(
          imagePath: data['imagePath'] as String,
          modelType: data['modelType'] as ModelType,
        );
      },
    ),
    GoRoute(
      path: '/result',
      builder: (context, state) {
        final result = state.extra as RestorationResult;
        return ResultPage(result: result);
      },
    ),
    GoRoute(
      path: '/history',
      builder: (context, state) => const HistoryPage(),
    ),
  ],
);
