// lib/services/statistics_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/schedule.dart';
import '../models/statistics.dart';
import 'firebase_service.dart';

class StatisticsService {
  final FirebaseService _firebaseService;

  StatisticsService(this._firebaseService);

  /// Получить статистику за период
  Future<Map<String, dynamic>> getStatistics(
      DateTime startDate,
      DateTime endDate,
      ) async {
    final schedules = await _firebaseService.getSchedules().first;

    // Фильтруем расписания за период
    final relevantSchedules = schedules.where((schedule) =>
    schedule.startDate.isBefore(endDate) &&
        schedule.endDate.isAfter(startDate)
    ).toList();

    // Собираем все приёмы за период
    final allIntakes = <String, Map<String, dynamic>>{};
    final medicineStats = <String, MedicineStat>{};

    for (final schedule in relevantSchedules) {
      // Получаем историю приёмов
      final intakes = await _firebaseService.getIntakeHistory(schedule.id!).first;

      for (final intake in intakes) {
        final intakeTime = (intake['intakeTime'] as Timestamp).toDate();
        final taken = intake['taken'] ?? false;

        // Проверяем, входит ли приём в период
        if (intakeTime.isAfter(startDate) && intakeTime.isBefore(endDate.add(const Duration(days: 1)))) {
          final key = '${schedule.id}_${intakeTime.millisecondsSinceEpoch}';
          allIntakes[key] = {
            'scheduleId': schedule.id,
            'medicineName': schedule.medicineName,
            'medicineId': schedule.medicineId,
            'intakeTime': intakeTime,
            'taken': taken,
          };

          // Статистика по лекарствам
          if (!medicineStats.containsKey(schedule.medicineId)) {
            medicineStats[schedule.medicineId] = MedicineStat(
              medicineId: schedule.medicineId ?? '',
              medicineName: schedule.medicineName,
              total: 0,
              taken: 0,
              percentage: 0,
            );
          }

          final stat = medicineStats[schedule.medicineId]!;
          medicineStats[schedule.medicineId] = MedicineStat(
            medicineId: stat.medicineId,
            medicineName: stat.medicineName,
            total: stat.total + 1,
            taken: stat.taken + (taken ? 1 : 0),
            percentage: 0,
          );
        }
      }
    }

    // Вычисляем проценты для лекарств
    for (final key in medicineStats.keys) {
      final stat = medicineStats[key]!;
      final percentage = stat.total > 0 ? (stat.taken / stat.total) * 100 : 0;
      medicineStats[key] = MedicineStat(
        medicineId: stat.medicineId,
        medicineName: stat.medicineName,
        total: stat.total,
        taken: stat.taken,
        percentage: percentage.toDouble(),
      );
    }

    // Ежедневная статистика
    final dailyStats = <DailyStat>[];
    var currentDate = DateTime(startDate.year, startDate.month, startDate.day);
    final endDateTime = DateTime(endDate.year, endDate.month, endDate.day);

    while (currentDate.isBefore(endDateTime.add(const Duration(days: 1)))) {
      final dayIntakes = allIntakes.values.where((intake) {
        final intakeDate = intake['intakeTime'] as DateTime;
        return intakeDate.year == currentDate.year &&
            intakeDate.month == currentDate.month &&
            intakeDate.day == currentDate.day;
      }).toList();

      final total = dayIntakes.length;
      final taken = dayIntakes.where((i) => i['taken'] == true).length;
      final percentage = total > 0 ? (taken / total) * 100 : 0.0;

      dailyStats.add(DailyStat(
        date: DateTime(currentDate.year, currentDate.month, currentDate.day),
        total: total,
        taken: taken,
        percentage: percentage.toDouble(), // 👈 toDouble()
      ));

      currentDate = currentDate.add(const Duration(days: 1));
    }

    // Общая статистика
    final totalAll = allIntakes.length;
    final takenAll = allIntakes.values.where((i) => i['taken'] == true).length;
    final overallPercentage = totalAll > 0 ? (takenAll / totalAll) * 100 : 0;

    return {
      'dailyStats': dailyStats,
      'medicineStats': medicineStats.values.toList(),
      'total': totalAll,
      'taken': takenAll,
      'overallPercentage': overallPercentage,
    };
  }
}