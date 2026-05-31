// Use case untuk seluruh operasi Album: CRUD dan manajemen foto di dalam album.
import '../models/album_entity.dart';
import '../repositories/i_album_repository.dart';

class ManageAlbumUseCase {
  final IAlbumRepository repository;

  ManageAlbumUseCase(this.repository);

  Future<List<AlbumEntity>> getAllAlbums() => repository.getAllAlbums();
  Future<void> saveAlbum(AlbumEntity album) => repository.saveAlbum(album);
  Future<void> deleteAlbum(String id) => repository.deleteAlbum(id);
  Future<void> renameAlbum(String id, String newName) => repository.renameAlbum(id, newName);

  // Menambahkan restorasi ke album dengan pengecekan duplikat dan update cover.
  Future<void> addRestorationToAlbum(
    String albumId,
    String restorationId,
    String thumbnailPath,
  ) async {
    final albums = await repository.getAllAlbums();
    final album = albums.firstWhere((a) => a.id == albumId);

    if (album.restorationIds.contains(restorationId)) return;

    final updated = AlbumEntity(
      id: album.id,
      name: album.name,
      restorationIds: [...album.restorationIds, restorationId],
      // Gunakan thumbnail sebagai cover jika belum ada cover.
      coverImagePath: album.coverImagePath ?? thumbnailPath,
      createdAt: album.createdAt,
      updatedAt: DateTime.now(),
    );
    await repository.saveAlbum(updated);
  }
}
