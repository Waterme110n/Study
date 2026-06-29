import 'package:flutter/material.dart';
import 'FoodItem.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:image_picker/image_picker.dart';

class AddFoodItemPage extends StatefulWidget {
  @override
  _AddFoodItemPageState createState() => _AddFoodItemPageState();
}

class _AddFoodItemPageState extends State<AddFoodItemPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _subtitleController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  bool _isPro = false;
  bool _isHot = false;
  String? _base64Image;
  Offset buttonPosition = Offset(150, 500);

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? imageFile = await picker.pickImage(source: ImageSource.gallery);

    if (imageFile != null) {
      _base64Image = await convertImageToBase64(imageFile);
      setState(() {});
    }
  }

  Future<void> _addFoodItem() async {
    if (_formKey.currentState!.validate()) {
      final foodItem = FoodItem(
        id: '',
        imageUrl: _base64Image!,
        title: _titleController.text,
        subtitle: _subtitleController.text,
        price: _priceController.text,
        isPro: _isPro,
        isHot: _isHot,
      );

      await addFoodItem(foodItem);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please select an image')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Food Item'),
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        width: double.infinity,
                        height: 200,
                        child: _base64Image == null
                            ? Center(child: Text('Tap to select an image'))
                            : Image.memory(
                          base64Decode(_base64Image!),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
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
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: buttonPosition.dx,
            top: buttonPosition.dy,
            child: Draggable(
              feedback: Material(
                child: ElevatedButton(
                  onPressed: null,
                  child: Text('Add'),
                ),
              ),
              childWhenDragging: Container(),
              child: ElevatedButton(
                onPressed: _addFoodItem,
                child: Text('Add'),
              ),
              onDragEnd: (details) {
                setState(() {
                  buttonPosition = details.offset;
                });
              },
            ),
          ),
        ],
      ),
    );
  }
}

Future<String> convertImageToBase64(XFile imageFile) async {
  Uint8List imageBytes = await imageFile.readAsBytes();
  return base64Encode(imageBytes);
}