// lib/services/widget_service.dart

import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:home_widget/home_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_service.dart';

class WidgetService {
  static const String _androidWidgetName = 'MedicineWidget';

  static Future<void> init() async {

  }

  static Future<void> updateWidgetData(BuildContext context) async {
    final firebaseService = Provider.of<FirebaseService>(context, listen: false);

    final allSchedules = await firebaseService.getSchedules().first;
    final now = DateTime.now();

    final activeSchedules = allSchedules.where((schedule) =>
        schedule.endDate.isAfter(now)
    ).toList();

    final schedulesJson = activeSchedules.map((s) => ({
      'id': s.id,
      'medicineName': s.medicineName,
      'dosage': s.dosage,
      'startDate': s.startDate.millisecondsSinceEpoch,
      'endDate': s.endDate.millisecondsSinceEpoch,
      'reminderTimes': s.reminderTimes,
    })).toList();

    final jsonString = jsonEncode(schedulesJson);
    // Сохраняем в SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('all_schedules', jsonString);

    // Сохраняем также в home_widget
    await HomeWidget.saveWidgetData<String>('all_schedules', jsonString);

    // Обновляем виджет
    await HomeWidget.updateWidget(androidName: _androidWidgetName);
  }
}