import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:lab11/AddFoodPage.dart';
import 'package:lab11/EditFoodPage.dart';
import 'package:lab11/Profile.dart';
import 'Auth.dart';
import 'FoodItem.dart';
import 'second.dart';
import 'dart:convert';

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print("Handling a background message: ${message.messageId}");
}

class FoodAppScreen extends StatefulWidget {
  @override
  _FoodAppScreenState createState() => _FoodAppScreenState();
}

class _FoodAppScreenState extends State<FoodAppScreen> {
  late Future<List<FoodItem>> foodItemsFuture;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final remoteConfig = FirebaseRemoteConfig.instance;
  bool isLoad = false;
  int colorInt = 1;
  @override

  void initState() {
    super.initState();
    foodItemsFuture = fetchFoodItems();
    _requestPermission();
    _setupMessaging();
    _fetchRemoteConfig();
  }

  Future<void> _fetchRemoteConfig() async {
    setState(() {
      isLoad = true;
    });

    await remoteConfig.setDefaults(const {
      "color": 0xFF00adb5,
      "show_calendar": true,

    });

    await remoteConfig.setConfigSettings(RemoteConfigSettings(
      fetchTimeout: const Duration(seconds: 1),
      minimumFetchInterval: const Duration(seconds: 1),
    ));


    try {
      await remoteConfig.fetchAndActivate();
    } catch (e) {
      print("Ошибка получения конфигурации: $e");
    }

    String colorString = remoteConfig.getString("color");
    colorInt = int.parse(colorString);


    setState(() {
      isLoad = false;
    });

  }


  void _requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    print('User granted permission: ${settings.authorizationStatus}');
  }

  void _setupMessaging() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      if (notification != null) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(notification.title ?? ""),
            content: Text(notification.body ?? ""),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text('OK'),
              ),
            ],
          ),
        );
      }
    });
  }

  Future<void> refreshFoodItems() async {
    setState(() {
      foodItemsFuture = fetchFoodItems();
    });
  }

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
          isLoad?CircularProgressIndicator():Container(
            height: 180.0,
            child: remoteConfig.getBool("show_calendar")
                ? calendar(context)
                : SizedBox.shrink(),
          ),
          menuFst(context),
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
            child: Image.asset(
              'assets/images/ava.jpg',
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
                  icon: Icon(Icons.more_horiz,color: Colors.black54,size: 35.0,),
                  onSelected: (value) async {
                    if (value == 'add') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AddFoodItemPage(),
                        ),
                      ).then((_) {
                        refreshFoodItems();
                      });
                    } else if (value == 'exit'){
                      await FirebaseAuth.instance.signOut();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => AuthScreen()),
                      );
                    } else if (value == 'profile') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => UserProfileScreen()),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {

                    List<PopupMenuEntry<String>> menuItems = [];
                    menuItems.add(
                      PopupMenuItem<String>(
                        value: 'add',
                        child: Text('Создать блюдо'),
                      ),
                    );
                    menuItems.add(
                      PopupMenuItem<String>(
                        value: 'profile',
                        child: Text('Профиль'),
                      ),
                    );
                    menuItems.add(
                      PopupMenuItem<String>(
                        value: 'exit',
                        child: Text('Выход'),
                      ),
                    );
                    return menuItems;
                  },
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
                    color: index == 3 ? Color(colorInt) : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: index == 3 ? Color(colorInt) : Colors.transparent,
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

  Widget menuFst(BuildContext context){
    return Column(
          children: [
            Padding(
              padding: EdgeInsets.only(left: 25.0, top: 0.0, right: 25.0),
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
            FutureBuilder<List<FoodItem>>(
              future: fetchFoodItems(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }
                if (snapshot.hasError) {
                  print(snapshot.error);
                  return Text('Error: ${snapshot.error}');
                }
                final foodItems = snapshot.data ?? [];
                return SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: foodItems.map((foodItem) {
                      return Padding(
                        padding: EdgeInsets.only(left: 25.0),
                        child: FoodCard(
                            foodItem: foodItem,
                            refreshFoodItems :refreshFoodItems
                        ),
                      );
                    }).toList(),
                  ),
                );
              },
            ),
          ],
    );
  }
}

class FoodCard extends StatelessWidget {
  final FoodItem foodItem;
  final Future<void> Function() refreshFoodItems;

  const FoodCard({
    required this.foodItem,
    required this.refreshFoodItems,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Переход на второй экран
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(foodItem: foodItem),
            ),
          );
        },
        onLongPress: () {
          showMenu(
            context: context,
            position: RelativeRect.fromLTRB(110, 700, 110, 0),
            items: [
              PopupMenuItem<String>(
                value: 'edit',
                child: Text('Изменить'),
              ),
              PopupMenuItem<String>(
                value: 'delete',
                child: Text('Удалить'),
              ),
            ],
          ).then((value) {
            if (value == 'edit') {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => EditFoodItemPage(foodItem: foodItem),
                )
              ).then((_) {
                refreshFoodItems();
              });
            } else if (value == 'delete') {
              deleteFoodItem(foodItem.id);
              refreshFoodItems();

            }
          });
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
                      child: Image.memory(
                        base64Decode(foodItem.imageUrl),
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
                                foodItem.title,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              if (foodItem.isHot)
                                Padding(
                                  padding: EdgeInsets.only(right: 20.0),
                                  child: Image.asset(
                                    'assets/images/fire.png',
                                    width: 20,
                                    height: 20,
                                  ),
                                ),
                            ],
                          ),
                          Text(
                            foodItem.subtitle.toUpperCase(),
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
                                  "\$" + foodItem.price,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: foodItem.isPro == true
                                          ? Color(0xffd99320)
                                          : Colors.black,
                                      fontSize: 20,
                                      fontFamily: 'Roboto'
                                  ),
                                ),
                                if (foodItem.isPro)
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

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  firestore.settings = Settings(persistenceEnabled: true);
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: AuthScreen(),
  ));
}
