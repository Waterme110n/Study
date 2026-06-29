import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/material.dart';

import '../models/schedule.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Инициализация временных зон
    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Europe/Moscow'));

    // Настройки только для Android
    const AndroidInitializationSettings androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings settings = InitializationSettings(
      android: androidSettings,
      iOS: null,
    );

    await _notifications.initialize(settings: settings);
  }

  DateTime _parseTimeOfDay(String timeStr, DateTime date) {
    final parts = timeStr.split(':');
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);
    return DateTime(date.year, date.month, date.day, hour, minute);
  }


  Future<void> scheduleRemindersForSchedule(MedicineSchedule schedule) async {
    // Отменяем старые уведомления для этого расписания
    await cancelScheduleNotifications(schedule.id!);

    final now = DateTime.now();
    int notificationId = _generateBaseId(schedule.id!);
    int dayCounter = 0;

    // Начинаем с startDate
    DateTime currentDate = DateTime(
      schedule.startDate.year,
      schedule.startDate.month,
      schedule.startDate.day,
    );

    // Конечная дата (включительно)
    final endDate = DateTime(
      schedule.endDate.year,
      schedule.endDate.month,
      schedule.endDate.day,
    );

    // Проходим по всем дням от startDate до endDate
    while (currentDate.isBefore(endDate) || currentDate.isAtSameMomentAs(endDate)) {
      // Для каждого времени приёма в этот день
      for (int i = 0; i < schedule.reminderTimes.length; i++) {
        final timeStr = schedule.reminderTimes[i];
        final scheduledDateTime = _parseTimeOfDay(timeStr, currentDate);

        // Планируем только будущие уведомления (не в прошлом)
        if (scheduledDateTime.isAfter(now)) {
          await _scheduleSingleNotification(
            id: notificationId + dayCounter * 10 + i,
            title: '💊 Напоминание о приёме',
            body: 'Пора принять: ${schedule.medicineName} (${schedule.dosage})',
            scheduledTime: scheduledDateTime,
          );
        }
      }
      currentDate = currentDate.add(const Duration(days: 1));
      dayCounter++;
    }
  }

  /// Внутренний метод для планирования ОДНОГО уведомления
  Future<void> _scheduleSingleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    final tz.TZDateTime tzScheduledTime = tz.TZDateTime.from(
      scheduledTime,
      tz.local,
    );

    // Если время уже прошло, не планируем
    if (tzScheduledTime.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'medication_channel',
      'Приём лекарств',
      channelDescription: 'Напоминания о приёме лекарств',
      importance: Importance.high,
      priority: Priority.high,
      enableVibration: true,
      playSound: true,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: null,
    );

    await _notifications.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: tzScheduledTime,
      notificationDetails: details,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  /// Планирует уведомления для ВСЕХ расписаний пользователя
  Future<void> scheduleAllReminders(List<MedicineSchedule> schedules) async {
    await cancelAllNotifications();
    for (var schedule in schedules) {
      await scheduleRemindersForSchedule(schedule);
    }
  }

  /// Отменить уведомления для конкретного расписания
  Future<void> cancelScheduleNotifications(String scheduleId) async {
    int baseId = _generateBaseId(scheduleId);
    // Отменяем все уведомления в диапазоне ID этого расписания
    for (int i = 0; i < 1000; i++) {
      await _notifications.cancel(id: baseId + i);
    }
  }

  /// Отменить все уведомления
  Future<void> cancelAllNotifications() async {
    await _notifications.cancelAll();
  }

  /// Показать мгновенное уведомление (когда пользователь отметил приём)
  Future<void> showInstantNotification({
    required String title,
    required String body,
  }) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'instant_channel',
      'Мгновенные уведомления',
      channelDescription: 'Уведомления о действиях',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: null,
    );

    await _notifications.show(
      id: DateTime.now().millisecondsSinceEpoch.remainder(100000),
      title: title,
      body: body,
      notificationDetails: details,
    );
  }

  /// Запросить разрешение на уведомления (Android 13+)
  Future<void> requestPermissions() async {
    await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  /// Проверить, есть ли разрешение на уведомления
  Future<bool> areNotificationsEnabled() async {
    final bool? enabled = await _notifications
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.areNotificationsEnabled();
    return enabled ?? true;
  }

  // ==================== ВСПОМОГАТЕЛЬНЫЕ МЕТОДЫ ====================

  /// Генерирует уникальный базовый ID для расписания
  int _generateBaseId(String scheduleId) {
    return scheduleId.hashCode.abs() % 100000;
  }
}