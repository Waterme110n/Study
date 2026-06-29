import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../services/firebase_service.dart';
import '../../models/schedule.dart';
import '../../widgets/schedule_card.dart';
import '../statistics/statistics_screen.dart';
import '../stock/stock_screen.dart';
import 'add_schedule_screen.dart';
import '../drugs/medicines_screen.dart';
import '../auth/login_screen.dart';
import '../../services/notification_service.dart';
import '../../services/widget_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  DateTime _selectedDate = DateTime.now();
  Key _scheduleListKey = UniqueKey();

  // Флаг для предотвращения повторных вызовов
  bool _isCheckingMissedIntakes = false;
  bool _isFirstCheckDone = false;
  bool _isGuest = false;
  bool _isInitialized = false;

  void _updateDate(DateTime newDate) {
    setState(() {
      _selectedDate = newDate;
      _scheduleListKey = UniqueKey();
    });
  }


  Future<void> _requestNotificationPermission() async {
    await NotificationService().requestPermissions();
  }

  Future<void> _scheduleAllNotifications() async {
    if (!mounted) return;
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final schedules = await firebaseService.getSchedules().first;
    await NotificationService().scheduleAllReminders(schedules);
  }

  Future<void> _updateWidgetData() async {
    if (!mounted) return;
    await WidgetService.updateWidgetData(context);
  }

  Future<void> _checkMissedIntakes() async {
    if (_isCheckingMissedIntakes || _isFirstCheckDone) return;

    _isCheckingMissedIntakes = true;

    try {
      final firebaseService = Provider.of<FirebaseService>(context, listen: false);
      await firebaseService.checkAndAddMissedIntakes();
      _isFirstCheckDone = true;
    } catch (e) {
      print('❌ Ошибка проверки пропусков: $e');
    } finally {
      _isCheckingMissedIntakes = false;
    }
  }

  Future<void> _initializeGuestMode() async {
    if (_isInitialized) {
      print('⚠️ Инициализация уже выполнена, пропускаем');
      return;
    }

    _isInitialized = true;
    print('🔧 Начинаем инициализацию гостевого режима...');

    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    // ДИАГНОСТИКА
    print('📊 Текущий пользователь: ${firebaseService.currentUser?.uid}');
    print('📊 isAnonymous: ${firebaseService.currentUser?.isAnonymous}');
    print('📊 email: ${firebaseService.currentUser?.email}');

    // Проверяем сохранённую сессию в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final savedUid = prefs.getString('user_uid');
    final wasLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    print('📊 Сохранённый UID: $savedUid');
    print('📊 Был ли вход ранее: $wasLoggedIn');

    if (firebaseService.currentUser == null && wasLoggedIn && savedUid != null) {
      print('⚠️ СЕССИЯ ПОТЕРЯНА! Был пользователь $savedUid, но Firebase его не нашёл');
      // Не входим как гость, показываем экран входа
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
        );
      }
      return;
    }

    // Проверяем, есть ли уже пользователь
    if (firebaseService.currentUser == null) {
      print('👤 Нет пользователя → входим как гость');
      await firebaseService.ensureLoggedIn();
    } else {
      print('👤 Пользователь уже есть, пропускаем гостевой вход');
    }

    if (mounted) {
      final isGuest = await firebaseService.isGuest();
      setState(() {
        _isGuest = isGuest;
      });
      print('✅ Инициализация завершена, isGuest = $isGuest');
    }
  }

  /// Показать диалог предложения входа для гостя
  void _showAuthDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Вход в аккаунт'),
        content: const Text(
          'Вы вошли как гость. Зарегистрируйтесь или войдите, чтобы:\n\n'
              '✓ Синхронизировать данные между устройствами\n'
              '✓ Использовать аптечку\n'
              '✓ Просматривать инструкции\n'
              '✓ Экспортировать отчёты',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Позже'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              if (mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                );
              }
            },
            child: const Text('Войти'),
          ),
        ],
      ),
    );
  }

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
            leading: const Icon(Icons.medication, color: Colors.blue),
            title: const Text('Мои лекарства', style: TextStyle(fontWeight: FontWeight.w500)),
            selected: true,
            selectedTileColor: Colors.blue.shade50,
            onTap: () => Navigator.pop(context),
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
    );
  }

  @override
  void initState() {
    super.initState();
    print('🏠 HomeScreen initState вызван');
    _initializeGuestMode().then((_) {
      if (mounted) {
        print('✅ После инициализации, выполняем остальные действия');
        _requestNotificationPermission();

        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            _checkMissedIntakes();
            _updateWidgetData();
          }
        });

        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            _scheduleAllNotifications();
          }
        });
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    print('🏠 HomeScreen dispose');
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Мои лекарства'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: _isGuest
            ? IconButton(
          icon: const Icon(Icons.login),
          onPressed: _showAuthDialog,
          tooltip: 'Войти или зарегистрироваться',
        )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: _showDatePicker,
            tooltip: 'Выбрать дату',
          ),
        ],
      ),
      drawer: !_isGuest ? _buildDrawer(firebaseService) : null,
      body: Column(
        children: [
          _buildCalendar(),
          Expanded(
            child: StreamBuilder<List<MedicineSchedule>>(
              key: _scheduleListKey,
              stream: firebaseService.getSchedules(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Ошибка: ${snapshot.error}'));
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final filteredSchedules = _filterSchedules(snapshot.data!);
                return _buildScheduleList(filteredSchedules, context);
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addSchedule(context),
        icon: const Icon(Icons.add),
        label: const Text('Добавить прием'),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildCalendar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
          ),
        ],
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _showDatePicker,
            child: Text(
              DateFormat('EEEE, d MMMM yyyy', 'ru').format(_selectedDate),
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDayButton(-3),
                _buildDayButton(-2),
                _buildDayButton(-1),
                _buildDayButton(0, isToday: true),
                _buildDayButton(1),
                _buildDayButton(2),
                _buildDayButton(3),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<MedicineSchedule> _filterSchedules(List<MedicineSchedule> schedules) {
    final selectedDateOnly = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
    );

    return schedules.where((schedule) {
      final startDateOnly = DateTime(
        schedule.startDate.year,
        schedule.startDate.month,
        schedule.startDate.day,
      );
      final endDateOnly = DateTime(
        schedule.endDate.year,
        schedule.endDate.month,
        schedule.endDate.day,
      );

      return (selectedDateOnly.isAfter(startDateOnly) ||
          selectedDateOnly.isAtSameMomentAs(startDateOnly)) &&
          (selectedDateOnly.isBefore(endDateOnly) ||
              selectedDateOnly.isAtSameMomentAs(endDateOnly));
    }).toList();
  }

  Widget _buildScheduleList(List<MedicineSchedule> schedules, BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Расписание приема',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${schedules.length} препаратов',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: schedules.isEmpty
              ? Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.medication_liquid, size: 80, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  'Нет расписаний на ${DateFormat('d MMMM', 'ru').format(_selectedDate)}',
                  style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => _addSchedule(context),
                  child: const Text('Добавить расписание'),
                ),
              ],
            ),
          )
              : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: schedules.length,
            itemBuilder: (context, index) {
              return ScheduleCard(
                schedule: schedules[index],
                date: _selectedDate,
                onIntakeRecorded: () async {
                  setState(() {});
                  await _updateWidgetData();
                },
                onScheduleUpdated: () {
                  setState(() {});
                  _checkMissedIntakes();
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildDayButton(int daysOffset, {bool isToday = false}) {
    DateTime date = _selectedDate.add(Duration(days: daysOffset));
    bool isSelected = daysOffset == 0;

    return GestureDetector(
      onTap: () => _updateDate(date),
      child: Container(
        width: 45,
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Theme.of(context).primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              DateFormat('E', 'ru').format(date).substring(0, 2),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              date.day.toString(),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showDatePicker() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      locale: const Locale('ru', 'RU'),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  void _addSchedule(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AddScheduleScreen()),
    ).then((_) async {
      await _scheduleAllNotifications();
      await _updateWidgetData();
      setState(() {});
    });
  }
}