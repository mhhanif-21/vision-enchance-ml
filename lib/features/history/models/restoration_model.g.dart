// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'restoration_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class RestorationModelAdapter extends TypeAdapter<RestorationModel> {
  @override
  final int typeId = 0;

  @override
  RestorationModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return RestorationModel(
      id: fields[0] as String,
      originalImagePath: fields[1] as String,
      restoredImagePath: fields[2] as String,
      modelType: fields[3] as String,
      createdAt: fields[4] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, RestorationModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.originalImagePath)
      ..writeByte(2)
      ..write(obj.restoredImagePath)
      ..writeByte(3)
      ..write(obj.modelType)
      ..writeByte(4)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RestorationModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
