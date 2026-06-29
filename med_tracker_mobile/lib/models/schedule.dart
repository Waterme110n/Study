// lib/models/schedule.dart
import 'package:cloud_firestore/cloud_firestore.dart';

class MedicineSchedule {
  final String? id;
  final String medicineId;
  final String medicineName;
  final String dosage;
  final DateTime startDate;
  final DateTime endDate;
  final List<String> reminderTimes;
  final DateTime createdAt;

  MedicineSchedule({
    this.id,
    required this.medicineId,
    required this.medicineName,
    required this.dosage,
    required this.startDate,
    required this.endDate,
    required this.reminderTimes,
    required this.createdAt,
  });

  int get timesPerDay => reminderTimes.length;

  bool isActiveOnDate(DateTime date) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    final checkDate = DateTime(date.year, date.month, date.day);

    return checkDate.isAfter(start) ||
        checkDate.isAtSameMomentAs(start) && checkDate.isBefore(end) ||
        checkDate.isAtSameMomentAs(end);
  }

  List<DateTime> getReminderTimesForDate(DateTime date) {
    final times = <DateTime>[];

    for (var timeStr in reminderTimes) {
      final parts = timeStr.split(':');
      if (parts.length == 2) {
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        final reminderTime = DateTime(
          date.year,
          date.month,
          date.day,
          hour,
          minute,
        );
        times.add(reminderTime);
      }
    }
    
    times.sort((a, b) => a.compareTo(b));
    return times;
  }

  Map<String, dynamic> toJson() {
    return {
      'medicineId': medicineId,
      'medicineName': medicineName,
      'dosage': dosage,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'reminderTimes': reminderTimes,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory MedicineSchedule.fromJson(Map<String, dynamic> json) {
    return MedicineSchedule(
      id: json['id'] as String?,
      medicineId: json['medicineId'] as String,
      medicineName: json['medicineName'] as String,
      dosage: json['dosage'] as String,
      startDate: (json['startDate'] as Timestamp).toDate(),
      endDate: (json['endDate'] as Timestamp).toDate(),
      reminderTimes: List<String>.from(json['reminderTimes'] ?? []),
      createdAt: (json['createdAt'] as Timestamp).toDate(),
    );
  }
}
