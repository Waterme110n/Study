import 'package:flutter/material.dart';
import 'Messager.dart';
import 'database.dart';

class UserForm extends StatefulWidget {
  final User? user;

  UserForm({this.user});

  @override
  _UserFormState createState() => _UserFormState();
}

class _UserFormState extends State<UserForm> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  final _formKey = GlobalKey<FormState>();
  late String _id;
  late String _name;
  late String _email;
  late String _status;

  @override
  void initState() {
    super.initState();
    if (widget.user != null) {
      _id = widget.user!.id;
      _name = widget.user!.name;
      _email = widget.user!.email;
      _status = widget.user!.status;
    } else {
      _id = DateTime.now().toString();
      _name = '';
      _email = '';
      _status = 'Онлайн';
    }
  }

  void _saveUser() async {
    if (_formKey.currentState!.validate()) {
      User user = User(id: _id, name: _name, email: _email, status: _status);
      if (widget.user == null) {
        await _databaseHelper.insertUser(user);
      } else {
        await _databaseHelper.updateUser(user);
      }
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.user == null ? 'Добавить Пользователя' : 'Редактировать Пользователя'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                initialValue: _name,
                decoration: InputDecoration(labelText: 'Имя'),
                onChanged: (value) {
                  _name = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите имя';
                  }
                  return null;
                },
              ),
              TextFormField(
                initialValue: _email,
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (value) {
                  _email = value;
                },
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Введите email';
                  }
                  return null;
                },
              ),
              DropdownButtonFormField<String>(
                value: _status,
                decoration: InputDecoration(labelText: 'Статус'),
                onChanged: (value) {
                  setState(() {
                    _status = value!;
                  });
                },
                items: ['Онлайн', 'Неактивен', 'Офлайн']
                    .map((status) => DropdownMenuItem(
                  value: status,
                  child: Text(status),
                ))
                    .toList(),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveUser,
                child: Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}