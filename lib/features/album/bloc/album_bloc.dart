// BLoC untuk mengelola state daftar Album dan seluruh operasi CRUD-nya.
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:uuid/uuid.dart';
import '../models/album_entity.dart';
import '../repositories/manage_album_usecase.dart';

// --- Events ---

abstract class AlbumEvent extends Equatable {
  const AlbumEvent();

  @override
  List<Object> get props => [];
}

class LoadAlbums extends AlbumEvent {}

class CreateAlbum extends AlbumEvent {
  final String name;
  const CreateAlbum(this.name);

  @override
  List<Object> get props => [name];
}

class DeleteAlbum extends AlbumEvent {
  final String id;
  const DeleteAlbum(this.id);

  @override
  List<Object> get props => [id];
}

// Event untuk mengganti nama album yang sudah ada.
class RenameAlbum extends AlbumEvent {
  final String id;
  final String newName;

  const RenameAlbum({required this.id, required this.newName});

  @override
  List<Object> get props => [id, newName];
}

class AddRestorationToAlbum extends AlbumEvent {
  final String albumId;
  final String restorationId;
  final String thumbnailPath;

  const AddRestorationToAlbum({
    required this.albumId,
    required this.restorationId,
    required this.thumbnailPath,
  });

  @override
  List<Object> get props => [albumId, restorationId, thumbnailPath];
}

// --- States ---

abstract class AlbumState extends Equatable {
  const AlbumState();

  @override
  List<Object> get props => [];
}

class AlbumLoading extends AlbumState {}

class AlbumLoaded extends AlbumState {
  final List<AlbumEntity> albums;
  const AlbumLoaded(this.albums);

  @override
  List<Object> get props => [albums];
}

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
    on<RenameAlbum>(_onRenameAlbum);
    on<AddRestorationToAlbum>(_onAddRestorationToAlbum);
  }

  Future<void> _onLoadAlbums(LoadAlbums event, Emitter<AlbumState> emit) async {
    emit(AlbumLoading());
    try {
      emit(AlbumLoaded(await useCase.getAllAlbums()));
    } catch (e) {
      emit(AlbumError('Gagal memuat album: $e'));
    }
  }

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

  Future<void> _onDeleteAlbum(DeleteAlbum event, Emitter<AlbumState> emit) async {
    try {
      await useCase.deleteAlbum(event.id);
      add(LoadAlbums());
    } catch (e) {
      emit(AlbumError('Gagal menghapus album: $e'));
    }
  }

  // Mengganti nama album tanpa mengubah data foto di dalamnya.
  Future<void> _onRenameAlbum(RenameAlbum event, Emitter<AlbumState> emit) async {
    try {
      await useCase.renameAlbum(event.id, event.newName);
      add(LoadAlbums());
    } catch (e) {
      emit(AlbumError('Gagal mengganti nama album: $e'));
    }
  }

  Future<void> _onAddRestorationToAlbum(
    AddRestorationToAlbum event,
    Emitter<AlbumState> emit,
  ) async {
    try {
      await useCase.addRestorationToAlbum(
        event.albumId,
        event.restorationId,
        event.thumbnailPath,
      );
      add(LoadAlbums());
    } catch (e) {
      emit(AlbumError('Gagal menambahkan gambar ke album: $e'));
    }
  }
}
