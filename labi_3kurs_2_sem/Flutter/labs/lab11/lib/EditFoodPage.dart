import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'FoodItem.dart';

class EditFoodItemPage extends StatefulWidget {
  final FoodItem foodItem;

  const EditFoodItemPage({Key? key, required this.foodItem}) : super(key: key);

  @override
  _EditFoodItemPageState createState() => _EditFoodItemPageState();
}

class _EditFoodItemPageState extends State<EditFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _imageUrlController;
  late TextEditingController _titleController;
  late TextEditingController _subtitleController;
  late TextEditingController _priceController;
  bool _isPro = false;
  bool _isHot = false;

  @override
  void initState() {
    super.initState();
    _imageUrlController = TextEditingController(text: widget.foodItem.imageUrl);
    _titleController = TextEditingController(text: widget.foodItem.title);
    _subtitleController = TextEditingController(text: widget.foodItem.subtitle);
    _priceController = TextEditingController(text: widget.foodItem.price);
    _isPro = widget.foodItem.isPro;
    _isHot = widget.foodItem.isHot;
  }

  Future<void> _editFoodItem() async {
    if (_formKey.currentState!.validate()) {
      final updatedFoodItem = FoodItem(
        id: widget.foodItem.id,
        imageUrl: _imageUrlController.text,
        title: _titleController.text,
        subtitle: _subtitleController.text,
        price: _priceController.text,
        isPro: _isPro,
        isHot: _isHot,
      );

      await updateFoodItem(updatedFoodItem.id,updatedFoodItem);
      Navigator.pop(context);
    }
  }

  @override
  void dispose() {
    // Освобождение ресурсов контроллеров
    _imageUrlController.dispose();
    _titleController.dispose();
    _subtitleController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Food Item'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _imageUrlController,
                decoration: InputDecoration(labelText: 'Image URL'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter an image URL';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _subtitleController,
                decoration: InputDecoration(labelText: 'Subtitle'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a subtitle';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: 'Price'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a price';
                  }
                  return null;
                },
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isPro,
                    onChanged: (value) {
                      setState(() {
                        _isPro = value!;
                      });
                    },
                  ),
                  Text('Pro Item'),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Checkbox(
                    value: _isHot,
                    onChanged: (value) {
                      setState(() {
                        _isHot = value!;
                      });
                    },
                  ),
                  Text('Hot Item'),
                ],
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _editFoodItem,
                child: Text('Update Food Item'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}