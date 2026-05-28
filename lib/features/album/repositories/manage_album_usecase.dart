// File ini mendefinisikan UseCase untuk mengelola Album.
// BLoC akan memanggil fungsi-fungsi ini alih-alih memanggil repository langsung.

import '../models/album_entity.dart';
import '../repositories/i_album_repository.dart';

class ManageAlbumUseCase {
  final IAlbumRepository repository;

  ManageAlbumUseCase(this.repository);

  // Mengambil semua daftar album
  Future<List<AlbumEntity>> getAllAlbums() {
    return repository.getAllAlbums();
  }

  // Menyimpan album baru atau mengupdate album yang sudah ada
  Future<void> saveAlbum(AlbumEntity album) {
    return repository.saveAlbum(album);
  }

  // Menambahkan foto restorasi ke dalam album
  Future<void> addRestorationToAlbum(String albumId, String restorationId) async {
    final albums = await repository.getAllAlbums();
    final album = albums.firstWhere((a) => a.id == albumId);
    
    // Pastikan tidak ada duplikat ID restorasi
    if (!album.restorationIds.contains(restorationId)) {
      final updatedAlbum = AlbumEntity(
        id: album.id,
        name: album.name,
        restorationIds: [...album.restorationIds, restorationId],
        createdAt: album.createdAt,
        updatedAt: DateTime.now(),
      );
      await repository.saveAlbum(updatedAlbum);
    }
  }

  // Menghapus album
  Future<void> deleteAlbum(String id) {
    return repository.deleteAlbum(id);
  }
}
