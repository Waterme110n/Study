import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../models/stock.dart';
import '../../models/medicine.dart';
import '../../services/notification_service.dart';
import '../auth/login_screen.dart';
import '../drugs/medicines_screen.dart';
import '../home/home_screen.dart';
import '../statistics/statistics_screen.dart';
import 'add_stock_screen.dart';
import 'edit_stock_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  // Кэш для названий лекарств
  final Map<String, String> _medicineNames = {};

  Future<String> _getMedicineName(String medicineId) async {
    // Проверяем кэш
    if (_medicineNames.containsKey(medicineId)) {
      return _medicineNames[medicineId]!;
    }

    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    // 1. Ищем в личных лекарствах (users/{userId}/medicines)
    final personalMedicines = await firebaseService.getPersonalMedicines().first;
    final personalMatch = personalMedicines.firstWhere(
          (m) => m.id == medicineId,
      orElse: () => Medicine(id: medicineId, name: '', isPersonal: true),
    );

    if (personalMatch.id == medicineId && personalMatch.name.isNotEmpty) {
      _medicineNames[medicineId] = personalMatch.name;
      return personalMatch.name;
    }

    // 2. Ищем в общих лекарствах (drugs)
    final publicMedicines = await firebaseService.getPublicMedicines().first;
    final publicMatch = publicMedicines.firstWhere(
          (m) => m.id == medicineId,
      orElse: () => Medicine(id: medicineId, name: medicineId, isPersonal: false),
    );

    _medicineNames[medicineId] = publicMatch.name;
    return publicMatch.name;
  }

  Future<void> _deleteStock(Stock stock, String medicineName) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить из аптечки?'),
        content: Text(
          'Вы уверены, что хотите удалить "$medicineName (${stock.unit})" из аптечки?\n\n'
              'История остатков будет удалена, но лекарство останется в расписаниях.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      try {
        // Удаляем по stockId, а не по medicineId
        await firebaseService.deleteStockById(stock.stockId);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Лекарство удалено из аптечки'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Ошибка удаления: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Моя аптечка'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addToStock(),
            tooltip: 'Добавить лекарство',
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF36A5E5), Colors.blueAccent],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/icons/taking_medications.png',
                    width: 40,
                    height: 40,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Taking Medications',
                    style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Ваш помощник в приёме лекарств',
                    style: TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.medication, color: Colors.grey),
              title: const Text('Мои лекарства'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HomeScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.library_books, color: Colors.grey),
              title: const Text('Все лекарства'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MedicinesCatalogScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.inventory, color: Colors.blue),
              title: const Text('В наличии', style: TextStyle(fontWeight: FontWeight.w500)),
              selected: true,
              selectedTileColor: Colors.blue.shade50,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.bar_chart, color: Colors.grey),
              title: const Text('Статистика'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StatisticsScreen()),
                );
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Выход', style: TextStyle(color: Colors.red)),
              onTap: () async {
                await NotificationService().cancelAllNotifications();
                await firebaseService.signOut();
                if (context.mounted) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const LoginScreen()),
                  );
                }
              },
            ),
          ],
        ),
      ),
      body: StreamBuilder<List<Stock>>(
        stream: firebaseService.getStocks(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stocks = snapshot.data!;

          if (stocks.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inventory_2_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Аптечка пуста',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Добавьте лекарства, чтобы отслеживать запасы',
                    style: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => _addToStock(),
                    icon: const Icon(Icons.add),
                    label: const Text('Добавить лекарство'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: stocks.length,
            itemBuilder: (context, index) {
              final stock = stocks[index];
              return FutureBuilder<String>(
                future: _getMedicineName(stock.medicineId),
                builder: (context, nameSnapshot) {
                  final medicineName = nameSnapshot.data ?? stock.medicineId;
                  return _buildStockCard(
                    stock,
                    medicineName,
                    firebaseService,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStockCard(Stock stock, String medicineName, FirebaseService firebaseService) {
    final isOut = stock.currentAmount == 0;
    final isLow = stock.currentAmount <= 5 && stock.currentAmount > 0;

    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (isOut) {
      statusColor = Colors.red;
      statusIcon = Icons.warning;
      statusText = 'Закончилось';
    } else if (isLow) {
      statusColor = Colors.orange;
      statusIcon = Icons.info_outline;
      statusText = 'Мало';
    } else {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'В наличии';
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(statusIcon, color: statusColor, size: 28),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    medicineName,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  // Показываем единицу измерения вместе с количеством
                  Row(
                    children: [
                      Text(
                        '${stock.currentAmount}',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: statusColor,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          stock.unit,
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: statusColor,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    statusText,
                    style: TextStyle(fontSize: 12, color: statusColor),
                  ),
                ],
              ),
            ),
            // Кнопка редактирования (карандаш)
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue),
              onPressed: () => _editStock(stock, medicineName),
              tooltip: 'Изменить количество',
            ),
            // Кнопка удаления (мусорка)
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _deleteStock(stock, medicineName),
              tooltip: 'Удалить из аптечки',
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _addToStock() async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (context) => const AddToStockScreen()),
    );
    if (result == true && mounted) {
    }
  }

  Future<void> _editStock(Stock stock, String medicineName) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (context) => EditStockScreen(
          stock: stock,
          medicineName: medicineName,
        ),
      ),
    );
    if (result == true && mounted) {
    }
  }
}