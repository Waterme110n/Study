import 'package:flutter/material.dart';
import 'HiveHelper.dart';
import 'Product.dart';
import 'FavoriteProduct.dart';
import 'second.dart';

class FavoritesScreen extends StatefulWidget {
  final String username;

  const FavoritesScreen({required this.username});

  @override
  _FavoritesScreenState createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<FavoriteProduct> _favoriteProducts = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteProducts();
  }

  void _loadFavoriteProducts() async {
    try {
      final products = await HiveHelper.getFavoriteProducts(widget.username);
      setState(() {
        _favoriteProducts = products;
        _isLoading = false;
      });
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $error')),
      );
    }
  }

  void _removeFavoriteProduct(String favoriteId) async {
    try {
      await HiveHelper.removeFavoriteProduct(favoriteId);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Продукт удалён из избранного')),
      );
      _loadFavoriteProducts();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при удалении: $error')),
      );
    }
  }

  void _navigateToDetail(String productId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FoodDetailScreen(productId: productId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранные продукты'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _favoriteProducts.isEmpty
          ? Center(child: Text('Нет избранных продуктов.'))
          : ListView.builder(
        itemCount: _favoriteProducts.length,
        itemBuilder: (context, index) {
          final favorite = _favoriteProducts[index];

          return FutureBuilder<Product?>(
            future: HiveHelper.getProductById(favorite.productId),
            builder: (context, productSnapshot) {
              if (productSnapshot.connectionState == ConnectionState.waiting) {
                return ListTile(title: Text('Загрузка...'));
              } else if (productSnapshot.hasError) {
                return ListTile(title: Text('Ошибка загрузки продукта.'));
              } else if (!productSnapshot.hasData) {
                return ListTile(title: Text('Продукт не найден.'));
              }

              final product = productSnapshot.data!;
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(product.imageUrl),
                ),
                title: Text(product.title),
                subtitle: Text(product.subtitle),
                trailing: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    _removeFavoriteProduct(favorite.favoriteId);
                  },

                ),
                onTap: () {
                  _navigateToDetail(product.productId);
                },
              );
            },
          );
        },
      ),
    );
  }
}