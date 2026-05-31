// Kontrak antarmuka untuk repositori album foto.
import '../models/album_entity.dart';

abstract class IAlbumRepository {
  Future<List<AlbumEntity>> getAllAlbums();
  Future<void> saveAlbum(AlbumEntity album);
  Future<void> deleteAlbum(String id);
  // Mengganti nama album yang sudah ada berdasarkan ID.
  Future<void> renameAlbum(String id, String newName);
}
