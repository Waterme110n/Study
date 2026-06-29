import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'Product.dart';

class EditDishScreen extends StatefulWidget {
  final Function() onProductUpdated;
  final Product product; // Продукт для редактирования

  EditDishScreen({required this.onProductUpdated, required this.product});

  @override
  _EditDishScreenState createState() => _EditDishScreenState();
}

class _EditDishScreenState extends State<EditDishScreen> {
  final _formKey = GlobalKey<FormState>();
  late String imageUrl;
  late String title;
  late String subtitle;
  late String description;
  late String price;
  late bool isPro;
  late bool isHot;
  late String deliveryTime;
  late double deliveryCost;

  @override
  void initState() {
    super.initState();
    imageUrl = widget.product.imageUrl;
    title = widget.product.title;
    subtitle = widget.product.subtitle;
    description = widget.product.description;
    price = widget.product.price;
    isPro = widget.product.isPro;
    isHot = widget.product.isHot;
    deliveryTime = widget.product.deliveryTime;
    deliveryCost = widget.product.deliveryCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Редактировать блюдо')),
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
                initialValue: imageUrl,
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
                initialValue: title,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Подзаголовок'),
                onChanged: (value) {
                  subtitle = value;
                },
                initialValue: subtitle,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Описание'),
                onChanged: (value) {
                  description = value;
                },
                initialValue: description,
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
                initialValue: price,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Время доставки'),
                onChanged: (value) {
                  deliveryTime = value;
                },
                initialValue: deliveryTime,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Стоимость доставки'),
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  deliveryCost = double.tryParse(value) ?? 0;
                },
                initialValue: deliveryCost.toString(),
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
                    updateProduct();
                    widget.onProductUpdated();
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

  void updateProduct() {
    final product = Product(
      productId: widget.product.productId,
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

    final box = Hive.box<Product>('products');
    box.put(product.productId, product);
  }

}