import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Keanu Reeves Whoa',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: KeanuReevesPage(),
    );
  }
}

class KeanuReevesPage extends StatefulWidget {
  @override
  _KeanuReevesPageState createState() => _KeanuReevesPageState();
}

class _KeanuReevesPageState extends State<KeanuReevesPage> {
  String? imageUrl;
  String? videoUrl;
  List<Map<String, String>> favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final favoritesList = prefs.getStringList('favorites') ?? [];
    setState(() {
      favorites = favoritesList.map((item) => Map<String, String>.from(json.decode(item))).toList();
    });
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favorites',
      favorites.map((item) => json.encode(item)).toList(),
    );
  }

  Future<void> fetchData() async {
    try {
      final response = await http.get(Uri.parse('https://whoa.onrender.com/whoas/random'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is List && data.isNotEmpty && data[0] is Map) {
          final movieData = data[0] as Map<String, dynamic>;
          setState(() {
            imageUrl = movieData['poster'];
            videoUrl = movieData['video']['1080p'];
          });
          return;
        }
      }
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка при получении данных'))
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: ${e.toString()}'))
      );
    }
  }

  Future<void> saveFavorite() async {
    if (imageUrl != null && videoUrl != null) {
      final newFavorite = {
        'imageUrl': imageUrl!,
        'videoUrl': videoUrl!,
      };

      bool isDuplicate = favorites.any((item) =>
      item['imageUrl'] == newFavorite['imageUrl'] &&
          item['videoUrl'] == newFavorite['videoUrl']);

      if (isDuplicate) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Уже в избранном'))
        );
        return;
      }

      setState(() {
        favorites.add(newFavorite);
      });

      await _saveFavorites();

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Добавлено в избранное'))
      );
    }
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Keanu Reeves Whoa'),
        actions: [
          IconButton(
            icon: Icon(Icons.list),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => FavoritesPage(
                    favorites: favorites,
                    onRemove: (index) async {
                      setState(() {
                        favorites.removeAt(index);
                      });
                      await _saveFavorites();
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null)
              Expanded(
                child: Image.network(
                  imageUrl!,
                  fit: BoxFit.contain,
                ),
              ),
            if (videoUrl != null)
              ElevatedButton(
                onPressed: () => _launchURL(videoUrl!),
                child: Text('Смотреть видео'),
              ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: fetchData,
                  child: Text('Новый экземпляр'),
                ),
                SizedBox(width: 20),
                ElevatedButton(
                  onPressed: saveFavorite,
                  child: Text('В избранное'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class FavoritesPage extends StatefulWidget {
  final List<Map<String, String>> favorites;
  final Function(int) onRemove;

  const FavoritesPage({
    Key? key,
    required this.favorites,
    required this.onRemove,
  }) : super(key: key);

  @override
  _FavoritesPageState createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  late List<Map<String, String>> _currentFavorites;

  @override
  void initState() {
    super.initState();
    _currentFavorites = List.from(widget.favorites);
  }

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch $uri');
    }
  }

  void _removeItem(int index) async {
    widget.onRemove(index);
    setState(() {
      _currentFavorites.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Избранное'),
      ),
      body: _currentFavorites.isEmpty
          ? Center(child: Text('Нет избранных элементов'))
          : ListView.builder(
        itemCount: _currentFavorites.length,
        itemBuilder: (context, index) {
          final item = _currentFavorites[index];
          return Card(
            margin: EdgeInsets.all(8),
            child: Column(
              children: [
                Image.network(
                  item['imageUrl']!,
                  fit: BoxFit.contain,
                ),
                Padding(
                  padding: EdgeInsets.all(8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      ElevatedButton(
                        onPressed: () => _launchURL(item['videoUrl']!),
                        child: Text('Смотреть видео'),
                      ),
                      ElevatedButton(
                        onPressed: () => _removeItem(index),
                        child: Text('Удалить'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}