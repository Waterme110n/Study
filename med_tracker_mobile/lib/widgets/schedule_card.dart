// lib/widgets/schedule_card.dart

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/schedule.dart';
import '../services/firebase_service.dart';
import 'package:provider/provider.dart';
import '../screens/home/edit_schedule_screen.dart';
import '../services/notification_service.dart';
import '../models/medicine.dart';
import '../models/stock.dart';
import '../screens/drugs/medicine_instruction_screen.dart';
import 'package:url_launcher/url_launcher.dart';

class ScheduleCard extends StatefulWidget {
  final MedicineSchedule schedule;
  final DateTime date;
  final VoidCallback onIntakeRecorded;
  final VoidCallback onScheduleUpdated;

  const ScheduleCard({
    super.key,
    required this.schedule,
    required this.date,
    required this.onIntakeRecorded,
    required this.onScheduleUpdated,
  });

  @override
  State<ScheduleCard> createState() => _ScheduleCardState();
}

class _ScheduleCardState extends State<ScheduleCard> {
  final Map<String, bool?> _intakeStatus = {}; // true - принято, false - пропущено, null - не отмечено
  bool _isLoading = true;
  Medicine? _medicineInfo;
  Stock? _stockInfo;
  bool isGuest = false;

  @override
  void initState() {
    super.initState();
    _checkIfGuest();
    _loadRecordedStatus();
    _loadMedicineInfo();
    _loadStockInfo();
  }

