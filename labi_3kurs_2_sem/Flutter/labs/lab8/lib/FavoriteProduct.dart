import 'package:hive/hive.dart';

part 'FavoriteProduct.g.dart';

@HiveType(typeId: 2)
class FavoriteProduct {
  @HiveField(0)
  final String favoriteId;

  @HiveField(1)
  final String productId;

  @HiveField(2)
  final String username;

  FavoriteProduct(this.favoriteId, this.productId, this.username);
}