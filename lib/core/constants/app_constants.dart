import 'dart:ui';

class AppConstants {
  AppConstants._();

  static const String appName = 'Lumina Restore';
  static const String appVersion = '1.0.0';

  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
  static const int maxFileSizeBytes = 20 * 1024 * 1024; // 20 MB
  static const int maxImageDimension = 4096;
  static const int thumbnailSize = 200;
  static const int jpegQuality = 95;
}
