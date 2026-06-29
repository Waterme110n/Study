// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lab11/AddFoodPage.dart';

void main() {
  testWidgets('text input', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddFoodItemPage()));

    await tester.enterText(find.byType(TextFormField).at(0), 'Pizza');
    expect(find.text('Pizza'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(1), 'Delicious');
    expect(find.text('Delicious'), findsOneWidget);

  });
  testWidgets('input number', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddFoodItemPage()));

    await tester.enterText(find.byType(TextFormField).at(2), '10');
    expect(find.text('10'), findsOneWidget);
  });
  testWidgets('Pro Item checkbox', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddFoodItemPage()));

    expect(find.byType(Checkbox).first, findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isFalse);

    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
  });
  testWidgets('Hot Item checkbox', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddFoodItemPage()));

    expect(find.byType(Checkbox).at(1), findsOneWidget);
    expect(tester.widget<Checkbox>(find.byType(Checkbox).at(1)).value, isFalse);

    await tester.tap(find.byType(Checkbox).at(1));
    await tester.pump();

    expect(tester.widget<Checkbox>(find.byType(Checkbox).at(1)).value, isTrue);
  });
  testWidgets('Draggable button', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(home: AddFoodItemPage()));

    final buttonFinder = find.byType(ElevatedButton).first;
    final initialPosition = tester.getCenter(buttonFinder);

    await tester.drag(buttonFinder, Offset(50, 50));
    await tester.pumpAndSettle();

    final newPosition = tester.getCenter(buttonFinder);

    expect(newPosition.dx, isNot(equals(initialPosition.dx)));
    expect(newPosition.dy, isNot(equals(initialPosition.dy)));
  });

}