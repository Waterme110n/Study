import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'Product.dart';
import 'HiveHelper.dart';

class FoodDetailScreen extends StatelessWidget {
  final String productId;

  const FoodDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Product?>(
        future: HiveHelper.getProductById(productId),
    builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
    return Center(child: CircularProgressIndicator());
    } else if (snapshot.hasError) {
    return Center(child: Text('Ошибка: ${snapshot.error}'));
    } else if (!snapshot.hasData) {
    return Center(child: Text('Продукт не найден'));
    }

    final product = snapshot.data!;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Stack(
            children: [
              Column(
                children: [
                  Container(
                    height: 400,
                    decoration: BoxDecoration(
                      image: DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Container(
                    height: 490,
                  )
                ],
              ),
              Positioned(
                top: 85,
                left: 25,
                child: Container(
                  decoration: BoxDecoration(
                    color: Color.fromRGBO(255, 255, 255, 0.5),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: IconButton(
                    icon: Icon(CupertinoIcons.back, color: Colors.black),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ),
              ),
              Positioned(
                top: 315,
                left: 0,
                right: 0,
                bottom: 0,
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(top: Radius.circular(30.0)),
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(top: 20.0, left: 25, right: 25),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(right: 145, left: 145),
                          child: Container(
                            width: 70,
                            height: 5,
                            decoration: BoxDecoration(
                                color: Color(0xFFf0f0f0),
                                borderRadius: BorderRadius.circular(100.0)),
                          ),
                        ),
                        SizedBox(height: 25),
                        Text(product.title, style: TextStyle(color: Colors.black, fontSize: 40, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                        Text(product.subtitle.toUpperCase(), style: TextStyle(color: Color(0xFFcccccc), fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                        SizedBox(height: 20),
                        Container(
                          width: 1000,
                          height: 1,
                          decoration: BoxDecoration(
                              color: Color(0xFFf0f0f0),
                              borderRadius: BorderRadius.circular(100.0)),
                        ),
                        SizedBox(height: 20),
                        Text('Description', style: TextStyle(color: Colors.black, fontSize: 23, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                        SizedBox(height: 8),
                        Text(product.description, style: TextStyle(color: Color(0xFFcccccc), fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                        SizedBox(height: 45),
                        Container(
                          width: 1070,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFebebeb),
                                spreadRadius: 3.0,
                                blurRadius: 30.0,
                                offset: Offset(0, 0),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: EdgeInsets.only(top: 22, left: 20),
                            child: RichText(
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                      text: 'Save \$99 monthly with ',
                                      style: TextStyle(color: Color(0xFFcccccc), fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: 'PRO ', style: TextStyle(color: Color(0xffd99320), height: 1.5, fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                  TextSpan(
                                      text: 'plan ',
                                      style: TextStyle(color: Color(0xFFcccccc), fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                          padding: EdgeInsets.only(right: 30, left: 30),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Text('DELIVERY COST', style: TextStyle(color: Color(0xFFcccccc), fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text('\$${product.deliveryCost.toStringAsFixed(2)}', style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                ],
                              ),
                              Container(
                                width: 2,
                                height: 56,
                                decoration: BoxDecoration(
                                    color: Color(0xFFf0f0f0),
                                    borderRadius: BorderRadius.circular(100.0)),
                              ),
                              Column(
                                children: [
                                  Text('DELIVERY TIME', style: TextStyle(color: Color(0xFFcccccc), fontSize: 15, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                  SizedBox(height: 5),
                                  Text(product.deliveryTime, style: TextStyle(color: Colors.black, fontSize: 22, fontFamily: 'Roboto', fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: 25),
                        Container(
                          width: 1070,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Color(0xFF6b45fa),
                            borderRadius: BorderRadius.circular(50.0),
                          ),
                          child: Align(
                            alignment: Alignment.center,
                            child: Text(
                              'Order for ${product.price}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontFamily: 'Roboto',
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                  bottom: 210,
                  right: 50,
                  child: Image.asset(
                    'assets/images/1.png',
                    width: 80,
                  )
              ),
            ],
          ),
        ],
      ),
    );
    },
    );
  }
}