import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:image/image.dart' as img;
import '../../core/constants/app_constants.dart';

class FileStorageService {
  Future<String> get _basePath async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  Future<String> saveOriginal(String id, Uint8List bytes) async {
    final dir = await _ensureDir('originals');
    final path = p.join(dir, '$id.jpg');
    await File(path).writeAsBytes(bytes);
    return path;
  }

  Future<String> saveRestored(String id, Uint8List bytes) async {
    final dir = await _ensureDir('restored');
    final path = p.join(dir, '${id}_restored.jpg');
    await File(path).writeAsBytes(bytes);
    return path;
  }

  Future<String> saveThumbnail(String id, Uint8List imageBytes) async {
    final dir = await _ensureDir('thumbnails');
    final path = p.join(dir, '${id}_thumb.jpg');
    final decoded = img.decodeImage(imageBytes);
    if (decoded != null) {
      final thumb = img.copyResize(decoded, width: AppConstants.thumbnailSize);
      await File(path).writeAsBytes(img.encodeJpg(thumb, quality: 80));
    }
    return path;
  }

  Future<Uint8List?> readFile(String path) async {
    final file = File(path);
    if (await file.exists()) return file.readAsBytes();
    return null;
  }

  Future<void> deleteFile(String path) async {
    final file = File(path);
    if (await file.exists()) await file.delete();
  }

  Future<String> _ensureDir(String sub) async {
    final base = await _basePath;
    final dir = Directory(p.join(base, 'lumina_restore', sub));
    if (!await dir.exists()) await dir.create(recursive: true);
    return dir.path;
  }
}
