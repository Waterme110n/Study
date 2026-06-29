import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';
import 'FavoriteProduct.dart';
import 'FavoritesScreen.dart';
import 'HiveHelper.dart';
import 'second.dart';
import 'CreateDishScreen.dart';
import 'EditDishScreen.dart';
import 'User.dart';
import 'Product.dart';
import 'encode.dart';



void main()  async{
  await Hive.initFlutter();
  Hive.registerAdapter(ProductAdapter());
  Hive.registerAdapter(FavoriteProductAdapter());
  await Hive.openBox<Product>('products');


  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: FoodAppScreen(),
  ));
}

class FoodAppScreen extends StatefulWidget {
  @override
  _FoodAppScreenState createState() => _FoodAppScreenState();
}


class _FoodAppScreenState extends State<FoodAppScreen> {
  User currentUser = User('Username', 'user');
  List<Product> products = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  void fetchProducts() async {
    bool useSecondKey = false; // вот тут менять
    final encryptionKey = await getEncryptionKey(useSecondKey: useSecondKey);
    print('Encryption Key: $encryptionKey');
    final encryptedBox = await Hive.openBox<Product>(
      'products',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    setState(() {
      products = encryptedBox.values.toList();
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
                  spreadRadius: 6.0,
                  blurRadius: 10.0,
                  offset: Offset(0, 0),
                ),
              ],
            ),
            child: topWidget(context,currentUser),
          ),
          Container(
            height: 180.0,
              child: calendar(context),
          ),
          menuFst(context),
        ],
      ),
      )
    );
  }

  Widget topWidget(BuildContext context, User currentUser) {
    return Padding(
      padding: EdgeInsets.only(left: 25.0, top: 30.0, right: 15.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16.0),
            child: Image.asset(
              'assets/images/1.png',
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
                  onSelected: (value) {
                    if (value == 'change_role') {
                      currentUser.changeRole();
                      (context as Element).markNeedsBuild();
                    } else if (value == 'add') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CreateDishScreen(
                            onProductCreated: () {
                              setState(() {
                                fetchProducts();
                              });
                            },
                          ),
                        ),
                      );
                    } else if (value == 'favorites') {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FavoritesScreen(username: currentUser.username),
                        ),
                      );
                    }
                  },
                  itemBuilder: (BuildContext context) {

                    List<PopupMenuEntry<String>> menuItems = [];
                    menuItems.add(
                      PopupMenuItem<String>(
                        value: 'change_role',
                        child: Text('Сменить роль'),
                      ),
                    );
                    if (currentUser.role == 'admin') {
                      menuItems.add(
                        PopupMenuItem<String>(
                          value: 'add',
                          child: Text('Создать блюдо'),
                        ),
                      );
                    } else{
                      menuItems.add(
                        PopupMenuItem<String>(
                          value: 'favorites',
                          child: Text('Просмотреть избранные '),
                        ),
                      );
                    }

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
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
                    child: Row(
                      children: products.map((product) {
                        return Padding(
                          padding: EdgeInsets.only(left: 16.0),
                          child: FoodCard(
                            productId: product.productId,
                            imageUrl: product.imageUrl,
                            title: product.title,
                            subtitle: product.subtitle,
                            price: product.price,
                            description: product.description,
                            isPro: product.isPro,
                            isHot: product.isHot,
                            deliveryTime: product.deliveryTime,
                            deliveryCost: product.deliveryCost,
                            onProductUpdated: fetchProducts,
                            currentUser: currentUser,
                          ),
                        );
                      }).toList(),
                    ),
                  ),
          ],
    );
  }
}

class FoodCard extends StatelessWidget {
  final String productId;
  final String imageUrl;
  final String title;
  final String subtitle;
  final String price;
  final String description;
  final bool isPro;
  final bool isHot;
  final String deliveryTime;
  final double deliveryCost;
  final Function() onProductUpdated;
  final User currentUser;

  const FoodCard({
    required this.productId,
    required this.imageUrl,
    required this.title,
    required this.subtitle,
    required this.price,
    required this.description,
    this.isPro = false,
    this.isHot = false,
    required this.deliveryTime,
    required this.deliveryCost,
    required this.onProductUpdated,
    required this.currentUser,
  });


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => FoodDetailScreen(productId: productId)),
          );
        },
        onLongPress: () {
          _showContextMenu(context, currentUser);
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
                              if (isHot)
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

  void _showContextMenu(BuildContext context, User currentUser) {
    List<PopupMenuEntry<String>> menuItems = [];

    // Проверяем роль пользователя для добавления дополнительных пунктов
    if (currentUser.role == 'admin') {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'edit',
          child: Text('Редактировать'),
        ),
      );

      // Добавляем пункт "Удалить"
      menuItems.add(
        PopupMenuItem<String>(
          value: 'delete',
          child: Text('Удалить'),
        ),
      );

    } else {
      menuItems.add(
        PopupMenuItem<String>(
          value: 'addToFavorites',
          child: Text('добавить в избранное'),
        ),
      );
    }

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(110, 700, 100, 0),
      items: menuItems,
    ).then((value) {
      if (value == 'edit') {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditDishScreen(
              onProductUpdated: onProductUpdated,
              product: Product(
                productId: productId,
                imageUrl: imageUrl,
                title: title,
                subtitle: subtitle,
                description: description,
                price: price,
                isPro: isPro,
                isHot: isHot,
                deliveryTime: deliveryTime,
                deliveryCost: deliveryCost,
              ),
            ),
          ),
        );
      } else if (value == 'delete') {
        deleteProduct(productId);
      } else if(value == 'addToFavorites'){
        HiveHelper.isProductInFavorites(productId, currentUser.username).then((exists) {
          if (exists) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Продукт уже в избранном')),
            );
          } else {
            final favoriteProduct = FavoriteProduct('unique_favorite_id', productId, currentUser.username);
            HiveHelper.addFavoriteProduct(favoriteProduct).then((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Продукт добавлен в избранное')),
              );
            }).catchError((error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Ошибка: $error')),
              );
              print('Ошибка: $error');
            });
          }
        }).catchError((error) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка проверки: $error')),
          );
          print('Ошибка проверки: $error');
        });
      }
    });
  }

  void deleteProduct(String productId) {
    final box = Hive.box<Product>('products');
    box.delete(productId);
    onProductUpdated();
  }
}

