import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'Product.dart';
import 'encode.dart';

class CreateDishScreen extends StatefulWidget {
  final Function() onProductCreated;

  CreateDishScreen({required this.onProductCreated});

  @override
  _CreateDishScreenState createState() => _CreateDishScreenState();
}

class _CreateDishScreenState extends State<CreateDishScreen> {
  final _formKey = GlobalKey<FormState>();
  String imageUrl = '';
  String title = '';
  String subtitle = '';
  String description = '';
  String price = '';
  bool isPro = false;
  bool isHot = false;
  String deliveryTime = '';
  double deliveryCost = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Создать блюдо')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'URL изображения'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите URL изображения';
                  }
                  return null;
                },
                onChanged: (value) {
                  imageUrl = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Название'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите название';
                  }
                  return null;
                },
                onChanged: (value) {
                  title = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Подзаголовок'),
                onChanged: (value) {
                  subtitle = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Описание'), // Поле для описания
                onChanged: (value) {
                  description = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Цена'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите цену';
                  }
                  return null;
                },
                onChanged: (value) {
                  price = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Время доставки'),
                onChanged: (value) {
                  deliveryTime = value;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Стоимость доставки'),
                keyboardType: TextInputType.number, // Для ввода чисел
                onChanged: (value) {
                  deliveryCost = double.tryParse(value) ?? 0;
                },
              ),
              SwitchListTile(
                title: Text('Входит в профессиональный пакет?'),
                value: isPro,
                onChanged: (value) {
                  setState(() {
                    isPro = value;
                  });
                },
              ),
              SwitchListTile(
                title: Text('Острый'),
                value: isHot,
                onChanged: (value) {
                  setState(() {
                    isHot = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    saveProduct(useSecondKey: true);
                    widget.onProductCreated();
                    Navigator.pop(context);
                  }
                },
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> saveProduct({required bool useSecondKey}) async {
    final product = Product(
      productId: DateTime.now().toString(),
      description: description,
      imageUrl: imageUrl,
      title: title,
      subtitle: subtitle,
      price: price,
      isPro: isPro,
      isHot: isHot,
      deliveryTime: deliveryTime,
      deliveryCost: deliveryCost,
    );
    final encryptionKey = await getEncryptionKey(useSecondKey: useSecondKey);
    final encryptedBox = await Hive.openBox<Product>(
      'products',
      encryptionCipher: HiveAesCipher(encryptionKey),
    );
    await encryptedBox.put(product.productId, product);
  }
}