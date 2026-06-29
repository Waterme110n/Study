import 'package:cloud_firestore/cloud_firestore.dart';

class FoodItem {
  final String id;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final bool isPro;
  final bool isHot;

  FoodItem({
    required this.id,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.isPro = false,
    this.isHot = false,
  });

  Map<String, dynamic> toMap() {
    return {
      'imageUrl': imageUrl,
      'title': title,
      'subtitle': subtitle,
      'price': price,
      'isPro': isPro,
      'isHot': isHot,
    };
  }

  static FoodItem fromMap(String id, Map<String, dynamic> map) {
    return FoodItem(
      id: id,
      imageUrl: map['imageUrl'],
      title: map['title'],
      subtitle: map['subtitle'],
      price: map['price'],
      isPro: map['isPro'] ?? false,
      isHot: map['isHot'] ?? false,
    );
  }
}

Future<void> addFoodItem(FoodItem foodItem) async {
  final docRef = FirebaseFirestore.instance.collection('foodItems').doc();
  await docRef.set(foodItem.toMap());
}

Future<List<FoodItem>> fetchFoodItems() async {
  final snapshot = await FirebaseFirestore.instance.collection('foodItems').get();
  return snapshot.docs.map((doc) => FoodItem.fromMap(doc.id, doc.data())).toList();
}

Future<void> updateFoodItem(String id, FoodItem foodItem) async {
  final docRef = FirebaseFirestore.instance.collection('foodItems').doc(id);
  await docRef.update(foodItem.toMap());
}

Future<void> deleteFoodItem(String id) async {
  final docRef = FirebaseFirestore.instance.collection('foodItems').doc(id);
  await docRef.delete();
}