import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lab11/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('интеграционный тест изменения и просмотра товара', () {
    testWidgets('изменение данных -> вернуться в меню -> перейти к изображению',
            (WidgetTester tester) async {
          app.main();

          await tester.pumpAndSettle(const Duration(seconds: 10));
          print('Вход');

          final emailField = find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Email');
          await tester.enterText(emailField, '12345@gmail.com');

          final passwordField = find.byWidgetPredicate((widget) =>
          widget is TextField && widget.decoration?.labelText == 'Password');
          await tester.enterText(passwordField, '123456');

          expect(find.text('12345@gmail.com'), findsOneWidget);
          expect(find.text('123456'), findsOneWidget);

          final loginButton = find.text('Login');
          expect(loginButton, findsOneWidget);

          await tester.tap(loginButton);
          await tester.pumpAndSettle(const Duration(seconds: 10));

          print('выбор тестируемого изображения');
          final foodCard = find.byType(app.FoodCard).first;

          expect(foodCard, findsOneWidget);
          await tester.longPress(foodCard);
          await tester.pumpAndSettle();

          final editMenuItem = find.text('Изменить');
          expect(editMenuItem, findsOneWidget);

          await tester.tap(editMenuItem);
          await tester.pumpAndSettle();

          print('Изменение данных');

          final titleField = find.byType(TextFormField).at(1);
          await tester.enterText(titleField, 'test');

          final subtitleField  = find.byType(TextFormField).at(2);
          await tester.enterText(subtitleField, 'TEST');

          final priceField  = find.byType(TextFormField).at(3);
          await tester.enterText(priceField, '10');


          final updateButton = find.text('Update Food Item');
          await tester.tap(updateButton);
          await tester.pumpAndSettle();
          await tester.pumpAndSettle(const Duration(seconds: 10));

          print('просмотр и проверка данных');
          final updatedCard = find.byType(app.FoodCard).first;
          await tester.tap(updatedCard);
          await tester.pumpAndSettle();

          expect(find.text('test'), findsOneWidget);
          print('title успешно изменен');
          expect(find.text('TEST'), findsOneWidget);
          print('subtitle успешно изменен');
          expect(find.text('Order for \$10'), findsOneWidget);
          print('price успешно изменен');

        });
  });
}