// Entitas domain untuk Album foto restorasi.
// Menyimpan daftar ID restorasi dan path gambar sampul untuk tampilan grid.

class AlbumEntity {
  final String id;
  final String name;
  final List<String> restorationIds;
  final String? coverImagePath;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AlbumEntity({
    required this.id,
    required this.name,
    required this.restorationIds,
    this.coverImagePath,
    required this.createdAt,
    required this.updatedAt,
  });
}
