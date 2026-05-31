// Model data Hive untuk Album foto restorasi.
// Field baru coverImagePath ditambahkan di index 5 dengan backward compatibility.
import 'package:hive/hive.dart';
import '../models/album_entity.dart';

part 'album_model.g.dart';

@HiveType(typeId: 1)
class AlbumModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final List<String> restorationIds;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  final DateTime updatedAt;

  // Field baru: path gambar sampul album (nullable).
  @HiveField(5)
  final String? coverImagePath;

  AlbumModel({
    required this.id,
    required this.name,
    required this.restorationIds,
    required this.createdAt,
    required this.updatedAt,
    this.coverImagePath,
  });

  // Mengonversi AlbumModel menjadi AlbumEntity.
  AlbumEntity toEntity() {
    return AlbumEntity(
      id: id,
      name: name,
      restorationIds: restorationIds,
      coverImagePath: coverImagePath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  // Membuat AlbumModel dari AlbumEntity.
  factory AlbumModel.fromEntity(AlbumEntity entity) {
    return AlbumModel(
      id: entity.id,
      name: entity.name,
      restorationIds: entity.restorationIds,
      coverImagePath: entity.coverImagePath,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }
}
