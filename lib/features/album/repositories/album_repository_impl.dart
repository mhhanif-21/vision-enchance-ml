// Implementasi IAlbumRepository menggunakan Hive sebagai penyimpanan lokal.
import 'package:hive_flutter/hive_flutter.dart';
import '../repositories/i_album_repository.dart';
import '../models/album_entity.dart';
import '../models/album_model.dart';

class AlbumRepositoryImpl implements IAlbumRepository {
  static const String boxName = 'albums_box';

  @override
  Future<List<AlbumEntity>> getAllAlbums() async {
    final box = Hive.box<AlbumModel>(boxName);
    final albums = box.values.toList();
    // Urutkan dari album terbaru ke terlama.
    albums.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return albums.map((m) => m.toEntity()).toList();
  }

  @override
  Future<void> saveAlbum(AlbumEntity album) async {
    final box = Hive.box<AlbumModel>(boxName);
    await box.put(album.id, AlbumModel.fromEntity(album));
  }

  @override
  Future<void> deleteAlbum(String id) async {
    final box = Hive.box<AlbumModel>(boxName);
    await box.delete(id);
  }

  @override
  Future<void> renameAlbum(String id, String newName) async {
    final box = Hive.box<AlbumModel>(boxName);
    final existing = box.get(id);
    if (existing == null) return;

    // Simpan ulang album dengan nama baru, semua field lain tetap sama.
    final updated = AlbumModel(
      id: existing.id,
      name: newName,
      restorationIds: existing.restorationIds,
      coverImagePath: existing.coverImagePath,
      createdAt: existing.createdAt,
      updatedAt: DateTime.now(),
    );
    await box.put(id, updated);
  }
}
