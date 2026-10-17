import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:profile_card_app/main.dart';
import 'package:profile_card_app/widgets/profile_card.dart';

/// Pumps the app and waits for the simulated 2-second API call to finish.
Future<void> pumpLoadedApp(WidgetTester tester) async {
  await tester.pumpWidget(const MyApp());
  await tester.pump(const Duration(seconds: 2));
  await tester.pumpAndSettle();
}

Finder navItem(String label) => find.descendant(
      of: find.byType(NavigationBar),
      matching: find.text(label),
    );

Finder appBarTitle(String title) => find.descendant(
      of: find.byType(AppBar),
      matching: find.text(title),
    );

void main() {
  testWidgets('shows a loading indicator, then the profile card',
      (tester) async {
    await tester.pumpWidget(const MyApp());
    expect(find.text('Loading profile...'), findsOneWidget);
    expect(find.byType(ProfileCard), findsNothing);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    expect(find.text('Loading profile...'), findsNothing);
    expect(find.byType(ProfileCard), findsOneWidget);
  });

  testWidgets('bottom navigation bar switches between the pages',
      (tester) async {
    await pumpLoadedApp(tester);
    expect(appBarTitle('Profile Card'), findsOneWidget);

    await tester.tap(navItem('About'));
    await tester.pumpAndSettle();
    expect(appBarTitle('About'), findsOneWidget);

    await tester.tap(navItem('Mission'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Mission & Vision'), findsOneWidget);

    await tester.tap(navItem('Contact'));
    await tester.pumpAndSettle();
    expect(appBarTitle('Contact'), findsOneWidget);
  });

  testWidgets('message dialog validates and then "sends" the message',
      (tester) async {
    await pumpLoadedApp(tester);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Message'));
    await tester.pumpAndSettle();
    expect(find.text('New Message'), findsOneWidget);

    // Empty message -> validation error.
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('Please write a message.'), findsOneWidget);

    // Valid message -> sending state, then the dialog closes with a snackbar.
    await tester.enterText(
      find.widgetWithText(TextFormField, 'Your message'),
      'Hello!',
    );
    await tester.tap(find.text('Send'));
    await tester.pump();
    expect(find.text('Sending...'), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1300));
    await tester.pumpAndSettle();
    expect(find.text('New Message'), findsNothing);
    expect(find.textContaining('Sent to'), findsOneWidget);
  });

  testWidgets('email channel requires a subject', (tester) async {
    await pumpLoadedApp(tester);

    await tester.tap(find.widgetWithText(FloatingActionButton, 'Message'));
    await tester.pumpAndSettle();

    await tester.tap(
      find.descendant(of: find.byType(Dialog), matching: find.text('Email')),
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextFormField, 'Your message'),
      'Hi there',
    );
    await tester.tap(find.text('Send'));
    await tester.pump();

    expect(find.text('Please enter a subject for the email.'), findsOneWidget);
  });
}
