import 'package:flutter/material.dart';
import 'package:lab2/Cart.dart';
import 'package:provider/provider.dart';
import 'FoodProvider.dart';
import 'second.dart';
import 'Cart.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => FoodProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food App',
      home: FoodAppScreen(), // Your main screen
    );
  }
}

class FoodAppScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body:   SingleChildScrollView(
        scrollDirection: Axis.vertical,
          child: Column(
        children: [

          Container(
            height: 180.0,
            decoration: BoxDecoration(
              color: Colors.white, // Цвет фона
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(16.0),
                bottomRight: Radius.circular(16.0),
              ),
              boxShadow: [
                BoxShadow(
                  color: Color(0xF0f0f0f0),
                  spreadRadius: 6.0, // Распространение тени
                  blurRadius: 10.0, // Размытие тени
                  offset: Offset(0, 0), // Смещение тени (по оси x и y)
                ),
              ],
            ),
            child: topWidget(context),
          ),
          Container(
            height: 180.0,
              child: calendar(context),
          ),
          menuFst(context),
          menuSec(context),
        ],
      ),
      )
    );
  }

  Widget topWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, top: 30.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.network(
              'https://i.pinimg.com/736x/42/fb/aa/42fbaaf78e65b377f3d20f4629461211.jpg',
              width: 85.0,
              height: 85.0,
              fit: BoxFit.cover,
            ),
          ),
          Column(
          crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Padding(
                padding: EdgeInsets.only(top: 20.0,),
                child: PopupMenuButton<String>(
                  icon: Icon(Icons.more_horiz, color: Colors.black54, size: 35.0),
                  onSelected: (String value) {
                    switch (value) {
                      case 'cart':
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => Cart()),
                        );
                        break;
                    }
                  },
                  itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
                    const PopupMenuItem<String>(
                      value: 'cart',
                      child: Text('Корзина'),
                    ),
                  ],
                ),
                ),
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child:  Text( 'Dubai, UAE',
                  style: TextStyle(color: Colors.grey, fontSize: 12,fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(right: 10.0),
                child: Text( 'Lost Office 2, Entrance A',
                  style: TextStyle(color: Colors.black, fontSize: 20, fontFamily: 'Roboto',fontWeight:  FontWeight.bold),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget calendar(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(left: 25.0, top: 30.0, ),
      child: Column(
        children: [
          Row(
            children: [
              Text('November, 2019', style: TextStyle(color: Colors.black,  fontSize: 17, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
              Icon(Icons.expand_more)
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Padding(padding: EdgeInsets.only(top: index == 3 ? 0.0 : 25.0),
                child: Container(
                  width: 55,
                  height: 75,
                  decoration: BoxDecoration(
                    border: Border.all(color:  index == 3 ? Colors.transparent : Color(0xFFcccccc) ),
                    color: index == 3 ? Color(0xFF6b45fa) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: index == 3 ? Color(0xFF6b45fa) : Colors.transparent,
                        spreadRadius: 1.0,
                        blurRadius: 10.0,
                        offset: Offset(0, 0),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'][index],
                        style: TextStyle(
                            color: index == 3
                                ? Colors.white
                                : Color(0xFFcccccc),
                            fontFamily: 'Roboto',fontWeight:  FontWeight.bold
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        (18 + index).toString(),
                        style: TextStyle(
                            fontWeight:  FontWeight.bold,
                            fontSize: 20.0,
                            color: index == 3
                                ? Colors.white
                                : Color(0xFF636363)
                        ),
                      ),
                    ],
                  ),
                )
              );
            }),
          )
        ],
      ),
    );
  }

  Widget menuFst(BuildContext context) {
    return Consumer<FoodProvider>(
      builder: (context, foodProvider, child) {
        return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25.0, top: 0.0, right: 25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Breakfast\'s',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 30,
                      fontFamily: 'Roboto',
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.access_time, color: Color(0xFFcccccc), size: 18.0),
                      SizedBox(width: 3),
                      Text(
                        '9:15 am',
                        style: TextStyle(color: Color(0xFFcccccc), fontSize: 12.0),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...foodProvider.foods.sublist(0, 2).map((food) {
                    return Padding(
                      padding: EdgeInsets.only(left: 25.0),
                      child: FoodCard(
                        food: food,
                      ),
                    );
                  }).toList(),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget menuSec(BuildContext context){
    final foodProvider = Provider.of<FoodProvider>(context);
    return Column(
      children: [
        Padding(
            padding: EdgeInsets.only(left: 25.0, top: 0.0, right: 25.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text( 'FastFood\'s',
                  style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Roboto',fontWeight:  FontWeight.bold),
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Icon(Icons.access_time, color: Color(0xFFcccccc), size: 18.0),
                    SizedBox(width: 3),
                    Text('12:00 am', style: TextStyle(color: Color(0xFFcccccc), fontSize: 12.0,))
                  ],
                )
              ],
            )
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              ...foodProvider.foods.sublist(2, 4).map((food) {
                return Padding(
                  padding: EdgeInsets.only(left: 25.0),
                  child: FoodCard(
                    food: food,
                  ),
                );
              }).toList(),
            ],
          ),
        ),
      ],
    );
  }
}

class FoodCard extends StatelessWidget {
  final Food food;

  const FoodCard({
    required this.food,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
        child: Padding(padding: EdgeInsets.only(
            left: 0.0, top: 18.0, right: 0.0, bottom: 30),
            child: Container(
              width: 200.0,
              height: 245.0,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Color(0xF0f0f0f0),
                    spreadRadius: 1.0,
                    blurRadius: 10,
                    offset: Offset(1, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30.0),
                        topRight: Radius.circular(30.0)),
                    child: Container(
                      width: 200,
                      height: 125,
                      child: Image.network(
                        food.imageUrl,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  Padding(padding: EdgeInsets.only(left: 20.0, top: 15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                food.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              if (food.isHot)
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child: Image.network(
                                    'https://cdn-icons-png.flaticon.com/256/5371/5371600.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            food.subtitle.toUpperCase(),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFFcccccc),
                                fontSize: 12,
                                fontFamily: 'Roboto'
                            ),
                          ),
                          SizedBox(height: 8),
                          Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  food.price,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: food.isPro == true
                                          ? Color(0xffd99320)
                                          : Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Roboto'
                                  ),
                                ),
                                if (food.isPro)
                                  Padding(padding: EdgeInsets.only(right: 20),
                                      child: Text('PRO', style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontFamily: 'Roboto',
                                          color: Color(0xffd99320),
                                          fontSize: 15),
                                      )
                                  )
                              ]
                          )
                        ],
                      )
                  ),
                ],
              ),
            )
        )
    );
  }
}
