// File ini mendefinisikan kontrak repositori untuk modul Album.
// Implementasinya akan berada di layer data (Hive).

import '../models/album_entity.dart';

abstract class IAlbumRepository {
  // Mengambil semua album pengguna
  Future<List<AlbumEntity>> getAllAlbums();
  
  // Membuat album baru atau memperbarui yang sudah ada
  Future<void> saveAlbum(AlbumEntity album);
  
  // Menghapus album berdasarkan ID
  Future<void> deleteAlbum(String id);
}
