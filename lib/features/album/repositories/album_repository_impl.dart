// File ini berisi implementasi IAlbumRepository menggunakan Hive.
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/i_album_repository.dart';
import '../models/album_entity.dart';
import '../models/album_model.dart';

class AlbumRepositoryImpl implements IAlbumRepository {
  // Nama box Hive yang digunakan untuk menyimpan album
  static const String boxName = 'albums_box';

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    final box = Hive.box<AlbumModel>(boxName);
    final albums = box.values.toList();
    
    // Mengurutkan album dari yang terbaru dibuat ke yang paling lama
    albums.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return albums.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> saveAlbum(AlbumEntity album) async {
    final box = Hive.box<AlbumModel>(boxName);
    final model = AlbumModel.fromEntity(album);
    await box.put(model.id, model);
  }

  @override
  Future<void> deleteAlbum(String id) async {
    final box = Hive.box<AlbumModel>(boxName);
    await box.delete(id);
  }
}
