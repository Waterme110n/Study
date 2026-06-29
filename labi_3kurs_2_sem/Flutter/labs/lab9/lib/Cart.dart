import 'package:flutter/material.dart';
import 'package:lab2/second.dart';
import 'package:provider/provider.dart';
import 'FoodProvider.dart';

class Cart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cart'),
      ),
      body: Consumer<FoodProvider>(
        builder: (context, foodProvider, child) {
          return foodProvider.cart.isNotEmpty ? Column(
            children: [
              Expanded(
                child: ListView.builder(
                  itemCount: foodProvider.cart.length,
                  itemBuilder: (context, index) {
                    final food = foodProvider.cart[index];
                    return ListTile(
                      leading: Image.network(food.imageUrl),
                      title: Text(food.title),
                      subtitle: Text(food.subtitle),
                      trailing: Text(food.price),
                      onLongPress: () {
                        foodProvider.removeFromCart(food);
                      },
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => FoodDetailScreen(
                              food: food,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  'Total: \$${calculateTotal(foodProvider.cart)}',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          )
              : Center(child: Text('Your cart is empty'));
        },
      ),
    );
  }

  double calculateTotal(List<Food> cart) {
    double total = 0.0;
    for (var food in cart) {
      String priceString = food.price.replaceAll('\$', '');
      total += double.tryParse(priceString) ?? 0.0;
    }
    return total;
  }
}