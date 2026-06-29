import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/firebase_service.dart';
import '../../services/notification_service.dart';
import '../../models/medicine.dart';
import '../auth/login_screen.dart';
import '../home/home_screen.dart';
import '../statistics/statistics_screen.dart';
import '../stock/stock_screen.dart';
import 'medicine_instruction_screen.dart';
import 'package:url_launcher/url_launcher.dart';

// Типы источников данных
enum DataSourceFilter {
  all,           // только drugs (общая база)
  personal,      // только users/{uid}/medicines (личные)
  both,          // и drugs, и личные
}

class MedicinesCatalogScreen extends StatefulWidget {
  const MedicinesCatalogScreen({super.key});

  @override
  State<MedicinesCatalogScreen> createState() => _MedicinesCatalogScreenState();
}

class _MedicinesCatalogScreenState extends State<MedicinesCatalogScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  bool _isSearching = false;

  // Текущий выбранный источник данных (по умолчанию both)
  DataSourceFilter _dataSourceFilter = DataSourceFilter.both;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _isSearching = _searchQuery.isNotEmpty;
    });
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _isSearching = false;
    });
  }

  /// Показать диалог выбора источника данных
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                'Источник данных',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
            const Divider(height: 24),
            _buildFilterOption(
              title: 'Общая база',
              subtitle: 'Только из общей базы',
              icon: Icons.medication,
              filter: DataSourceFilter.all,
              isSelected: _dataSourceFilter == DataSourceFilter.all,
            ),
            _buildFilterOption(
              title: 'Личная база',
              subtitle: 'Только из вашей личной коллекции',
              icon: Icons.person,
              filter: DataSourceFilter.personal,
              isSelected: _dataSourceFilter == DataSourceFilter.personal,
            ),
            _buildFilterOption(
              title: 'Все',
              subtitle: 'Объединённый список лекарств',
              icon: Icons.merge_type,
              filter: DataSourceFilter.both,
              isSelected: _dataSourceFilter == DataSourceFilter.both,
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                style: TextButton.styleFrom(
                  foregroundColor: Colors.grey[600],
                ),
                child: const Text('Закрыть'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption({
    required String title,
    required String subtitle,
    required IconData icon,
    required DataSourceFilter filter,
    required bool isSelected,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: isSelected ? Colors.blue : Colors.grey[200],
        child: Icon(icon, color: isSelected ? Colors.white : Colors.grey[600], size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? Colors.blue : null,
        ),
      ),
      subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: isSelected
          ? Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check, color: Colors.white, size: 16),
      )
          : null,
      onTap: () {
        setState(() {
          _dataSourceFilter = filter;
        });
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Все лекарства'),
        centerTitle: true,
        // Кнопка фильтра справа
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 8),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                  tooltip: 'Выбрать источник данных',
                ),
              ],
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Поиск лекарств...',
                prefixIcon: const Icon(Icons.search, color: Colors.grey),
                suffixIcon: _searchQuery.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey),
                  onPressed: _clearSearch,
                )
                    : null,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
              ),
            ),
          ),
        ),
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue, Colors.blueAccent],
            ),
          ),
        ),
      ),
      drawer: _buildDrawer(firebaseService),
      body: Container(
        color: Colors.grey[50],
        child: _isSearching
            ? _buildSearchResults(firebaseService)
            : _buildMedicinesByFilter(firebaseService),
      ),
    );
  }

  /// Построение списка в зависимости от выбранного фильтра
  Widget _buildMedicinesByFilter(FirebaseService firebaseService) {
    switch (_dataSourceFilter) {
      case DataSourceFilter.all:
      // Только из drugs
        return _buildPublicMedicines(firebaseService);
      case DataSourceFilter.personal:
      // Только из users/{uid}/medicines
        return _buildPersonalMedicines(firebaseService);
      case DataSourceFilter.both:
      // Объединённый список
        return _buildBothMedicines(firebaseService);
    }
  }

  /// Только общие лекарства (drugs)
  Widget _buildPublicMedicines(FirebaseService firebaseService) {
    return StreamBuilder<List<Medicine>>(
      stream: firebaseService.getPublicMedicines(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Ошибка загрузки: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return _buildLoadingWidget('Загрузка общих лекарств...');
        }

        final medicines = snapshot.data!;
        if (medicines.isEmpty) {
          return _buildEmptyWidget('Общая база лекарств пуста');
        }

        return _buildMedicinesList(medicines, firebaseService);
      },
    );
  }

  /// Только личные лекарства (users/{uid}/medicines)
  Widget _buildPersonalMedicines(FirebaseService firebaseService) {
    return StreamBuilder<List<Medicine>>(
      stream: firebaseService.getPersonalMedicines(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return _buildErrorWidget('Ошибка загрузки: ${snapshot.error}');
        }
        if (!snapshot.hasData) {
          return _buildLoadingWidget('Загрузка ваших лекарств...');
        }

        final medicines = snapshot.data!;
        if (medicines.isEmpty) {
          return _buildEmptyWidget(
            'У вас пока нет собственных лекарств',
            subtitle: 'Добавьте лекарство на странице "Мои лекарства"',
          );
        }

        return _buildMedicinesList(medicines, firebaseService);
      },
    );
  }

  /// Объединённый список (drugs + личные)
  Widget _buildBothMedicines(FirebaseService firebaseService) {
    return StreamBuilder<List<Medicine>>(
      stream: firebaseService.getPublicMedicines(),
      builder: (context, publicSnapshot) {
        if (!publicSnapshot.hasData) {
          return _buildLoadingWidget('Загрузка...');
        }

        return StreamBuilder<List<Medicine>>(
          stream: firebaseService.getPersonalMedicines(),
          builder: (context, personalSnapshot) {
            final List<Medicine> allMedicines = [];

            // Добавляем общие лекарства
            if (publicSnapshot.hasData && publicSnapshot.data != null) {
              allMedicines.addAll(publicSnapshot.data!);
            }

            // Добавляем личные лекарства
            if (personalSnapshot.hasData && personalSnapshot.data != null) {
              allMedicines.addAll(personalSnapshot.data!);
            }

            // Сортируем по названию
            allMedicines.sort((a, b) => a.name.compareTo(b.name));

            if (allMedicines.isEmpty) {
              return _buildEmptyWidget('Список лекарств пуст');
            }

            return _buildMedicinesList(allMedicines, firebaseService);
          },
        );
      },
    );
  }

  /// Поиск с учётом выбранного фильтра
  Widget _buildSearchResults(FirebaseService firebaseService) {
    return FutureBuilder<List<Medicine>>(
      future: _searchMedicinesWithFilter(firebaseService, _searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingWidget('Поиск...');
        }

        if (snapshot.hasError) {
          return _buildErrorWidget('Ошибка поиска: ${snapshot.error}');
        }

        final medicines = snapshot.data ?? [];

        if (medicines.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Ничего не найдено для "$_searchQuery"',
                  style: TextStyle(color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                Text(
                  'Попробуйте изменить запрос',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          );
        }

        return _buildMedicinesList(medicines, firebaseService);
      },
    );
  }

  /// Поиск с учётом выбранного источника данных
  Future<List<Medicine>> _searchMedicinesWithFilter(
      FirebaseService firebaseService,
      String query,
      ) async {
    final List<Medicine> results = [];

    switch (_dataSourceFilter) {
      case DataSourceFilter.all:
      // Ищем только в drugs
        final publicResults = await firebaseService.searchPublicMedicines(query);
        results.addAll(publicResults);
        break;

      case DataSourceFilter.personal:
      // Ищем только в личных
        final personalResults = await firebaseService.searchPersonalMedicines(query);
        results.addAll(personalResults);
        break;

      case DataSourceFilter.both:
      // Ищем везде и объединяем
        final [publicResults, personalResults] = await Future.wait([
          firebaseService.searchPublicMedicines(query),
          firebaseService.searchPersonalMedicines(query),
        ]);
        results.addAll(publicResults);
        results.addAll(personalResults);
        break;
    }

    // Сортируем по названию
    results.sort((a, b) => a.name.compareTo(b.name));
    return results;
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ ВИДЖЕТЫ ====================

  Widget _buildLoadingWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(message),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyWidget(String message, {String subtitle = ''}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.medication, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(color: Colors.grey[600]),
          ),
          if (subtitle.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMedicinesList(List<Medicine> medicines, FirebaseService firebaseService) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: medicines.length,
      itemBuilder: (context, index) {
        return _buildMedicineCard(medicines[index], firebaseService);
      },
    );
  }

  /// Построение Drawer
  Widget _buildDrawer(FirebaseService firebaseService) {
    return Drawer(
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
            title: const Text('Мои лекарства',),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.library_books, color: Colors.blue),
            title: const Text('Все лекарства', style: TextStyle(fontWeight: FontWeight.w500),),
            selected: true,
            selectedTileColor: Colors.blue.shade50,
            onTap: () => Navigator.pop(context),
          ),
          ListTile(
            leading: const Icon(Icons.inventory, color: Colors.grey),
            title: const Text('В наличии'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const StockScreen()),
              );
            },
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
          // Пункт 4: Выход
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text(
              'Выход',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await NotificationService().cancelAllNotifications();
              await firebaseService.signOut();
              if (context.mounted) {
                Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
              }
            },
          ),
        ],
      ),
    );
  }

  /// Карточка лекарства
  Widget _buildMedicineCard(Medicine medicine, FirebaseService firebaseService) {
    final bool isPersonal = medicine.isPersonal ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => showMedicineDetails(medicine, firebaseService),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Иконка с индикатором типа
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  gradient: isPersonal
                      ? const LinearGradient(colors: [Colors.green, Colors.greenAccent])
                      : const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPersonal ? Icons.person : Icons.medication,
                  color: Colors.white,
                  size: 28,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            medicine.name,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isPersonal)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.green.shade100,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Моё',
                              style: TextStyle(fontSize: 10, color: Colors.green.shade800, fontWeight: FontWeight.w500),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    if (medicine.genericName != null && medicine.genericName!.isNotEmpty)
                      Text(
                        medicine.genericName!,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 8,
                      runSpacing: 6,
                      children: [
                        if (medicine.dosageForm != null && medicine.dosageForm!.isNotEmpty)
                          _buildInfoChip(Icons.medical_services, medicine.dosageForm!),
                        if (medicine.dosage != null && medicine.dosage!.isNotEmpty)
                          _buildInfoChip(Icons.speed, medicine.dosage!),
                        if (medicine.manufacturer != null && medicine.manufacturer!.isNotEmpty)
                          _buildInfoChip(Icons.business, medicine.manufacturer!),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: 12, color: Colors.grey[700]),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  void showMedicineDetails(Medicine medicine, FirebaseService firebaseService) {
    final bool isPersonal = medicine.isPersonal ?? false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.4,
        maxChildSize: 0.8,
        expand: false,
        builder: (context, scrollController) {
          final moreInfo = medicine.moreInfo ?? {};
          final String? buyUrl = medicine.sourceUrl;
          final String? instructionUrl = moreInfo['source_url'] as String?;

          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Полоска для свайпа
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // 👇 СТРОКА С НАЗВАНИЕМ И КНОПКАМИ
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Иконка
                    Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        gradient: isPersonal
                            ? const LinearGradient(colors: [Colors.green, Colors.greenAccent])
                            : const LinearGradient(colors: [Colors.blue, Colors.blueAccent]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isPersonal ? Icons.person : Icons.medication,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Название и кнопки
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  medicine.name,
                                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              if (isPersonal) ...[
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context); // закрываем BottomSheet
                                    _showEditMedicineDialog(medicine, firebaseService);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(Icons.edit, color: Colors.blue[600], size: 20),
                                  ),
                                ),
                                // Кнопка удаления
                                InkWell(
                                  onTap: () {
                                    Navigator.pop(context); // закрываем BottomSheet
                                    _confirmDeleteMedicine(medicine, firebaseService);
                                  },
                                  borderRadius: BorderRadius.circular(20),
                                  child: Container(
                                    padding: const EdgeInsets.all(8),
                                    child: Icon(Icons.delete, color: Colors.red[400], size: 20),
                                  ),
                                ),
                              ],
                            ],
                          ),
                          if (medicine.genericName != null && medicine.genericName!.isNotEmpty)
                            Text(
                              medicine.genericName!,
                              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // Кнопки "Инструкция" и "Где купить?"
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: instructionUrl != null && instructionUrl.isNotEmpty
                            ? () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MedicineInstructionScreen(
                                medicineName: medicine.name,
                                moreInfo: moreInfo,
                                sourceUrl: instructionUrl,
                              ),
                            ),
                          );
                        }
                            : null,
                        icon: const Icon(Icons.description, size: 18),
                        label: const Text('Инструкция'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: buyUrl != null && buyUrl.isNotEmpty
                            ? () => _launchBuyUrl(buyUrl, context)
                            : null,
                        icon: const Icon(Icons.shopping_cart, size: 18),
                        label: const Text('Где купить?'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),
                const Divider(),
                const SizedBox(height: 12),

                // Детальная информация
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      if (medicine.dosageForm != null && medicine.dosageForm!.isNotEmpty)
                        _buildDetailRow(Icons.medical_services, 'Форма выпуска', medicine.dosageForm),
                      if (medicine.dosage != null && medicine.dosage!.isNotEmpty)
                        _buildDetailRow(Icons.speed, 'Дозировка', medicine.dosage),
                      if (medicine.manufacturer != null && medicine.manufacturer!.isNotEmpty)
                        _buildDetailRow(Icons.business, 'Производитель', medicine.manufacturer),
                      if (medicine.country != null && medicine.country!.isNotEmpty)
                        _buildDetailRow(Icons.location_on, 'Страна', medicine.country),
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

  /// Диалог подтверждения удаления
  Future<void> _confirmDeleteMedicine(Medicine medicine, FirebaseService firebaseService) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить лекарство?'),
        content: Text('Вы уверены, что хотите удалить "${medicine.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await firebaseService.deletePersonalMedicine(medicine.id!);
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Лекарство удалено'), backgroundColor: Colors.green),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  /// Диалог редактирования лекарства
  void _showEditMedicineDialog(Medicine medicine, FirebaseService firebaseService) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: medicine.name);
    final genericNameController = TextEditingController(text: medicine.genericName ?? '');
    final dosageController = TextEditingController(text: medicine.dosage ?? '');
    final dosageFormController = TextEditingController(text: medicine.dosageForm ?? '');
    final manufacturerController = TextEditingController(text: medicine.manufacturer ?? '');
    final countryController = TextEditingController(text: medicine.country ?? '');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Редактировать лекарство',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 20),

                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Название *',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) => value == null || value.isEmpty ? 'Введите название' : null,
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: genericNameController,
                  decoration: const InputDecoration(
                    labelText: 'Международное название',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Дозировка',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: dosageFormController,
                  decoration: const InputDecoration(
                    labelText: 'Форма выпуска',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: manufacturerController,
                  decoration: const InputDecoration(
                    labelText: 'Производитель',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),

                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(
                    labelText: 'Страна',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Отмена'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          if (formKey.currentState!.validate()) {
                            final updatedMedicine = medicine.copyWith(
                              name: nameController.text.trim(),
                              genericName: genericNameController.text.trim().isEmpty
                                  ? null
                                  : genericNameController.text.trim(),
                              dosage: dosageController.text.trim().isEmpty
                                  ? null
                                  : dosageController.text.trim(),
                              dosageForm: dosageFormController.text.trim().isEmpty
                                  ? null
                                  : dosageFormController.text.trim(),
                              manufacturer: manufacturerController.text.trim().isEmpty
                                  ? null
                                  : manufacturerController.text.trim(),
                              country: countryController.text.trim().isEmpty
                                  ? null
                                  : countryController.text.trim(),
                            );

                            try {
                              await firebaseService.updatePersonalMedicine(updatedMedicine);
                              if (context.mounted) {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Лекарство обновлено'), backgroundColor: Colors.green),
                                );
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
                                );
                              }
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Сохранить'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _launchBuyUrl(String url, BuildContext context) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Не удалось открыть ссылку')),
          );
        }
      }
    } catch (e) {
      print('Ошибка: $e');
    }
  }

  Widget _buildDetailRow(IconData icon, String label, String? value, {Color? color}) {
    if (value == null || value.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color ?? Colors.blue),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                const SizedBox(height: 2),
                Text(value, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}