  @override
  void didUpdateWidget(ScheduleCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date) {
      _loadRecordedStatus();
    }
  }

  Future<void> _checkIfGuest() async {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);
    final _isGuest = await firebaseService.isGuest();
    if (mounted) {
      setState(() {
        isGuest = _isGuest;
      });
    }
  }

  Future<void> _loadMedicineInfo() async {
    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );

      Medicine? foundMedicine;

      if (widget.schedule.medicineId != null && widget.schedule.medicineId!.isNotEmpty) {
        foundMedicine = await firebaseService.getMedicineById(widget.schedule.medicineId!);
      }

      if (foundMedicine == null && widget.schedule.medicineName.isNotEmpty) {
        final searchResults = await firebaseService.searchMedicines(widget.schedule.medicineName);
        if (searchResults.isNotEmpty) {
          foundMedicine = searchResults.firstWhere(
                (m) => m.name.toLowerCase() == widget.schedule.medicineName.toLowerCase(),
            orElse: () => searchResults.first,
          );
        }
      }

      if (mounted) {
        setState(() {
          _medicineInfo = foundMedicine;
        });
      }
    } catch (e) {
      print('❌ Ошибка загрузки информации о лекарстве: $e');
    }
  }

  Future<void> _loadStockInfo() async {
    try {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );

      if (widget.schedule.medicineId != null && widget.schedule.medicineId!.isNotEmpty) {
        final stock = await firebaseService.getStockByMedicineId(widget.schedule.medicineId!);
        if (mounted) {
          setState(() {
            _stockInfo = stock;
          });
        }
      }
    } catch (e) {
      print('❌ Ошибка загрузки информации о запасах: $e');
    }
  }

  Future<void> _loadRecordedStatus() async {
    setState(() => _isLoading = true);

    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );

    final reminderTimes = widget.schedule.getReminderTimesForDate(widget.date);

    final Map<String, bool?> newStatus = {};

    for (var time in reminderTimes) {
      final key = _getTimeKey(time);
      final status = await firebaseService.getIntakeStatus(widget.schedule.id!, time);
      newStatus[key] = status;
    }

    if (mounted) {
      setState(() {
        _intakeStatus.clear();
        _intakeStatus.addAll(newStatus);
        _isLoading = false;
      });
    }
  }

  String _getTimeKey(DateTime time) {
    return '${time.hour}:${time.minute}';
  }

  Future<void> _toggleIntake(DateTime time) async {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    // Получаем текущий статус до изменения
    final oldStatus = await firebaseService.getIntakeStatus(widget.schedule.id!, time);

    // Переключаем статус
    await firebaseService.toggleIntakeStatus(widget.schedule.id!, time);

    // Получаем новый статус
    final newStatus = await firebaseService.getIntakeStatus(widget.schedule.id!, time);

    // Работа с аптечкой только для авторизованных пользователей
    if (!isGuest && widget.schedule.medicineId != null && widget.schedule.medicineId!.isNotEmpty) {
      // Парсим дозировку
      double dosageAmount = 1.0;
      String dosageUnit = '';

      if (widget.schedule.dosage.isNotEmpty) {
        final dosageParts = widget.schedule.dosage.split(' ');
        if (dosageParts.isNotEmpty) {
          dosageAmount = double.tryParse(dosageParts[0]) ?? 1.0;
          if (dosageParts.length > 1) {
            dosageUnit = dosageParts.sublist(1).join(' ');
          }
        }
      }

      final stock = await firebaseService.getStockByMedicineIdAndUnit(
        widget.schedule.medicineId!,
        dosageUnit,
      );

      if (stock != null) {
        if (oldStatus != true && newStatus == true) {
          // Было не принято -> стало принято: списываем
          await firebaseService.decrementStockById(stock.stockId, amount: dosageAmount);
        } else if (oldStatus == true && newStatus != true) {
          // Было принято -> стало не принято: возвращаем
          await firebaseService.refillStockById(stock.stockId, dosageAmount);
        }
      }
    }

    // Обновляем UI
    await _loadRecordedStatus();
    widget.onIntakeRecorded();

  }

  Future<void> _deleteSchedule() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Удалить расписание?'),
        content: Text(
          'Вы уверены, что хотите удалить расписание для "${widget.schedule.medicineName}"?\n\n'
              'Вся история приемов также будет удалена.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Удалить'),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      final firebaseService = Provider.of<FirebaseService>(
        context,
        listen: false,
      );

      try {
        await NotificationService().cancelScheduleNotifications(widget.schedule.id!);
        await firebaseService.deleteSchedule(widget.schedule.id!);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Расписание удалено'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 2),
            ),
          );
          widget.onScheduleUpdated();
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

  Future<void> _editSchedule() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditScheduleScreen(schedule: widget.schedule),
      ),
    );

    if (result == true && mounted) {
      await _rescheduleAllNotifications();
      await _loadRecordedStatus();
      widget.onScheduleUpdated();
    }
  }

  Future<void> _rescheduleAllNotifications() async {
    final firebaseService = Provider.of<FirebaseService>(
      context,
      listen: false,
    );
    final allSchedules = await firebaseService.getSchedules().first;
    await NotificationService().scheduleAllReminders(allSchedules);
  }

  void _showMedicineDetails() {
    if (_medicineInfo == null) {
      final basicMedicine = Medicine(
        id: widget.schedule.medicineId ?? widget.schedule.id,
        name: widget.schedule.medicineName,
        dosage: widget.schedule.dosage,
        dosageForm: 'не указана',
        isPersonal: false,
      );
      _showMedicineDetailsSheet(basicMedicine);
    } else {
      _showMedicineDetailsSheet(_medicineInfo!);
    }
  }

  void _showMedicineDetailsSheet(Medicine medicine) {
    final bool isPersonal = medicine.isPersonal ?? false;
    final moreInfo = medicine.moreInfo ?? {};
    final String? buyUrl = medicine.sourceUrl;
    final String? instructionUrl = moreInfo['source_url'] as String?;

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
          return Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
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

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                          Text(
                            medicine.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
                            ? () => _launchBuyUrl(buyUrl)
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

  void _launchBuyUrl(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      print('Ошибка открытия ссылки: $e');
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

  @override
  Widget build(BuildContext context) {
    final reminderTimes = widget.schedule.getReminderTimesForDate(widget.date);
    final isActive = widget.schedule.isActiveOnDate(widget.date);

    if (!isActive) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Заголовок
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.blue.shade400, Colors.blue.shade700],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.medication,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.schedule.medicineName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (widget.schedule.dosage.isNotEmpty)
                        Text(
                          widget.schedule.dosage,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    if (value == 'info') {
                      _showMedicineDetails();
                    } else if (value == 'edit') {
                      _editSchedule();
                    } else if (value == 'delete') {
                      _deleteSchedule();
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'info',
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, size: 20),
                          SizedBox(width: 8),
                          Text('Информация о лекарстве'),
                        ],
                      ),
                    ),
                    if (!isGuest) const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, size: 20),
                          SizedBox(width: 8),
                          Text('Редактировать'),
                        ],
                      ),
                    ),
                    if (!isGuest) const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, size: 20, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Удалить', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const Divider(height: 24),

            // Список времени приема
            const Text(
              'Время приема:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 12),

            if (_isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: reminderTimes.map((time) {
                  final timeKey = _getTimeKey(time);
                  final status = _intakeStatus[timeKey]; // true - принято, false - пропущено, null - не отмечено

                  // Определяем цвет фона в зависимости от статуса
                  Color backgroundColor;
                  Color borderColor;
                  Color textColor;
                  IconData icon;
                  Color iconColor;

                  if (status == true) {
                    // ПРИНЯТО — зелёный
                    backgroundColor = Colors.green.shade100;
                    borderColor = Colors.green;
                    textColor = Colors.green.shade700;
                    icon = Icons.check_circle;
                    iconColor = Colors.green;
                  } else if (status == false) {
                    // ПРОПУЩЕНО — красный
                    backgroundColor = Colors.red.shade100;
                    borderColor = Colors.red;
                    textColor = Colors.red.shade700;
                    icon = Icons.cancel;
                    iconColor = Colors.red;
                  } else {
                    // НЕ ОТМЕЧЕНО — синий
                    backgroundColor = Colors.blue.shade50;
                    borderColor = Colors.blue.shade200;
                    textColor = Colors.blue.shade700;
                    icon = Icons.access_time;
                    iconColor = Colors.blue;
                  }

                  return GestureDetector(
                    onTap: () => _toggleIntake(time),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: backgroundColor,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: borderColor, width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(icon, size: 18, color: iconColor),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(time),
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: textColor),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),

            // Информация о периоде
            if (widget.schedule.startDate.isAfter(DateTime.now()) ||
                widget.schedule.endDate.isBefore(DateTime.now()))
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 16,
                        color: Colors.orange.shade700,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.schedule.startDate.isAfter(DateTime.now())
                              ? 'Начнется ${DateFormat('d MMMM').format(widget.schedule.startDate)}'
                              : 'Завершился ${DateFormat('d MMMM').format(widget.schedule.endDate)}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}