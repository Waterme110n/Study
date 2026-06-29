import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../services/firebase_service.dart';
import '../../models/medicine.dart';
import '../../models/schedule.dart';
import '../drugs/add_medicine_screen.dart';
import '../stock/add_stock_screen.dart';

class AddScheduleScreen extends StatefulWidget {
  const AddScheduleScreen({super.key});

  @override
  State<AddScheduleScreen> createState() => _AddScheduleScreenState();
}

class _AddScheduleScreenState extends State<AddScheduleScreen> {
  Medicine? _selectedMedicine;
  DateTime _startDate = DateTime.now();
  DateTime _endDate = DateTime.now().add(const Duration(days: 7));
  List<TimeOfDay> _reminderTimes = [
    const TimeOfDay(hour: 8, minute: 0),
    const TimeOfDay(hour: 20, minute: 0),
  ];
  final _searchController = TextEditingController();
  List<Medicine> _searchResults = [];
  bool _isSearching = false;

  // Переменные для дозировки
  final TextEditingController _dosageValueController = TextEditingController();
  String _dosageUnit = 'мг';
  final List<String> _dosageUnits = ['мг', 'мл', 'шт', 'капсулы', 'капли', 'таблетки'];

  bool _isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
  }

  Future<void> _checkIfGuest() async {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final isGuest = await firebaseService.isGuest();
    setState(() {
      _isGuest = isGuest;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _dosageValueController.dispose();
    super.dispose();
  }

  // Вспомогательные методы для форматирования
  String _getMedicineInfo(Medicine medicine) {
    final parts = <String>[];
    if (medicine.dosage != null && medicine.dosage!.isNotEmpty) {
      parts.add(medicine.dosage!);
    }
    if (medicine.dosageForm != null && medicine.dosageForm!.isNotEmpty) {
      parts.add(medicine.dosageForm!);
    }
    return parts.join(' • ');
  }

  String _getManufacturer(Medicine medicine) {
    if (medicine.manufacturer != null && medicine.manufacturer!.isNotEmpty) {
      return medicine.manufacturer!;
    }
    return 'Производитель не указан';
  }

  @override
  Widget build(BuildContext context) {
    final firebaseService = Provider.of<FirebaseService>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Добавить расписание'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Заголовок выбора лекарства
                  const Text(
                    '1. Выберите лекарство',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),

                  // Выбор лекарства
                  if (_selectedMedicine != null) ...[
                    // Карточка выбранного лекарства
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Colors.blue.shade50, Colors.blue.shade100],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.blue.shade200,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.medication,
                              color: Colors.blue.shade700,
                              size: 28,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedMedicine!.name,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _getMedicineInfo(_selectedMedicine!),
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                                Text(
                                  _getManufacturer(_selectedMedicine!),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.grey),
                            onPressed: () {
                              setState(() {
                                _selectedMedicine = null;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    // Поле поиска
                    TextField(
                      controller: _searchController,
                      autofocus: true,
                      decoration: InputDecoration(
                        hintText: 'Введите название лекарства...',
                        prefixIcon: const Icon(
                          Icons.search,
                          color: Colors.blue,
                        ),
                        suffixIcon: _isSearching
                            ? const Padding(
                          padding: EdgeInsets.all(12),
                          child: SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                            ),
                          ),
                        )
                            : null,
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(
                            color: Colors.blue,
                            width: 2,
                          ),
                        ),
                      ),
                      onChanged: (value) async {
                        if (value.isNotEmpty) {
                          setState(() => _isSearching = true);
                          final results = await firebaseService.searchMedicines(
                            value,
                          );

                          setState(() {
                            _searchResults = results;
                            _isSearching = false;
                          });
                        } else {
                          setState(() {
                            _searchResults = [];
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 12),

                    if (_searchResults.isNotEmpty)
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _searchResults.length,
                        itemBuilder: (context, index) {
                          final medicine = _searchResults[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            elevation: 0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(color: Colors.grey.shade200),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.blue.shade100,
                                child: Icon(
                                  Icons.medication,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                medicine.name,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              subtitle: Text(
                                _getMedicineInfo(medicine),
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                              trailing: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade50,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Icon(
                                  Icons.add,
                                  color: Colors.blue.shade700,
                                  size: 20,
                                ),
                              ),
                              onTap: () {
                                setState(() {
                                  _selectedMedicine = medicine;
                                  _searchResults.clear();
                                  _searchController.clear();
                                });
                              },
                            ),
                          );
                        },
                      ),

                    // Сообщение "Ничего не найдено"
                    if (_searchResults.isEmpty &&
                        _searchController.text.length >= 2 &&
                        !_isSearching)
                      Container(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Ничего не найдено',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.grey[600],
                              ),
                            ),
                            Text(
                              'Попробуйте изменить запрос или добавьте новое лекарство',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[500],
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),

                    const SizedBox(height: 8),

                    // ✅ Кнопка добавления нового лекарства - показываем только для НЕ-гостей
                    if (!_isGuest)
                      Center(
                        child: TextButton.icon(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const AddMedicineScreen(),
                              ),
                            );
                            if (result != null && result is Medicine) {
                              setState(() {
                                _selectedMedicine = result;
                              });
                            }
                          },
                          icon: const Icon(Icons.add_box),
                          label: const Text(
                            'Добавить новое лекарство',
                            style: TextStyle(fontSize: 14),
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.blue.shade700,
                          ),
                        ),
                      ),
                  ],

                  if (_selectedMedicine != null) ...[
                    const SizedBox(height: 24),
                    const Divider(height: 8),
                    const SizedBox(height: 16),

                    // БЛОК ДОЗИРОВКИ
                    const Text(
                      '2. Дозировка',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _dosageValueController,
                            decoration: const InputDecoration(
                              labelText: 'Количество',
                              border: OutlineInputBorder(),
                              hintText: 'например: 10',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 2,
                          child: DropdownButtonFormField<String>(
                            value: _dosageUnit,
                            decoration: const InputDecoration(
                              labelText: 'Единица измерения',
                              border: OutlineInputBorder(),
                            ),
                            items: _dosageUnits.map((unit) {
                              return DropdownMenuItem(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (value) {
                              if (value != null) {
                                setState(() {
                                  _dosageUnit = value;
                                });
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Заголовок периода приема
                    const Text(
                      '3. Период приема',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),

                    // Период приема
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Column(
                        children: [
                          _buildDateRow('Начало', _startDate, () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _startDate,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2030),
                              locale: const Locale('ru', 'RU'),
                            );
                            if (date != null) {
                              setState(() {
                                _startDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                );
                                if (_endDate.isBefore(_startDate)) {
                                  _endDate = _startDate.add(
                                    const Duration(days: 7),
                                  );
                                }
                              });
                            }
                          }),
                          const Divider(),
                          _buildDateRow('Окончание', _endDate, () async {
                            final date = await showDatePicker(
                              context: context,
                              initialDate: _endDate,
                              firstDate: _startDate,
                              lastDate: DateTime(2030),
                              locale: const Locale('ru', 'RU'),
                            );
                            if (date != null) {
                              setState(() {
                                _endDate = DateTime(
                                  date.year,
                                  date.month,
                                  date.day,
                                );
                              });
                            }
                          }),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Заголовок времени приема с кнопкой добавления
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          '4. Время приема',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            setState(() {
                              _reminderTimes.add(
                                const TimeOfDay(hour: 12, minute: 0),
                              );
                            });
                          },
                          icon: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.add,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ),
                          tooltip: 'Добавить время приема',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Время приема (список с возможностью удаления)
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _reminderTimes.length,
                      itemBuilder: (context, index) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.grey.shade200),
                          ),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.blue.shade100,
                              child: Text(
                                '${index + 1}',
                                style: TextStyle(
                                  color: Colors.blue.shade700,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            title: Text(
                              _formatTimeOfDay(_reminderTimes[index]),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: Icon(
                                    Icons.access_time,
                                    color: Colors.blue.shade700,
                                  ),
                                  onPressed: () async {
                                    final time = await showTimePicker(
                                      context: context,
                                      initialTime: _reminderTimes[index],
                                    );
                                    if (time != null) {
                                      setState(() {
                                        _reminderTimes[index] = time;
                                      });
                                    }
                                  },
                                ),
                                if (_reminderTimes.length > 1)
                                  IconButton(
                                    icon: Icon(
                                      Icons.delete_outline,
                                      color: Colors.red.shade300,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        _reminderTimes.removeAt(index);
                                      });
                                    },
                                  ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 32),

                    // Кнопка сохранения
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () => _saveSchedule(context, firebaseService),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: const Text(
                          'Сохранить расписание',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateRow(String label, DateTime date, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            Row(
              children: [
                Text(
                  DateFormat('d MMMM yyyy', 'ru').format(date),
                  style: const TextStyle(fontSize: 14),
                ),
                const SizedBox(width: 8),
                Icon(Icons.arrow_drop_down, color: Colors.blue.shade700),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeOfDay(TimeOfDay time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  Future<void> _saveSchedule(BuildContext context, FirebaseService service) async {
    if (_selectedMedicine == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Сначала выберите лекарство'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedMedicine!.id == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка: ID лекарства не найден'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте хотя бы одно время приема'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_endDate.isBefore(_startDate)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Дата окончания не может быть раньше даты начала'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    _reminderTimes.sort((a, b) {
      if (a.hour == b.hour) return a.minute.compareTo(b.minute);
      return a.hour.compareTo(b.hour);
    });

    // Формируем дозировку из введённых значений
    String dosage = '';
    if (_dosageValueController.text.trim().isNotEmpty) {
      dosage = '${_dosageValueController.text.trim()} $_dosageUnit';
    } else {
      // Если пользователь не ввёл дозировку, используем из лекарства (если есть)
      dosage = _selectedMedicine!.dosage ?? '';
    }

    final schedule = MedicineSchedule(
      medicineId: _selectedMedicine!.id!,
      medicineName: _selectedMedicine!.name,
      dosage: dosage,
      startDate: DateTime(_startDate.year, _startDate.month, _startDate.day),
      endDate: DateTime(_endDate.year, _endDate.month, _endDate.day),
      reminderTimes: _reminderTimes
          .map((time) => _formatTimeOfDay(time))
          .toList(),
      createdAt: DateTime.now(),
    );

    try {
      final id = await service.createSchedule(schedule);

      if (id != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Расписание успешно создано!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 1),
          ),
        );

        // ✅ Показываем диалог добавления в аптечку только для НЕ-гостей
        if (!_isGuest) {
          await _showAddToStockDialogAndWait(_selectedMedicine!);
        }

        if (mounted) {
          Navigator.pop(context, true);
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ошибка: не удалось создать расписание'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ошибка: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _showAddToStockDialogAndWait(Medicine medicine) async {
    final completer = Completer<void>();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Добавить в аптечку?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Хотите добавить "${medicine.name}" в аптечку для отслеживания остатков?',
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 8),
            const Text(
              'Вы сможете указать количество и единицу измерения.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              completer.complete();
            },
            child: const Text('Не сейчас'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddToStockScreen(initialMedicine: medicine),
                ),
              );

              completer.complete();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
            ),
            child: const Text('Добавить'),
          ),
        ],
      ),
    );

    return completer.future;
  }
}