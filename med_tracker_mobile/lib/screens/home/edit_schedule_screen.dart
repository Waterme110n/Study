// lib/screens/edit_schedule_screen.dart
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../models/schedule.dart';
import '../../services/firebase_service.dart';

class EditScheduleScreen extends StatefulWidget {
  final MedicineSchedule schedule;

  const EditScheduleScreen({super.key, required this.schedule});

  @override
  State<EditScheduleScreen> createState() => _EditScheduleScreenState();
}

class _EditScheduleScreenState extends State<EditScheduleScreen> {
  late DateTime _startDate;
  late DateTime _endDate;
  late List<String> _reminderTimes;
  bool _isLoading = false;

  // Переменные для дозировки
  late TextEditingController _dosageValueController;
  late String _dosageUnit;
  final List<String> _dosageUnits = ['мг', 'мл', 'шт', 'капсулы', 'капли', 'таблетки'];

  @override
  void initState() {
    super.initState();
    _startDate = widget.schedule.startDate;
    _endDate = widget.schedule.endDate;
    _reminderTimes = List.from(widget.schedule.reminderTimes);

    // Парсим дозировку из строки
    final parsed = _parseDosage(widget.schedule.dosage);
    _dosageValueController = TextEditingController(text: parsed['value']);
    _dosageUnit = parsed['unit']!;
  }

  Map<String, String> _parseDosage(String dosage) {
    if (dosage.isEmpty) {
      return {'value': '', 'unit': 'мг'};
    }

    // Пробуем разделить строку дозировки на значение и единицу
    final parts = dosage.split(' ');
    if (parts.length >= 2) {
      // Проверяем, является ли первая часть числом
      final value = parts[0];
      final unit = parts.sublist(1).join(' ');

      if (_isNumeric(value)) {
        return {
          'value': value,
          'unit': _dosageUnits.contains(unit) ? unit : 'мг'
        };
      }
    }

    // Если не удалось распарсить, возвращаем всю строку как значение
    return {'value': dosage, 'unit': 'мг'};
  }

  bool _isNumeric(String str) {
    return double.tryParse(str) != null || int.tryParse(str) != null;
  }

  String _getFormattedDosage() {
    final value = _dosageValueController.text.trim();
    if (value.isEmpty) {
      return '';
    }
    return '$value $_dosageUnit';
  }

  @override
  void dispose() {
    _dosageValueController.dispose();
    super.dispose();
  }

  Future<void> _updateSchedule() async {
    if (_reminderTimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Добавьте хотя бы одно время приема'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    // Добавим отладочный вывод
    final newDosage = _getFormattedDosage();
    print('=== Saving dosage ===');
    print('Value: ${_dosageValueController.text}');
    print('Unit: $_dosageUnit');
    print('Formatted dosage: $newDosage');
    print('=====================');

    try {
      // Создаем обновленное расписание с новой дозировкой
      final updatedSchedule = MedicineSchedule(
        id: widget.schedule.id,
        medicineId: widget.schedule.medicineId,
        medicineName: widget.schedule.medicineName,
        dosage: newDosage, // Используем новую дозировку
        startDate: _startDate,
        endDate: _endDate,
        reminderTimes: _reminderTimes,
        createdAt: widget.schedule.createdAt,
      );

      // Сохраняем в Firebase
      await firebaseService.updateSchedule(updatedSchedule);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Расписание обновлено'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Ошибка: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _addTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 12, minute: 0),
    );

    if (time != null) {
      setState(() {
        _reminderTimes.add(
          '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
        );
        _reminderTimes.sort();
      });
    }
  }

  Future<void> _editTime(int index) async {
    final parts = _reminderTimes[index].split(':');
    final currentTime = TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts[1]),
    );

    final newTime = await showTimePicker(
      context: context,
      initialTime: currentTime,
    );

    if (newTime != null) {
      setState(() {
        _reminderTimes[index] =
        '${newTime.hour.toString().padLeft(2, '0')}:${newTime.minute.toString().padLeft(2, '0')}';
        _reminderTimes.sort();
      });
    }
  }

  void _removeTime(int index) {
    setState(() {
      _reminderTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Редактировать расписание'),
        elevation: 0,
        backgroundColor: Colors.blue.shade700,
        actions: [
          IconButton(
            onPressed: _updateSchedule,
            icon: const Icon(Icons.save),
            tooltip: 'Сохранить',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Информация о лекарстве
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Лекарство',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.schedule.medicineName,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(height: 12),

                    // ТЕКУЩАЯ ДОЗИРОВКА (для информации)
                    if (widget.schedule.dosage.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          'Текущая: ${widget.schedule.dosage}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),

                    // БЛОК РЕДАКТИРОВАНИЯ ДОЗИРОВКИ
                    const Text(
                      'Новая дозировка',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextField(
                            controller: _dosageValueController,
                            decoration: const InputDecoration(
                              hintText: 'Количество',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.all(Radius.circular(8)),
                              ),
                              contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Период приема
            const Text(
              'Период приема',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
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
            ),
            const SizedBox(height: 16),

            // Время приема
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Время приема',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: _addTime,
                  icon: const Icon(Icons.add),
                  tooltip: 'Добавить время',
                ),
              ],
            ),
            const SizedBox(height: 8),
            ..._reminderTimes.asMap().entries.map((entry) {
              final index = entry.key;
              final time = entry.value;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(color: Colors.blue.shade700),
                    ),
                  ),
                  title: Text(time, style: const TextStyle(fontSize: 18)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit),
                        onPressed: () => _editTime(index),
                        color: Colors.blue,
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _removeTime(index),
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 24),
          ],
        ),
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
}