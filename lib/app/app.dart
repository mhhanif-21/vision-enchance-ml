/// Mengatur navigasi (Routing) dan Tema Utama aplikasi.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';
import '../features/home/presentation/pages/home_page.dart';
import '../features/restore/presentation/pages/upload_page.dart';
import '../features/restore/presentation/pages/processing_page.dart';
import '../features/restore/presentation/pages/result_page.dart';
import '../features/history/presentation/pages/history_page.dart';
import '../features/album/presentation/pages/album_detail_page.dart';
import '../features/settings/presentation/pages/settings_page.dart';
import '../features/album/domain/entities/album_entity.dart';
import '../services/ml/onnx_inference_service.dart';
import '../core/constants/model_config.dart';

class LuminaRestoreApp extends StatelessWidget {
  const LuminaRestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Lumina Restore',
          theme: AppTheme.lightTheme,
          darkTheme: ThemeData.dark(), // Tema gelap bawaan atau bisa dikustomisasi
          themeMode: state.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
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
    GoRoute(
      path: '/album-detail',
      builder: (context, state) {
        final album = state.extra as AlbumEntity;
        return AlbumDetailPage(album: album);
      },
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);
