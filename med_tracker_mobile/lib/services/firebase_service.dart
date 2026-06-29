import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/medicine.dart';
import '../models/schedule.dart';
import 'dart:async';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/stock.dart';
import 'notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseService extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoggingIn = false;

  bool get isAuthenticated => currentUser != null;

  /// Вход как гость (анонимный пользователь)
  Future<User?> signInAsGuest() async {
    try {
      UserCredential result = await _auth.signInAnonymously();

      if (result.user != null) {
        await _createGuestUserDocument(result.user!);
      }

      notifyListeners();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Создание документа для гостя в Firestore
  Future<void> _createGuestUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'uid': user.uid,
        'isGuest': true,
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // Проверка, является ли текущий пользователь гостем
  Future<bool> isGuest() async {
    if (currentUser == null) return false;

    // Анонимные пользователи Firebase — это гости
    if (currentUser!.isAnonymous) return true;

    // Дополнительная проверка по Firestore
    try {
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .get();
      return userDoc.data()?['isGuest'] == true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isRealUser() async {
    if (currentUser == null) return false;
    if (currentUser!.isAnonymous) return false;

    // Проверка по Firestore
    final userDoc = await _firestore.collection('users').doc(currentUser!.uid).get();
    final isGuest = userDoc.data()?['isGuest'] == true;
    return !isGuest;
  }

  // Автоматический вход как гость при первом запуске
  Future<void> ensureLoggedIn() async {
    await restoreUserSession();
    // Сначала проверяем текущего пользователя
    if (currentUser != null && !currentUser!.isAnonymous) {
      print('✅ Пользователь уже есть (не гость): ${currentUser!.uid}');
      return;
    }

    // Если гость — проверяем, может быть это полноценный пользователь?
    if (currentUser != null && currentUser!.isAnonymous) {
      print('👤 Текущий пользователь — гость, пытаемся восстановить полноценную сессию');
      await restoreUserSession();

      if (currentUser != null && !currentUser!.isAnonymous) {
        print('✅ Сессия восстановлена!');
        return;
      }
    }

    // Если нет пользователя — пробуем восстановить
    if (currentUser == null) {
      await restoreUserSession();
      if (currentUser != null) return;
    }

    // Если всё ещё нет — входим как гость
    if (currentUser == null) {
      print('🔑 Выполняем вход как гость...');
      await signInAsGuest();
    }
  }

// Регистрация без подтверждения email
  Future<User?> registerWithEmailAndPassword(String email, String password) async {
    try {
      final guestUser = _auth.currentUser;
      final bool isGuest = guestUser != null && guestUser.isAnonymous;

      List<Map<String, dynamic>> guestSchedulesData = [];
      List<Map<String, dynamic>> guestIntakesData = [];

      if (isGuest && guestUser != null) {

        // Получаем все расписания гостя
        final schedulesSnapshot = await _firestore
            .collection('users')
            .doc(guestUser.uid)
            .collection('schedules')
            .get();

        for (var scheduleDoc in schedulesSnapshot.docs) {
          final scheduleData = scheduleDoc.data();
          scheduleData['originalId'] = scheduleDoc.id;
          guestSchedulesData.add(scheduleData);

          final intakesSnapshot = await scheduleDoc.reference.collection('intakes').get();
          for (var intakeDoc in intakesSnapshot.docs) {
            guestIntakesData.add({
              'scheduleOriginalId': scheduleDoc.id,
              'intakeData': intakeDoc.data(),
            });
          }
        }
      }

      // Регистрация нового пользователя
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      if (result.user != null) {
        final newUserId = result.user!.uid;
        await _createUserDocument(result.user!);
        await saveUserSession();

        if (isGuest && guestSchedulesData.isNotEmpty) {

          for (var scheduleData in guestSchedulesData) {
            final newScheduleRef = _firestore
                .collection('users')
                .doc(newUserId)
                .collection('schedules')
                .doc();

            final cleanData = Map<String, dynamic>.from(scheduleData);
            cleanData.remove('originalId');

            await newScheduleRef.set(cleanData);
            final relatedIntakes = guestIntakesData.where(
                    (i) => i['scheduleOriginalId'] == scheduleData['originalId']
            ).toList();

            for (var intake in relatedIntakes) {
              await newScheduleRef.collection('intakes').add(intake['intakeData']);
            }
          }
        }
        notifyListeners();
        return result.user;
      }
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

// Вход — убираем проверку emailConfirmed
  Future<User?> signInWithEmailAndPassword(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _updateUserLastLogin(result.user!);
      await saveUserSession();
      return result.user;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> _createUserDocument(User user) async {
    final userDoc = _firestore.collection('users').doc(user.uid);
    final doc = await userDoc.get();

    if (!doc.exists) {
      await userDoc.set({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName ?? user.email?.split('@').first,
        'photoURL': user.photoURL,
        // 'emailVerified': user.emailVerified,  // 👈 УДАЛИТЬ
        'createdAt': FieldValue.serverTimestamp(),
        'lastLoginAt': FieldValue.serverTimestamp(),
        'provider': user.providerData.first.providerId,
      });
    } else {
      await userDoc.update({
        'lastLoginAt': FieldValue.serverTimestamp(),
        'displayName': user.displayName ?? doc.data()?['displayName'],
        'photoURL': user.photoURL ?? doc.data()?['photoURL'],
      });
    }
  }

  Future<User?> signInWithGoogle() async {
    try {
      // Создаём экземпляр GoogleSignIn
      final GoogleSignIn googleSignIn = GoogleSignIn();

      // Запрашиваем аккаунт
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        // Пользователь отменил вход
        return null;
      }

      // Получаем токены
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Создаём учётные данные для Firebase
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Входим в Firebase
      UserCredential userCredential = await _auth.signInWithCredential(credential);

      if (userCredential.user != null) {
        await _createUserDocument(userCredential.user!);
        await _updateUserLastLogin(userCredential.user!);
        await saveUserSession();
      }

      notifyListeners();
      return userCredential.user;
    } catch (e) {
      print('❌ Ошибка входа через Google: $e');
      throw Exception('Ошибка входа через Google: ${e.toString()}');
    }
  }

  // Обновление времени последнего входа
  Future<void> _updateUserLastLogin(User user) async {
    await _firestore.collection('users').doc(user.uid).update({
      'lastLoginAt': FieldValue.serverTimestamp(),
    });
  }

  // Выход из аккаунта (упрощенный - только Firebase)
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      await clearUserSession();
      notifyListeners();
    } catch (e) {
      print('Ошибка выхода: $e');
      throw Exception('Ошибка выхода: $e');
    }
  }

  // Отправка письма для сброса пароля
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw _handleAuthError(e);
    }
  }

  // Объединить данные гостя с новым аккаунтом при регистрации
  Future<void> mergeGuestDataWithNewAccount(String newUserId) async {
    print('🔍 mergeGuestDataWithNewAccount START');
    print('🔍 currentUser: ${currentUser?.uid}');
    print('🔍 newUserId: $newUserId');
    if (currentUser == null) return;

    final guestId = currentUser!.uid;

    // 1. Получаем все расписания гостя
    final guestSchedules = await _firestore
        .collection('users')
        .doc(guestId)
        .collection('schedules')
        .get();

    print('📦 Найдено расписаний гостя: ${guestSchedules.docs.length}');

    // 2. Копируем каждое расписание новому пользователю
    for (var scheduleDoc in guestSchedules.docs) {
      final scheduleData = scheduleDoc.data();

      // Создаём копию расписания для нового пользователя
      final newScheduleRef = _firestore
          .collection('users')
          .doc(newUserId)
          .collection('schedules')
          .doc(); // новый ID

      await newScheduleRef.set(scheduleData);

      // 3. Копируем историю приёмов (intakes) для этого расписания
      final intakes = await scheduleDoc.reference.collection('intakes').get();

      for (var intakeDoc in intakes.docs) {
        final intakeData = intakeDoc.data();
        await newScheduleRef.collection('intakes').add(intakeData);
      }

      print('  ✅ Скопировано расписание: ${scheduleData['medicineName']}');
    }

    // 4. Копируем личные лекарства гостя (если есть)
    final guestMedicines = await _firestore
        .collection('users')
        .doc(guestId)
        .collection('medicines')
        .get();

    for (var medicineDoc in guestMedicines.docs) {
      final medicineData = medicineDoc.data();
      await _firestore
          .collection('users')
          .doc(newUserId)
          .collection('medicines')
          .add(medicineData);
    }

    // 5. (Опционально) Помечаем гостевой аккаунт как объединённый
    await _firestore.collection('users').doc(guestId).update({
      'mergedTo': newUserId,
      'mergedAt': FieldValue.serverTimestamp(),
    });

    print('✅ Данные гостя объединены с аккаунтом $newUserId');
  }

  // Получение текущего пользователя
  User? get currentUser => _auth.currentUser;

  // Получение данных пользователя из Firestore
  Stream<DocumentSnapshot> getUserData() {
    if (currentUser == null) return Stream.empty();
    return _firestore.collection('users').doc(currentUser!.uid).snapshots();
  }

  // Обработка ошибок Firebase
  String _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Этот email уже используется';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Пароль должен содержать минимум 6 символов';
      case 'user-not-found':
        return 'Пользователь не найден';
      case 'wrong-password':
        return 'Неверный пароль';
      case 'too-many-requests':
        return 'Слишком много попыток. Попробуйте позже';
      case 'operation-not-allowed':
        return 'Вход с email/паролем отключен';
      case 'user-disabled':
        return 'Аккаунт отключен';
      case 'invalid-credential':
        return 'Неверный email или пароль';
      case 'account-exists-with-different-credential':
        return 'Аккаунт уже существует с другим способом входа';
      default:
        return 'Ошибка: ${e.message}';
    }
  }

  Future<void> saveUserSession() async {
    if (currentUser != null) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_uid', currentUser!.uid);
      await prefs.setBool('isLoggedIn', true);
      print('✅ saveUserSession: сохранён ${currentUser!.uid}');
    } else {
      print('⚠️ saveUserSession: currentUser == null');
    }
  }

  Future<void> restoreUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    final isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    final savedUid = prefs.getString('user_uid');
    print('📀 restoreUserSession: isLoggedIn=$isLoggedIn, savedUid=$savedUid');

    if (isLoggedIn && savedUid != null && currentUser == null) {
      print('⚠️ Сессия была, но потеряна');
    }
  }

  Future<void> clearUserSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_uid');
    await prefs.setBool('isLoggedIn', false);
    print('✅ Сессия очищена');
  }

  // Создать расписание
  Future<String?> createSchedule(MedicineSchedule schedule) async {
    try {
      if (currentUser == null) return null;

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('schedules')
          .add(schedule.toJson());

      notifyListeners();
      return docRef.id;
    } catch (e) {
      print('❌ Ошибка создания расписания: $e');
      return null;
    }
  }

  // Получить расписания текущего пользователя
  Stream<List<MedicineSchedule>> getSchedules() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .orderBy('startDate', descending: false)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        return MedicineSchedule.fromJson(jsonData);
      }).toList();
    });
  }

  // Получить все лекарства
  Stream<List<Medicine>> getMedicines() {
    return _firestore.collection('drugs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        return Medicine.fromJson(jsonData);
      }).toList();
    });
  }

  // Получить лекарство по ID
  Future<Medicine?> getMedicineById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('drugs').doc(id).get();
      if (doc.exists) {
        final data = doc.data() as Map<String, dynamic>?;
        if (data != null) {
          final Map<String, dynamic> jsonData = {...data};
          jsonData['id'] = doc.id;
          return Medicine.fromJson(jsonData);
        }
      }
      return null;
    } catch (e) {
      print('Ошибка получения лекарства: $e');
      return null;
    }
  }

  // Получить расписания на конкретную дату
  Future<List<MedicineSchedule>> getSchedulesForDate(DateTime date) async {
    if (currentUser == null) return [];

    DateTime startOfDay = DateTime(date.year, date.month, date.day);
    DateTime endOfDay = startOfDay.add(const Duration(days: 1));

    try {
      QuerySnapshot snapshot = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('schedules')
          .get();

      return snapshot.docs
          .map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        return MedicineSchedule.fromJson(jsonData);
      })
          .where(
            (schedule) =>
        schedule.startDate.isBefore(endOfDay) &&
            schedule.endDate.isAfter(startOfDay),
      )
          .toList();
    } catch (e) {
      print('Ошибка получения расписаний: $e');
      return [];
    }
  }

  // Обновить расписание
  Future<void> updateSchedule(MedicineSchedule schedule) async {
    try {
      if (currentUser == null) throw Exception('Пользователь не авторизован');
      if (schedule.id == null) throw Exception('ID расписания не указан');

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('schedules')
          .doc(schedule.id)
          .update({
        'dosage': schedule.dosage,
        'startDate': Timestamp.fromDate(schedule.startDate),
        'endDate': Timestamp.fromDate(schedule.endDate),
        'reminderTimes': schedule.reminderTimes,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print('❌ Ошибка обновления расписания: $e');
      throw Exception('Ошибка обновления расписания: $e');
    }
  }

  // Удалить расписание
  Future<void> deleteSchedule(String scheduleId) async {
    if (currentUser == null) return;

    try {
      final scheduleRef = _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('schedules')
          .doc(scheduleId);

      final intakes = await scheduleRef.collection('intakes').get();
      for (var intake in intakes.docs) {
        await intake.reference.delete();
      }

      await scheduleRef.delete();

      notifyListeners();
    } catch (e) {
      print('❌ Ошибка удаления расписания: $e');
      throw Exception('Ошибка удаления расписания: $e');
    }
  }

  // Записать факт приема
  Future<void> recordIntake(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .add({
      'intakeTime': Timestamp.fromDate(intakeTime),
      'taken': true,
      'recordedAt': FieldValue.serverTimestamp(),
    });

    notifyListeners();
  }

  // Создать запись о пропущенном приёме
  Future<void> createMissedIntake(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return;

    // Генерируем уникальный ID на основе времени (чтобы не создавать дубликаты)
    final intakeId = 'missed_${intakeTime.millisecondsSinceEpoch}';

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .doc(intakeId)
        .set({
      'intakeTime': Timestamp.fromDate(intakeTime),
      'taken': false,
      'recordedAt': FieldValue.serverTimestamp(),
      'isMissed': true,
    });

    notifyListeners();
  }

  // Проверить, есть ли уже запись о приёме
  Future<bool> isIntakeExists(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return false;

    // Ищем запись с точным соответствием времени (в пределах 1 минуты)
    final startOfMinute = DateTime(
      intakeTime.year,
      intakeTime.month,
      intakeTime.day,
      intakeTime.hour,
      intakeTime.minute,
    );
    final endOfMinute = startOfMinute.add(const Duration(minutes: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .where('intakeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMinute))
        .where('intakeTime', isLessThan: Timestamp.fromDate(endOfMinute))
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  // Проверить, был ли отмечен приём как принятый
  Future<bool> isIntakeRecorded(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return false;

    final startOfMinute = DateTime(
      intakeTime.year,
      intakeTime.month,
      intakeTime.day,
      intakeTime.hour,
      intakeTime.minute,
    );
    final endOfMinute = startOfMinute.add(const Duration(minutes: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .where('intakeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMinute))
        .where('intakeTime', isLessThan: Timestamp.fromDate(endOfMinute))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return false;

    // Проверяем поле 'taken' - true если принято, false если пропущено
    final data = snapshot.docs.first.data();
    return data['taken'] == true;
  }

  // Проверить, есть ли запись о пропущенном приёме (taken == false)
  Future<bool> isIntakeMissed(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return false;

    final startOfMinute = DateTime(
      intakeTime.year,
      intakeTime.month,
      intakeTime.day,
      intakeTime.hour,
      intakeTime.minute,
    );
    final endOfMinute = startOfMinute.add(const Duration(minutes: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .where('intakeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMinute))
        .where('intakeTime', isLessThan: Timestamp.fromDate(endOfMinute))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return false;

    final data = snapshot.docs.first.data();
    return data['taken'] == false;
  }

  // Проверить и добавить пропущенные приёмы за все прошедшие дни
  Future<void> checkAndAddMissedIntakes() async {
    if (currentUser == null) return;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Получаем все расписания
    final schedules = await getSchedules().first;

    for (final schedule in schedules) {
      // Начинаем с даты начала расписания
      var currentDate = DateTime(
        schedule.startDate.year,
        schedule.startDate.month,
        schedule.startDate.day,
      );

      // Проверяем только прошедшие дни (до сегодня, не включая сегодня)
      while (currentDate.isBefore(today)) {
        // Проверяем, активен ли этот день в расписании
        if (currentDate.isBefore(schedule.startDate) ||
            currentDate.isAfter(schedule.endDate)) {
          currentDate = currentDate.add(const Duration(days: 1));
          continue;
        }

        // Для каждого времени приёма в этот день
        for (final timeStr in schedule.reminderTimes) {
          final parts = timeStr.split(':');
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);

          final intakeTime = DateTime(
            currentDate.year,
            currentDate.month,
            currentDate.day,
            hour,
            minute,
          );

          // Проверяем, есть ли уже запись
          final exists = await isIntakeExists(schedule.id!, intakeTime);

          if (!exists) {
            // Создаём запись о пропуске
            await createMissedIntake(schedule.id!, intakeTime);
            print('📝 Создан пропуск: ${schedule.medicineName} - ${DateFormat('dd.MM.yyyy HH:mm').format(intakeTime)}');
          }
        }

        currentDate = currentDate.add(const Duration(days: 1));
      }
    }
  }

  // Получить историю приемов
  Stream<List<Map<String, dynamic>>> getIntakeHistory(String scheduleId) {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .orderBy('intakeTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        return jsonData;
      }).toList();
    });
  }

  // Переключение статуса приёма
  Future<void> toggleIntakeStatus(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return;

    final startOfMinute = DateTime(
      intakeTime.year,
      intakeTime.month,
      intakeTime.day,
      intakeTime.hour,
      intakeTime.minute,
    );
    final endOfMinute = startOfMinute.add(const Duration(minutes: 1));

    // Ищем существующую запись
    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .where('intakeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMinute))
        .where('intakeTime', isLessThan: Timestamp.fromDate(endOfMinute))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) {
      // Нет записи -> создаём с taken = true (принято)
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('schedules')
          .doc(scheduleId)
          .collection('intakes')
          .add({
        'intakeTime': Timestamp.fromDate(intakeTime),
        'taken': true,
        'recordedAt': FieldValue.serverTimestamp(),
      });
      print('📝 Создана запись: принято');
    } else {
      // Запись есть -> меняем статус
      final doc = snapshot.docs.first;
      final currentTaken = doc.data()['taken'] == true;

      if (currentTaken) {
        // Было принято -> меняем на пропущено
        await doc.reference.update({
          'taken': false,
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print('📝 Обновлено: принято -> пропущено');
      } else {
        // Было пропущено -> удаляем запись (становится не отмечено)
        await doc.reference.delete();
        print('📝 Удалена запись: пропущено -> не отмечено');
      }
    }

    notifyListeners();
  }

  Future<bool?> getIntakeStatus(String scheduleId, DateTime intakeTime) async {
    if (currentUser == null) return null;

    final startOfMinute = DateTime(
      intakeTime.year,
      intakeTime.month,
      intakeTime.day,
      intakeTime.hour,
      intakeTime.minute,
    );
    final endOfMinute = startOfMinute.add(const Duration(minutes: 1));

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('schedules')
        .doc(scheduleId)
        .collection('intakes')
        .where('intakeTime', isGreaterThanOrEqualTo: Timestamp.fromDate(startOfMinute))
        .where('intakeTime', isLessThan: Timestamp.fromDate(endOfMinute))
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    return snapshot.docs.first.data()['taken'] == true;
  }

  // Получить общие лекарства (из коллекции drugs)
  Stream<List<Medicine>> getPublicMedicines() {
    return _firestore.collection('drugs').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        jsonData['isPersonal'] = false; // Помечаем как общее
        return Medicine.fromJson(jsonData);
      }).toList();
    });
  }

  Stream<List<Medicine>> getPersonalMedicines() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('medicines')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        jsonData['isPersonal'] = true;
        return Medicine.fromJson(jsonData);
      }).toList();
    });
  }

  Future<List<Medicine>> searchMedicines(String query) async {
    try {
      List<Medicine> results = [];

      String formattedQuery = '';
      if (query.isNotEmpty) {
        formattedQuery =
            query[0].toUpperCase() + query.substring(1).toLowerCase();
      }

      print('🔍 Поиск: "$query" -> отформатировано: "$formattedQuery"');

      // Ищем в общих лекарствах
      print('📚 Поиск в общих лекарствах...');
      QuerySnapshot publicSnapshot = await _firestore
          .collection('drugs')
          .where('name', isGreaterThanOrEqualTo: formattedQuery)
          .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
          .limit(20)
          .get();

      print('📊 Найдено в общих: ${publicSnapshot.docs.length}');

      final publicResults = publicSnapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        final Map<String, dynamic> jsonData = {...data};
        jsonData['id'] = doc.id;
        jsonData['isPersonal'] = false;
        return Medicine.fromJson(jsonData);
      }).toList();

      results.addAll(publicResults);

      // Ищем в личных лекарствах пользователя
      if (currentUser != null) {
        print('👤 Поиск в личных лекарствах пользователя...');
        try {
          QuerySnapshot personalSnapshot = await _firestore
              .collection('users')
              .doc(currentUser!.uid)
              .collection('medicines')
              .where('name', isGreaterThanOrEqualTo: formattedQuery)
              .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
              .limit(20)
              .get();

          print('📊 Найдено в личных: ${personalSnapshot.docs.length}');

          final personalResults = personalSnapshot.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            final Map<String, dynamic> jsonData = {...data};
            jsonData['id'] = doc.id;
            jsonData['isPersonal'] = true;
            return Medicine.fromJson(jsonData);
          }).toList();

          results.addAll(personalResults);
        } catch (e) {
          print('❌ Ошибка поиска в личных лекарствах: $e');
        }
      }

      // Сортируем результаты по имени
      results.sort((a, b) => a.name.compareTo(b.name));

      print('📊 Всего найдено: ${results.length}');
      return results;
    } catch (e) {
      print('❌ Ошибка поиска: $e');
      print('📚 Stack trace: ${StackTrace.current}');
      return [];
    }
  }

  // Поиск только в общих лекарствах (drugs)
  Future<List<Medicine>> searchPublicMedicines(String query) async {
    if (query.isEmpty) return [];

    String formattedQuery = query[0].toUpperCase() +
        query.substring(1).toLowerCase();

    QuerySnapshot snapshot = await _firestore
        .collection('drugs')
        .where('name', isGreaterThanOrEqualTo: formattedQuery)
        .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final Map<String, dynamic> jsonData = {...data};
      jsonData['id'] = doc.id;
      jsonData['isPersonal'] = false;
      return Medicine.fromJson(jsonData);
    }).toList();
  }

  // Поиск только в личных лекарствах (users/{uid}/medicines)
  Future<List<Medicine>> searchPersonalMedicines(String query) async {
    if (currentUser == null || query.isEmpty) return [];

    String formattedQuery = query[0].toUpperCase() +
        query.substring(1).toLowerCase();

    QuerySnapshot snapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('medicines')
        .where('name', isGreaterThanOrEqualTo: formattedQuery)
        .where('name', isLessThanOrEqualTo: '$formattedQuery\uf8ff')
        .limit(20)
        .get();

    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      final Map<String, dynamic> jsonData = {...data};
      jsonData['id'] = doc.id;
      jsonData['isPersonal'] = true;
      return Medicine.fromJson(jsonData);
    }).toList();
  }

  // Добавить личное лекарство
  Future<Medicine?> addPersonalMedicine(Medicine medicine) async {
    try {
      if (currentUser == null) throw Exception('Пользователь не авторизован');

      // Создаем данные для сохранения
      final data = medicine.toJson();
      data['createdAt'] =
          FieldValue.serverTimestamp(); // Используем серверное время

      DocumentReference docRef = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('medicines')
          .add(data);

      final newMedicine = medicine.copyWith(
        id: docRef.id,
        isPersonal: true,
        createdAt: DateTime.now(),
      );
      notifyListeners();
      return newMedicine;
    } catch (e) {
      print('❌ Ошибка добавления личного лекарства: $e');
      throw Exception('Ошибка добавления лекарства: $e');
    }
  }

  // Удалить личное лекарство
  Future<void> deletePersonalMedicine(String medicineId) async {
    try {
      if (currentUser == null) throw Exception('Пользователь не авторизован');

      // Сначала проверяем, есть ли расписания с этим лекарством
      final schedules = await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('schedules')
          .where('medicineId', isEqualTo: medicineId)
          .get();

      if (schedules.docs.isNotEmpty) {
        throw Exception(
          'Нельзя удалить лекарство, так как оно используется в расписаниях',
        );
      }

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('medicines')
          .doc(medicineId)
          .delete();

      notifyListeners();
    } catch (e) {
      print('❌ Ошибка удаления лекарства: $e');
      throw Exception('Ошибка удаления лекарства: $e');
    }
  }

  // Обновить личное лекарство
  Future<void> updatePersonalMedicine(Medicine medicine) async {
    try {
      if (currentUser == null) throw Exception('Пользователь не авторизован');
      if (medicine.id == null) throw Exception('ID лекарства не указан');

      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('medicines')
          .doc(medicine.id)
          .update({
        'name': medicine.name,
        'genericName': medicine.genericName,
        'dosageForm': medicine.dosageForm,
        'dosage': medicine.dosage,
        'manufacturer': medicine.manufacturer,
        'country': medicine.country,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      notifyListeners();
    } catch (e) {
      print('❌ Ошибка обновления лекарства: $e');
      throw Exception('Ошибка обновления лекарства: $e');
    }
  }

// Получить поток остатков
  Stream<List<Stock>> getStocks() {
    if (currentUser == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        final medicineId = data['medicineId'] as String; // теперь medicineId хранится внутри
        return Stock(
          medicineId: medicineId,
          currentAmount: (data['currentAmount'] as num).toDouble(),
          unit: data['unit'] as String? ?? 'мг',
          stockId: doc.id, // добавляем уникальный ID записи
        );
      }).toList();
    });
  }

