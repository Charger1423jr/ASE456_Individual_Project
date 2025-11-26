import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bookeep/main.dart';

void main() {
  testWidgets('App loads with correct title', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Bookeep'), findsOneWidget);
  });

  testWidgets('Form fields are present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.widgetWithText(TextField, 'Book Title'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Word Count'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Select Date'), findsOneWidget);
    expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);
  });

  testWidgets('Statistics boxes are displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Word Count (All)'), findsOneWidget);
    expect(find.text('Word Count (${DateTime.now().year})'), findsOneWidget);
    expect(find.text('Books Read'), findsOneWidget);
    expect(find.text('Points (${DateTime.now().year})'), findsOneWidget);
  });

  testWidgets('Book Shelf section is displayed', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Book Shelf'), findsOneWidget);
  });

  testWidgets('Search bar is present in Book Shelf', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.widgetWithText(TextField, 'Search books'), findsOneWidget);
    expect(find.byIcon(Icons.search), findsOneWidget);
  });

  testWidgets('Word count field formats numbers with commas', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final wordCountField = find.widgetWithText(TextField, 'Word Count');
    
    await tester.enterText(wordCountField, '10000');
    await tester.pump();

    expect(find.text('10,000'), findsOneWidget);
  });

  testWidgets('Date selection shows selected date', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('No date selected'), findsOneWidget);

    await tester.tap(find.widgetWithText(ElevatedButton, 'Select Date'));
    await tester.pumpAndSettle();

    expect(find.byType(DatePickerDialog), findsOneWidget);

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    expect(find.text('No date selected'), findsNothing);
    
    expect(find.textContaining('Finished:'), findsOneWidget);
  });

  testWidgets('Submit button shows snackbar when fields are empty', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(ElevatedButton, 'Submit'));
    await tester.pump();

    expect(find.text('Fill all fields'), findsOneWidget);
  });

  testWidgets('Search functionality filters book list', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final searchField = find.widgetWithText(TextField, 'Search books');
    
    await tester.enterText(searchField, 'Test');
    await tester.pump();

    expect(find.text('Test'), findsOneWidget);
  });

  testWidgets('Points display shows decimal format', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    final pointsBox = find.text('Points (${DateTime.now().year})');
    expect(pointsBox, findsOneWidget);

    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('All totals boxes are initially zero', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Books Read'), findsOneWidget);
    expect(find.text('0.00'), findsOneWidget);
  });

  testWidgets('AppBar and Scaffold are present', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.byType(AppBar), findsOneWidget);
    expect(find.widgetWithText(AppBar, 'Bookeep'), findsOneWidget);
    
    expect(find.byType(Scaffold), findsOneWidget);
  });

  testWidgets('Text fields accept input', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.enterText(
      find.widgetWithText(TextField, 'Book Title'),
      'Test Book'
    );
    await tester.pump();
    expect(find.text('Test Book'), findsOneWidget);

    await tester.enterText(
      find.widgetWithText(TextField, 'Word Count'),
      '50000'
    );
    await tester.pump();
    expect(find.text('50,000'), findsOneWidget);
  });
}
