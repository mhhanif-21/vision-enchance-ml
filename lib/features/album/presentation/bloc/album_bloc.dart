// File ini mendefinisikan BLoC untuk mengelola status (state) dan interaksi data Album.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/album_entity.dart';
import '../../domain/usecases/manage_album_usecase.dart';

// --- Events ---

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object> get props => [];
}

// Event untuk memuat daftar album dari penyimpanan
class LoadAlbums extends AlbumEvent {}

// Event untuk membuat album baru
class CreateAlbum extends AlbumEvent {
  final String name;

  const CreateAlbum(this.name);

  @override
  List<Object> get props => [name];
}

// Event untuk menghapus album
class DeleteAlbum extends AlbumEvent {
  final String id;

  const DeleteAlbum(this.id);

  @override
  List<Object> get props => [id];
}

// Event untuk menambahkan restorasi ke dalam album
class AddRestorationToAlbum extends AlbumEvent {
  final String albumId;
  final String restorationId;

  const AddRestorationToAlbum({
    required this.albumId,
    required this.restorationId,
  });

  @override
  List<Object> get props => [albumId, restorationId];
}

// --- States ---

abstract class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object> get props => [];
}

// State saat data sedang dimuat
class AlbumLoading extends AlbumState {}

// State ketika data berhasil dimuat
class AlbumLoaded extends AlbumState {
  final List<AlbumEntity> albums;

  const AlbumLoaded(this.albums);

  @override
  List<Object> get props => [albums];
}

// State ketika terjadi kesalahan
class AlbumError extends AlbumState {
  final String message;

  const AlbumError(this.message);

  @override
  List<Object> get props => [message];
}

// --- BLoC ---

class AlbumBloc extends Bloc<AlbumEvent, AlbumState> {
  final ManageAlbumUseCase useCase;

  AlbumBloc({required this.useCase}) : super(AlbumLoading()) {
    on<LoadAlbums>(_onLoadAlbums);
    on<CreateAlbum>(_onCreateAlbum);
    on<DeleteAlbum>(_onDeleteAlbum);
    on<AddRestorationToAlbum>(_onAddRestorationToAlbum);
  }

  // Menangani pemuatan data
  Future<void> _onLoadAlbums(LoadAlbums event, Emitter<AlbumState> emit) async {
    emit(AlbumLoading());
    try {
      final albums = await useCase.getAllAlbums();
      emit(AlbumLoaded(albums));
    } catch (e) {
      emit(AlbumError('Gagal memuat album: $e'));
    }
  }

  // Menangani pembuatan album baru
  Future<void> _onCreateAlbum(CreateAlbum event, Emitter<AlbumState> emit) async {
    try {
      final newAlbum = AlbumEntity(
        id: const Uuid().v4(),
        name: event.name,
        restorationIds: const [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      await useCase.saveAlbum(newAlbum);
      add(LoadAlbums());
    } catch (e) {
      emit(AlbumError('Gagal membuat album: $e'));
    }
  }

  // Menangani penghapusan album
  Future<void> _onDeleteAlbum(DeleteAlbum event, Emitter<AlbumState> emit) async {
    try {
      await useCase.deleteAlbum(event.id);
      add(LoadAlbums());
    } catch (e) {
      emit(AlbumError('Gagal menghapus album: $e'));
    }
  }

  // Menambahkan riwayat restorasi ke dalam album tertentu
  Future<void> _onAddRestorationToAlbum(
    AddRestorationToAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    try {
      await useCase.addRestorationToAlbum(event.albumId, event.restorationId);
      add(LoadAlbums());
    } catch (e) {
      emit(AlbumError('Gagal menambahkan gambar ke album: $e'));
    }
  }
}
