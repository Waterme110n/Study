import 'package:flutter/material.dart';
import 'second.dart';
import 'dart:math';



class CustomCurve extends Curve {
  @override
  double transform(double t) {
    return 1 + pow(t - 1, 5).toDouble();
  }
}

class FoodAppScreen extends StatefulWidget {
  @override
  FoodAppScreenState createState() => FoodAppScreenState();
}

class FoodAppScreenState extends State<FoodAppScreen> with SingleTickerProviderStateMixin{
  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<Color?> _colorAnimation;
  Color menuSecColor = Colors.blue;
  double opacity = 1.0;
  double _fontSize = 20.0;
  double _paddingValue = 25.0;


  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 50).animate(CurveTween(curve: CustomCurve()).animate(_controller));
    _colorAnimation = ColorTween(begin: Colors.grey, end: Colors.blue).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut),);

    _controller.addListener(() {
      setState(() {
      });
    });
  }

  void ExplicitAnimations(){
    if (_controller.isCompleted) {
      _controller.reverse();
    } else {
      _controller.forward(from: 0);
    }
  }



  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _changeProperties() {
    setState(() {
      _fontSize = _fontSize == 20.0 ? 25.0 : 20.0;
    });
  }

  void changeColor() {
    setState(() {
      menuSecColor = menuSecColor == Colors.blue ? Colors.green : Colors.blue;
      opacity = opacity == 1.0 ? 0.0 : 1.0;
      _paddingValue = _paddingValue == 25.0 ? 50.0 : 25.0;
    });

  }


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
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: AnimatedPositioned(
                duration: Duration(seconds: 1),
                left: _animation.value,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.network(
                    'https://i.pinimg.com/736x/42/fb/aa/42fbaaf78e65b377f3d20f4629461211.jpg',
                    width: 85.0,
                    height: 85.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            Positioned(
              right: 0,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Padding(
                    padding: EdgeInsets.only(top: 20.0),
                    child: IconButton(
                      onPressed:ExplicitAnimations,
                      icon: Icon(Icons.more_horiz, color: Colors.black54, size: 35.0),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child: Text(
                      'Dubai, UAE',
                      style: TextStyle(color: _colorAnimation.value, fontSize: 12, fontFamily: 'Roboto', fontWeight: FontWeight.bold),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.only(right: 10.0),
                    child:  GestureDetector(
                      onTap: _changeProperties,
                    child: TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 20.0, end: _fontSize),
                      duration: const Duration(seconds: 1),
                      builder: (context, value, child) {
                        return  Text(
                            'Lost Office 2, Entrance A',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: value,
                              fontFamily: 'Roboto',
                              fontWeight: FontWeight.bold,
                            ),
                        );
                      },
                      onEnd: () => { ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: const Text('Анимация завершена!'),
                          duration: const Duration(seconds: 2),
                          ),
                        )
                      }
                    ),
                    )
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget calendar(BuildContext context){
    return Padding(
      padding: EdgeInsets.only(left: 25.0, top: 30.0, ),
      child: Column(
        children: [
          AnimatedOpacity(
            duration: Duration(seconds: 1),
            opacity: opacity,
            child: Row (
              children: [
                Text('November, 2019', style: TextStyle(color: Colors.black,  fontSize: 17, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
                Icon(Icons.expand_more)
              ],
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(6, (index) {
              return Padding(padding: EdgeInsets.only(top: index == 3 ? 0.0 : 25.0),
              child: GestureDetector(
                  onTap: changeColor,
                  child: AnimatedContainer(
                    duration: Duration(seconds: 1),
                    width: 55,
                    height: 75,
                    decoration: BoxDecoration(
                      border: Border.all(color:  index == 3 ? Colors.transparent : Color(0xFFcccccc) ),
                      color: index == 3 ? menuSecColor : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: index == 3 ? menuSecColor : Colors.transparent,
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
                                  : Color(0xFF636363),
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
              ),
              );
            }),
          )
        ],
      ),
    );
  }

  Widget menuFst(BuildContext context){
    return Column(
          children: [
            AnimatedPadding(
                padding: EdgeInsets.only(left: _paddingValue, top: 0.0, right: _paddingValue),
                duration: const Duration(seconds: 1),
                curve: Curves.easeInOut,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text( 'Breakfast\'s',
                    style: TextStyle(color: Colors.black, fontSize: 30, fontFamily: 'Roboto',fontWeight:  FontWeight.bold),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Icon(Icons.access_time, color: Color(0xFFcccccc), size: 18.0),
                      SizedBox(width: 3),
                      Text('9:15 am', style: TextStyle(color: Color(0xFFcccccc), fontSize: 12.0,))
                    ],
                  )
                ],
              )
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: FoodCard(
                    imageUrl:
                    'https://i.pinimg.com/736x/5e/a5/6f/5ea56f212bfdd2b70b31a9d3e95d6258.jpg',
                    title: 'Pancakes',
                    subtitle: 'pancake • banana',
                    price: '\$1.99',
                    isPro: true,
                    ishot: true,
                  ),
                ),
                  SizedBox(width: 20),
                  FoodCard(
                    imageUrl:
                    'https://i.pinimg.com/736x/22/a0/f1/22a0f105bbadf3edbc5c158ba0d61f2b.jpg',
                    title: 'Cookies',
                    subtitle: 'cookie • strawberry',
                    price: '\$3.49',
                    isPro: false,
                    ishot: false,
                  ),
                ],
              ),
            ),
          ],
    );
  }

  Widget menuSec(BuildContext context){
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
              Padding(
                padding: EdgeInsets.only(left: 25.0),
                child: FoodCard(
                  imageUrl:
                  'https://i.pinimg.com/736x/8b/36/9f/8b369fefca44952ef36cc09f830c00e7.jpg',
                  title: 'Burga',
                  subtitle: 'burger • cheese',
                  price: '\$5.99',
                  isPro: false,
                  ishot: true,
                ),
              ),
              SizedBox(width: 20),
              FoodCard(
                imageUrl:
                'https://i.pinimg.com/736x/87/7a/b9/877ab9df6ec6fb47851ef803d72550d7.jpg',
                title: 'Potato in Mundir',
                subtitle: 'Potato • Meet',
                price: '\$7.49',
                isPro: true,
                ishot: false,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class FoodCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final bool isPro;
  final bool ishot;

  const FoodCard({
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.isPro = false,
    this.ishot = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Переход на второй экран
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodDetailScreen()),
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
                        imageUrl,
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
                                title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                            ],
                          ),
                          Text(
                            subtitle.toUpperCase(),
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
                                  price,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isPro == true
                                          ? Color(0xffd99320)
                                          : Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Roboto'
                                  ),
                                ),
                                if (isPro)
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

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FoodAppScreen(),
  ));
}