import 'package:flutter/material.dart';

class Food {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final bool isPro;
  final bool isHot;

  Food({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.isPro = false,
    this.isHot = false,
  });
}

class FoodProvider with ChangeNotifier {
  final List<Food> _foods = [
    Food(
      imageUrl: 'https://i.pinimg.com/736x/5e/a5/6f/5ea56f212bfdd2b70b31a9d3e95d6258.jpg',
      title: 'Pancakes',
      subtitle: 'pancake • banana',
      price: '\$1.99',
      isPro: true,
      isHot: true,
    ),
    Food(
      imageUrl: 'https://aif-s3.aif.ru/images/015/573/91c0d7c133aa580e0c368bb536b053a1.jpg',
      title: 'Sandwich',
      subtitle: 'sandwich • tomato',
      price: '\$3.49',
      isPro: false,
      isHot: false,
    ),
    Food(
      imageUrl:
      'https://i.pinimg.com/736x/8b/36/9f/8b369fefca44952ef36cc09f830c00e7.jpg',
      title: 'Burga',
      subtitle: 'burger • cheese',
      price: '\$5.99',
      isPro: false,
      isHot: true,
    ),
    Food(
      imageUrl:
      'https://i.pinimg.com/736x/87/7a/b9/877ab9df6ec6fb47851ef803d72550d7.jpg',
      title: 'Potato in Mundir',
      subtitle: 'Potato • Meet',
      price: '\$7.49',
      isPro: true,
      isHot: false,
    ),
  ];

  List<Food> _cart = [];

  List<Food> get foods => _foods;
  List<Food> get cart => _cart;

  void addToCart(Food food) {
    _cart.add(food);
    notifyListeners();
  }

  void removeFromCart(Food food) {
    _cart.remove(food);
    notifyListeners();
  }
}