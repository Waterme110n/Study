import 'package:hive/hive.dart';
import 'FavoriteProduct.dart';
import 'Product.dart';

class HiveHelper {
  static Future<Product?> getProductById(String productId) async {
    final box = await Hive.openBox<Product>('products');
    return box.get(productId);
  }

  static Future<void> addProduct(Product product) async {
    final box = await Hive.openBox<Product>('products');
    await box.put(product.productId, product);
  }

  static Future<void> addFavoriteProduct(FavoriteProduct favoriteProduct) async {
    final box = await Hive.openBox<FavoriteProduct>('favorites');
    await box.put(favoriteProduct.favoriteId, favoriteProduct);
  }

  static Future<List<FavoriteProduct>> getFavoriteProducts(String username) async {
    final box = await Hive.openBox<FavoriteProduct>('favorites');
    return box.values.where((item) => item.username == username).toList();
  }

  static Future<void> clearFavoriteProducts() async {
    final box = await Hive.openBox<FavoriteProduct>('favorites');
    await box.clear();
  }

  static Future<void> removeFavoriteProduct(String favoriteId) async {
    final box = await Hive.openBox<FavoriteProduct>('favorites');
    await box.delete(favoriteId);
  }

  static Future<bool> isProductInFavorites(String productId, String username) async {
    final box = await Hive.openBox<FavoriteProduct>('favorites');
    return box.values.any((item) => item.productId == productId && item.username == username);
  }
}