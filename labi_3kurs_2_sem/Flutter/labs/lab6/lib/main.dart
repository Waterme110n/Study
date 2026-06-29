import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lab2/second.dart';
import 'dart:async';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';

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
          OpenMapButton(),
          MyHomePage(),
          CameraExample()
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
              child: IconButton(
                  onPressed: (){},
                  icon: Icon(Icons.more_horiz, color: Colors.black54, size: 35.0,)
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
                child: LocalizationScreen(),
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
            Container(
              height: 280.0, // Высота контейнера для PageView
              child: PageView(
                children: [
                  FoodCard(
                    imageUrl: 'https://i.pinimg.com/736x/5e/a5/6f/5ea56f212bfdd2b70b31a9d3e95d6258.jpg',
                    title: 'Pancakes',
                    subtitle: 'pancake • banana',
                    price: '\$1.99',
                    isPro: true,
                    ishot: true,
                  ),
                  FoodCard(
                    imageUrl: 'https://i.pinimg.com/736x/22/a0/f1/22a0f105bbadf3edbc5c158ba0d61f2b.jpg',
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
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    this.isPro = false,
    this.ishot = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          // Переход на второй экран с передачей данных
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FoodDetailScreen(
                title: title,
                subtitle: subtitle,
                price: price,
                imageUrl: imageUrl,
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
                      width: 400,
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
                              if (ishot)
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

class LocalizationScreen extends StatefulWidget {
  @override
  _LocalizationScreenState createState() => _LocalizationScreenState();
}

class _LocalizationScreenState extends State<LocalizationScreen> {
  static const platform = MethodChannel('com.example.localization_channel');
  String _currentLocale = 'Unknown locale';

  Future<void> _getCurrentLocale() async {
    String locale;
    try {
      final String result = await platform.invokeMethod('getCurrentLocale');
      locale = 'Current Locale: $result';
    } on PlatformException catch (e) {
      locale = "Failed to get current locale: '${e.message}'.";
    }

    setState(() {
      _currentLocale = locale;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocale();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        _currentLocale,
        style: TextStyle(
          color: Colors.black,
          fontSize: 20,
          fontFamily: 'Roboto',
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class OpenMapButton extends StatefulWidget {
  @override
  _OpenMapButtonState createState() => _OpenMapButtonState();
}

class _OpenMapButtonState extends State<OpenMapButton> {
  static const platform = MethodChannel('com.example.map_channel');
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();

  Future<void> openMap(double latitude, double longitude) async {
    try {
      await platform.invokeMethod('openMap', {'latitude': latitude, 'longitude': longitude});
    } on PlatformException catch (e) {
      print("Failed to open map: '${e.message}'.");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextField(
            controller: _latitudeController,
            decoration: InputDecoration(
              labelText: '37.7749',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          TextField(
            controller: _longitudeController,
            decoration: InputDecoration(
              labelText: '-122.4194',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              final double? latitude = double.tryParse(_latitudeController.text);
              final double? longitude = double.tryParse(_longitudeController.text);

              if (latitude != null && longitude != null) {
                openMap(latitude, longitude);
              } else {
                print("Пожалуйста, введите корректные координаты.");
              }
            },
            child: Text('Открыть карту'),
          ),
        ],
      ),
    );
  }
}
class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  static const platform = MethodChannel('samples.flutter.dev/battery');

  String _batteryLevel = 'Unknown battery level.';

  Future<void> _getBatteryLevel() async {
    String batteryLevel;
    try {
      final result = await platform.invokeMethod<int>('getBatteryLevel');
      batteryLevel = 'Battery level at $result % .';
    } on PlatformException catch (e) {
      batteryLevel = "Failed to get battery level: '${e.message}'.";
    }

    setState(() {
      _batteryLevel = batteryLevel;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            ElevatedButton(
              onPressed: _getBatteryLevel,
              child: const Text('Get Battery Level'),
            ),
            Text(_batteryLevel),
          ],
        ),
      ),
    );
  }
}

class CameraExample extends StatefulWidget {
  @override
  _CameraExampleState createState() => _CameraExampleState();
}

class _CameraExampleState extends State<CameraExample> {
  XFile? _image;

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.camera);

    setState(() {
      _image = image;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: _pickImage,
          child: Text('Сделать снимок'),
        ),
        SizedBox(height: 20),
        if (_image != null)
          Image.file(File(_image!.path), height: 300),
      ],
    );
  }
}

