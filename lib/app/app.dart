import 'package:flutter/material.dart';
import 'theme/app_theme.dart';
import '../core/constants/app_constants.dart';
import '../features/home/presentation/pages/home_page.dart';

class LuminaRestoreApp extends StatelessWidget {
  const LuminaRestoreApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const HomePage(),
    );
  }
}
