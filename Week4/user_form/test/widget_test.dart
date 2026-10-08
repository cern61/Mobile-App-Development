import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:user_form/main.dart';

void main() {
  testWidgets('Home page navigates to the form page', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Hello World'), findsOneWidget);

    await tester.tap(find.text('Go to Form Page'));
    await tester.pumpAndSettle();

    expect(find.text('User Form'), findsOneWidget);
    expect(find.text('Register'), findsOneWidget);
    expect(find.text('Clear'), findsOneWidget);
  });

  testWidgets('Empty form shows a warning', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.tap(find.text('Go to Form Page'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Register'));
    await tester.tap(find.text('Register'));
    await tester.pump();

    expect(find.text('Please fill in all fields.'), findsOneWidget);
  });
}
