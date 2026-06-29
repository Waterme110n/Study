// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'Product.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 1;

  @override
  Product read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Product(
      productId: fields[0] as String,
      description: fields[1] as String,
      imageUrl: fields[2] as String,
      title: fields[3] as String,
      subtitle: fields[4] as String,
      price: fields[5] as String,
      isPro: fields[6] as bool,
      isHot: fields[7] as bool,
      deliveryTime: fields[8] as String,
      deliveryCost: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.productId)
      ..writeByte(1)
      ..write(obj.description)
      ..writeByte(2)
      ..write(obj.imageUrl)
      ..writeByte(3)
      ..write(obj.title)
      ..writeByte(4)
      ..write(obj.subtitle)
      ..writeByte(5)
      ..write(obj.price)
      ..writeByte(6)
      ..write(obj.isPro)
      ..writeByte(7)
      ..write(obj.isHot)
      ..writeByte(8)
      ..write(obj.deliveryTime)
      ..writeByte(9)
      ..write(obj.deliveryCost);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProductAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
