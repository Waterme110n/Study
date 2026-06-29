import 'dart:io';

import 'package:flutter/material.dart';
import 'Messager.dart';
import 'database.dart';
import 'Users_form.dart';
import 'FileManager.dart';


void main() {
  runApp(MyApp());
  runMessengerLogic();
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Список Пользователей',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: UserListScreen(),

    );
  }
}

class UserListScreen extends StatefulWidget {
  @override
  _UserListScreenState createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final DatabaseHelper _databaseHelper = DatabaseHelper();
  List<User> _users = [];
  String _sortOrder = 'name';

  @override
  void initState() {
    super.initState();
    _loadUsers();
    checkPlatform();
  }

  void checkPlatform() {
    if (Platform.isAndroid) {
      print("Это Android");
    } else if (Platform.isIOS) {
      print("Это iOS");
    } else {
      print("Это другая платформа");
    }
  }

  _loadUsers() async {
    _users = await _databaseHelper.getUsers(orderBy: _sortOrder);
    setState(() {});
  }

  void _changeSortOrder(String? newOrder) {
    setState(() {
      _sortOrder = newOrder!;
      _loadUsers();
    });
  }


  _addUser() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserForm()),
    ).then((_) => _loadUsers());
  }

  _editUser(User user) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => UserForm(user: user)),
    ).then((_) => _loadUsers());
  }

  _deleteUser(String id) async {
    await _databaseHelper.deleteUser(id);
    _loadUsers();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('SQlite'),
        actions: [
          IconButton(icon: Icon(Icons.add), onPressed: _addUser),
          DropdownButton<String>(
            value: _sortOrder,
            items: [
              DropdownMenuItem(value: 'name', child: Text('Сортировать по имени')),
              DropdownMenuItem(value: 'email', child: Text('Сортировать по email')),
              // Добавьте другие параметры сортировки, если нужно
            ],
            onChanged: _changeSortOrder,
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _users.length,
        itemBuilder: (context, index) {
          final user = _users[index];
          return ListTile(
            title: Text(user.name),
            subtitle: Text('${user.email} - ${user.status}'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(icon: Icon(Icons.edit), onPressed: () => _editUser(user)),
                IconButton(icon: Icon(Icons.delete), onPressed: () => _deleteUser(user.id)),
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailScreen(user: user),
                      ),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}



class UserDetailScreen extends StatefulWidget {
  final User user;

  UserDetailScreen({required this.user});

  @override
  _UserDetailScreenState createState() => _UserDetailScreenState();
}

class _UserDetailScreenState extends State<UserDetailScreen> {
  final FileManager _fileManager = FileManager();
  String _loadedData = '';
  String _selectedDirectory = 'Application Documents';

  void _saveUserData(BuildContext context) async {
    try {
      await _fileManager.writeUserData(widget.user, _selectedDirectory);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Данные пользователя сохранены!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка сохранения: $e')));
      print('Ошибка сохранения: $e');
    }
  }

  void _loadUserData(BuildContext context) async {
    try {
      String data = await _fileManager.readUserData(widget.user.id, _selectedDirectory);
      setState(() {
        _loadedData = data;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Данные пользователя загружены!')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Ошибка загрузки: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.user.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Имя: ${widget.user.name}', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            SizedBox(height: 16),
            Text('Email: ${widget.user.email}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 16),
            Text('Статус: ${widget.user.status}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 20),
            DropdownButton<String>(
              value: _selectedDirectory,
              items: [
                DropdownMenuItem(value: 'Temporary', child: Text('Temporary')),
                DropdownMenuItem(value: 'Application Documents', child: Text('Application Documents')),
                DropdownMenuItem(value: 'Application Support', child: Text('Application Support')),
                DropdownMenuItem(value: 'Application Library', child: Text('Application Library')),
                DropdownMenuItem(value: 'Application Cache', child: Text('Application Cache')),
                DropdownMenuItem(value: 'External Storage', child: Text('External Storage')),
                DropdownMenuItem(value: 'External Cache Directories', child: Text('External Cache Directories')),
                DropdownMenuItem(value: 'External Storage Directories', child: Text('External Storage Directories')),
                DropdownMenuItem(value: 'Downloads', child: Text('Downloads')),
              ],
              onChanged: (value) {
                setState(() {
                  _selectedDirectory = value!;
                });
              },
            ),
            ElevatedButton(
              onPressed: () => _saveUserData(context),
              child: Text('Сохранить данные пользователя'),
            ),
            ElevatedButton(
              onPressed: () => _loadUserData(context),
              child: Text('Загрузить данные пользователя'),
            ),
            SizedBox(height: 20),
            Text(
              _loadedData,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
            ),
          ],
        ),
      ),
    );
  }
}


