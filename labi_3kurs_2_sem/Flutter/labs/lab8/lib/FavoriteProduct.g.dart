// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'FavoriteProduct.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteProductAdapter extends TypeAdapter<FavoriteProduct> {
  @override
  final int typeId = 2;

  @override
  FavoriteProduct read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteProduct(
      fields[0] as String,
      fields[1] as String,
      fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteProduct obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.favoriteId)
      ..writeByte(1)
      ..write(obj.productId)
      ..writeByte(2)
      ..write(obj.username);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
