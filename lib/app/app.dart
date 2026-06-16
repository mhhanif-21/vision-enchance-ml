// Konfigurasi routing dan tema utama aplikasi Lumina Restore.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme/app_theme.dart';
import '../features/settings/bloc/settings_bloc.dart';
import '../features/home/ui/home_page.dart';
import '../features/restore/ui/upload_page.dart';
import '../features/restore/ui/processing_page.dart';
import '../features/restore/ui/result_page.dart';
import '../features/restore/ui/restoration_detail_page.dart';
import '../features/history/ui/history_page.dart';
import '../features/album/ui/album_detail_page.dart';
import '../features/settings/ui/settings_page.dart';
import '../features/album/models/album_entity.dart';
import '../core/constants/model_config.dart';
import '../features/restore/models/restoration_result.dart';
import '../features/history/models/restoration_entity.dart';

class LuminaRestoreApp extends StatelessWidget {
  const LuminaRestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        return MaterialApp.router(
          title: 'Lumina Restore',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: state.settings.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          locale: const Locale('en', 'US'),
          supportedLocales: const [Locale('en', 'US')],
          routerConfig: _router,
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}

// Router terpusat dengan typed extra parameters untuk keamanan tipe data.
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
      path: '/restoration-detail',
      builder: (context, state) {
        final entity = state.extra as RestorationEntity;
        return RestorationDetailPage(entity: entity);
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
