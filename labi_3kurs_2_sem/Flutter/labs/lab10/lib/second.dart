import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class FoodDetailScreen extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;

  const FoodDetailScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
                        image: NetworkImage(imageUrl),
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
                                borderRadius: BorderRadius.circular(100.0)
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Text(title, style: TextStyle(color: Colors.black,  fontSize: 40, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
                        Text((subtitle).toUpperCase(), style: TextStyle(color: Color(0xFFcccccc),  fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
                        SizedBox(height: 20),
                        Container(
                          width: 1000,
                          height: 1,
                          decoration: BoxDecoration(
                              color: Color(0xFFf0f0f0),
                              borderRadius: BorderRadius.circular(100.0)
                          ),
                        ),
                        SizedBox(height: 20),
                        Text('Descriprion', style: TextStyle(color: Colors.black,  fontSize: 23, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
                        SizedBox(height: 8),
                        RichText(
                           text: TextSpan(
                             children: [
                               TextSpan(
                                 text: 'Banana pancakes are a delightful and fluffy breakfast treat that combines the sweetness of... ',
                               style: TextStyle(color: Color(0xFFcccccc),  fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)
                               ),
                               TextSpan(
                                 text: 'Read more', style: TextStyle(color: Color(0xFFb19df6), height: 1.5, fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)
                               ),
                             ],
                           ),
                        ),
                        SizedBox(height: 45),
                        Container(
                          width: 1070,
                          height: 70,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color:  Color(0xFFebebeb),
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
                                      text:  'Save \$99 monthly with ',
                                      style: TextStyle(color: Color(0xFFcccccc),  fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)
                                  ),
                                  TextSpan(
                                      text: 'PRO ', style: TextStyle(color: Color(0xffd99320), height: 1.5, fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)
                                  ),
                                  TextSpan(
                                      text:  'plan ',
                                      style: TextStyle(color: Color(0xFFcccccc),  fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 25),
                        Padding(
                            padding: EdgeInsets.only(right: 30, left: 30),
                            child:Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          children: [
                            Text(('delivery cost').toUpperCase(), style: TextStyle(color: Color(0xFFcccccc),  fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(('Free'), style: TextStyle(color: Colors.black,  fontSize: 22, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),

                          ],
                        ),
                        Container(
                          width: 2,
                          height: 56,
                          decoration: BoxDecoration(
                              color:  Color(0xFFf0f0f0),
                              borderRadius: BorderRadius.circular(100.0)
                          ),
                        ),
                        Column(
                          children: [
                            Text(('delivery time').toUpperCase(), style: TextStyle(color: Color(0xFFcccccc),  fontSize: 15, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),
                            SizedBox(height: 5),
                            Text(('9:15 am'), style: TextStyle(color: Colors.black,  fontSize: 22, fontFamily: 'Roboto',fontWeight:  FontWeight.bold)),

                          ],
                        ),
                      ],
                    )
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
                              'Order for ' + price,
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
                )
              ),
              Positioned(
                  bottom: 210,
                  right: 50,
                  child: Image.asset(
                    'assets/images/1.png',
                    width: 80,
                  )
              )
            ],
          ),
        ],
      ),
    );
  }
}