// Создать или обновить остаток
  Future<void> upsertStock({
    required String medicineId,
    required double amount,
    required String unit,
  }) async {
    if (currentUser == null) return;

    // Проверяем, есть ли уже такая комбинация
    final existing = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .where('medicineId', isEqualTo: medicineId)
        .where('unit', isEqualTo: unit)
        .get();

    if (existing.docs.isNotEmpty) {
      // Если уже есть, обновляем количество
      final doc = existing.docs.first;
      final currentAmount = (doc.data()['currentAmount'] as num).toDouble();
      await doc.reference.update({
        'currentAmount': currentAmount + amount,
      });
    } else {
      // Если нет, создаем новую запись
      await _firestore
          .collection('users')
          .doc(currentUser!.uid)
          .collection('stocks')
          .add({
        'medicineId': medicineId,
        'currentAmount': amount,
        'unit': unit,
      });
    }
    notifyListeners();
  }

// Получить остаток для конкретного лекарства (возвращает первую найденную запись)
  Future<Stock?> getStockByMedicineId(String medicineId) async {
    if (currentUser == null) return null;

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .where('medicineId', isEqualTo: medicineId)
        .limit(1)  // берем первую запись
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    final data = doc.data();

    return Stock(
      stockId: doc.id,
      medicineId: data['medicineId'] as String,
      currentAmount: (data['currentAmount'] as num).toDouble(),
      unit: data['unit'] as String? ?? 'мг',
    );
  }

