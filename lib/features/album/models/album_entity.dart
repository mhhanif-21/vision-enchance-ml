// File ini mendefinisikan entitas Album.
// Digunakan untuk mengelompokkan riwayat restorasi pengguna.

class AlbumEntity {
  // ID unik untuk setiap album
  final String id;
  
  // Nama album
  final String name;
  
  // Daftar ID restorasi yang ada di dalam album ini
  final List<String> restorationIds;
  
  // Waktu pembuatan album
  final DateTime createdAt;
  
  // Waktu terakhir album diperbarui
  final DateTime updatedAt;

  const AlbumEntity({
    required this.id,
    required this.name,
    required this.restorationIds,
    required this.createdAt,
    required this.updatedAt,
  });
}
