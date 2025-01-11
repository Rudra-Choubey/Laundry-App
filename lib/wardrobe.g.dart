// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wardrobe.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ClothAdapter extends TypeAdapter<Cloth> {
  @override
  final int typeId = 1;

  @override
  Cloth read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Cloth(
      type: fields[0] as String,
      count: fields[1] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Cloth obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.type)
      ..writeByte(1)
      ..write(obj.count);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ClothAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