// Получить остаток для конкретного лекарства с КОНКРЕТНОЙ единицей измерения
  Future<Stock?> getStockByMedicineIdAndUnit(String medicineId, String unit) async {
    if (currentUser == null) return null;

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .where('medicineId', isEqualTo: medicineId)
        .where('unit', isEqualTo: unit)
        .limit(1)
        .get();

    if (querySnapshot.docs.isEmpty) return null;

    final doc = querySnapshot.docs.first;
    final data = doc.data();

    return Stock(
      stockId: doc.id,
      medicineId: data['medicineId'] as String,
      currentAmount: (data['currentAmount'] as num).toDouble(),
      unit: data['unit'] as String? ?? 'мг',
    );
  }

// Получить ВСЕ остатки для конкретного лекарства (если есть в разных единицах)
  Future<List<Stock>> getAllStocksByMedicineId(String medicineId) async {
    if (currentUser == null) return [];

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .where('medicineId', isEqualTo: medicineId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return Stock(
        stockId: doc.id,
        medicineId: data['medicineId'] as String,
        currentAmount: (data['currentAmount'] as num).toDouble(),
        unit: data['unit'] as String? ?? 'мг',
      );
    }).toList();
  }

// Уменьшить остаток по ID записи в аптечке
  Future<void> decrementStockById(String stockId, {double amount = 1.0}) async {
    if (currentUser == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .doc(stockId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentAmount = (doc.data()!['currentAmount'] as num).toDouble();
    final newAmount = (currentAmount - amount).clamp(0.0, double.infinity);
    final unit = doc.data()!['unit'] as String? ?? 'мг';

    await docRef.update({
      'currentAmount': newAmount,
    });

    // Уведомления при низком остатке
    if (newAmount <= 5.0 && newAmount > 0) {
      await NotificationService().showInstantNotification(
        title: '⚠️ Заканчивается лекарство',
        body: 'Осталось всего $newAmount $unit',
      );
    } else if (newAmount == 0) {
      await NotificationService().showInstantNotification(
        title: '❌ Лекарство закончилось',
        body: 'Срочно пополните запас!',
      );
    }

    notifyListeners();
  }

// Старый метод для обратной совместимости
  Future<void> decrementStock(String medicineId, {double amount = 1.0, String? scheduleUnit}) async {
    // Просто вызываем новый метод, найдя нужный stock
    if (scheduleUnit != null) {
      final stock = await getStockByMedicineIdAndUnit(medicineId, scheduleUnit);
      if (stock != null) {
        await decrementStockById(stock.stockId, amount: amount);
      }
    } else {
      final stock = await getStockByMedicineId(medicineId);
      if (stock != null) {
        await decrementStockById(stock.stockId, amount: amount);
      }
    }
  }

// Пополнить остаток (по ID записи)
  Future<void> refillStockById(String stockId, double additionalAmount) async {
    if (currentUser == null) return;

    final docRef = _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .doc(stockId);

    final doc = await docRef.get();
    if (!doc.exists) return;

    final currentAmount = (doc.data()!['currentAmount'] as num).toDouble();
    final newAmount = currentAmount + additionalAmount;

    await docRef.update({
      'currentAmount': newAmount,
    });

    notifyListeners();
  }

// Пополнить остаток по medicineId и unit
  Future<void> refillStock(String medicineId, double additionalAmount, {String? unit}) async {
    if (currentUser == null) return;

    Stock? stock;
    if (unit != null) {
      stock = await getStockByMedicineIdAndUnit(medicineId, unit);
    } else {
      stock = await getStockByMedicineId(medicineId);
    }

    if (stock == null) return;

    await refillStockById(stock.stockId, additionalAmount);
  }

// Удалить запись из аптечки по ID
  Future<void> deleteStockById(String stockId) async {
    if (currentUser == null) return;

    await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .doc(stockId)
        .delete();

    notifyListeners();
  }

// Удалить ВСЕ записи лекарства из аптечки (по medicineId)
  Future<void> deleteAllStocksByMedicineId(String medicineId) async {
    if (currentUser == null) return;

    final querySnapshot = await _firestore
        .collection('users')
        .doc(currentUser!.uid)
        .collection('stocks')
        .where('medicineId', isEqualTo: medicineId)
        .get();

    final batch = _firestore.batch();
    for (var doc in querySnapshot.docs) {
      batch.delete(doc.reference);
    }
    await batch.commit();

    notifyListeners();
  }

  Future<void> deleteStock(String medicineId) async {
    await deleteAllStocksByMedicineId(medicineId);
  }
}