import 'package:hive/hive.dart';

part 'Product.g.dart';

@HiveType(typeId: 1)
class Product {
  @HiveField(0)
  final String productId;

  @HiveField(1)
  final String description;

  @HiveField(2)
  final String imageUrl;

  @HiveField(3)
  final String title;

  @HiveField(4)
  final String subtitle;

  @HiveField(5)
  final String price;

  @HiveField(6)
  final bool isPro;

  @HiveField(7)
  final bool isHot;

  @HiveField(8)
  final String deliveryTime;

  @HiveField(9)
  final double deliveryCost;

  Product({
    required this.productId,
    required this.description,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.isPro,
    required this.isHot,
    required this.deliveryTime,
    required this.deliveryCost,
  });

}