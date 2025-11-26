import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bookeep/main.dart';

void main() {
  group('Widget Tests', () {
    testWidgets('MyHomePage displays correct title', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Bookeep'), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('Form fields are present', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.widgetWithText(TextField, 'Book Title'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Word Count'), findsOneWidget);
      expect(find.text('No date selected'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Submit'), findsOneWidget);
    });

    testWidgets('Word count field formats numbers with commas',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      // Find the word count text field
      final wordCountField = find.widgetWithText(TextField, 'Word Count');

      // Enter a number without commas
      await tester.enterText(wordCountField, '50000');
      await tester.pump();

      // The field should format it with commas
      expect(find.text('50,000'), findsOneWidget);
    });

    testWidgets('Word count field formats large numbers correctly',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final wordCountField = find.widgetWithText(TextField, 'Word Count');

      await tester.enterText(wordCountField, '1234567');
      await tester.pump();

      expect(find.text('1,234,567'), findsOneWidget);
    });

    testWidgets('Word count field removes non-numeric characters',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final wordCountField = find.widgetWithText(TextField, 'Word Count');

      // Try entering text with letters and symbols
      await tester.enterText(wordCountField, 'abc123def456');
      await tester.pump();

      // Should only keep digits and format them
      expect(find.text('123,456'), findsOneWidget);
    });

    testWidgets('Statistics boxes display correctly', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Word Count (All)'), findsOneWidget);
      expect(find.textContaining('Word Count ('), findsAtLeastNWidgets(2)); // Finds both "All" and year-specific
      expect(find.text('Books Read'), findsOneWidget);
      expect(find.textContaining('Points ('), findsOneWidget);
    });

    testWidgets('Search field is present in book shelf',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.text('Book Shelf'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Search books'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
    });

    testWidgets('Wrapped button is in app bar', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.byIcon(Icons.auto_awesome), findsOneWidget);
    });

    testWidgets('Date picker button shows select date text',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      expect(find.widgetWithText(ElevatedButton, 'Select Date'), findsOneWidget);
    });

    testWidgets('Submit button is disabled until all fields are filled',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final submitButton = find.widgetWithText(ElevatedButton, 'Submit');
      
      // Tap submit without filling fields
      await tester.tap(submitButton);
      await tester.pump();

      // Should show error snackbar
      expect(find.text('Fill all fields'), findsOneWidget);
    });
  });

  group('Book Tile Widget Tests', () {
    testWidgets('EditableBookTile displays book information in view mode',
        (WidgetTester tester) async {
      final testBook = Book(
        id: '123',
        title: 'Test Book',
        wordCount: 50000,
        dateRead: '11-26-2025',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableBookTile(
              book: testBook,
              onDelete: (_) {},
              onSave: (_) {},
              onDatePick: (_) {},
            ),
          ),
        ),
      );

      expect(find.text('Test Book'), findsOneWidget);
      expect(find.textContaining('Words: 50,000'), findsOneWidget);
      expect(find.textContaining('Date: 11-26-2025'), findsOneWidget);
      expect(find.byIcon(Icons.edit), findsOneWidget);
      expect(find.byIcon(Icons.delete), findsOneWidget);
    });

    testWidgets('EditableBookTile enters edit mode when edit button tapped',
        (WidgetTester tester) async {
      final testBook = Book(
        id: '123',
        title: 'Test Book',
        wordCount: 50000,
        dateRead: '11-26-2025',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableBookTile(
              book: testBook,
              onDelete: (_) {},
              onSave: (_) {},
              onDatePick: (_) {},
            ),
          ),
        ),
      );

      // Tap edit button
      await tester.tap(find.byIcon(Icons.edit));
      await tester.pump();

      // Should show edit fields
      expect(find.widgetWithText(TextField, 'Edit Title'), findsOneWidget);
      expect(find.widgetWithText(TextField, 'Edit Word Count'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Save'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Cancel'), findsOneWidget);
    });

    testWidgets('EditableBookTile shows delete confirmation dialog',
        (WidgetTester tester) async {
      final testBook = Book(
        id: '123',
        title: 'Test Book',
        wordCount: 50000,
        dateRead: '11-26-2025',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EditableBookTile(
              book: testBook,
              onDelete: (_) {},
              onSave: (_) {},
              onDatePick: (_) {},
            ),
          ),
        ),
      );

      // Tap delete button
      await tester.tap(find.byIcon(Icons.delete));
      await tester.pumpAndSettle();

      // Should show confirmation dialog
      expect(find.text('Delete Book?'), findsOneWidget);
      expect(find.textContaining('Are you sure'), findsOneWidget);
      expect(find.widgetWithText(TextButton, 'Cancel'), findsOneWidget);
      expect(find.widgetWithText(ElevatedButton, 'Delete'), findsOneWidget);
    });
  });

  group('Wrapped Screen Widget Tests', () {
    testWidgets('WrappedScreen displays wrapped data correctly',
        (WidgetTester tester) async {
      final wrappedData = {
        'year': 2025,
        'totalBooks': 10,
        'totalWords': 500000,
        'points': 50.0,
        'topBooks': [
          {'title': 'Book 1', 'wordCount': 100000},
          {'title': 'Book 2', 'wordCount': 80000},
        ]
      };

      await tester.pumpWidget(
        MaterialApp(
          home: WrappedScreen(wrappedData: wrappedData),
        ),
      );

      expect(find.text('2025'), findsOneWidget);
      expect(find.text('WRAPPED'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
      expect(find.text('500,000'), findsOneWidget);
      expect(find.text('50.0'), findsOneWidget);
      expect(find.text('TOP READS'), findsOneWidget);
      expect(find.text('Book 1'), findsOneWidget);
      expect(find.text('Book 2'), findsOneWidget);
    });

    testWidgets('WrappedScreen has screenshot button',
        (WidgetTester tester) async {
      final wrappedData = {
        'year': 2025,
        'totalBooks': 5,
        'totalWords': 250000,
        'points': 25.0,
        'topBooks': []
      };

      await tester.pumpWidget(
        MaterialApp(
          home: WrappedScreen(wrappedData: wrappedData),
        ),
      );

      expect(find.byIcon(Icons.screenshot), findsOneWidget);
    });

    testWidgets('WrappedScreen handles empty top books list',
        (WidgetTester tester) async {
      final wrappedData = {
        'year': 2025,
        'totalBooks': 0,
        'totalWords': 0,
        'points': 0.0,
        'topBooks': []
      };

      await tester.pumpWidget(
        MaterialApp(
          home: WrappedScreen(wrappedData: wrappedData),
        ),
      );

      expect(find.text('2025'), findsOneWidget);
      expect(find.text('0'), findsAtLeastNWidgets(2)); // totalBooks and totalWords
      expect(find.text('TOP READS'), findsNothing); // Should not show if no books
    });
  });

  group('Statistics Integration Tests', () {
    testWidgets('Adding text to title field works', (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final titleField = find.widgetWithText(TextField, 'Book Title');
      await tester.enterText(titleField, 'My New Book');
      await tester.pump();

      expect(find.text('My New Book'), findsOneWidget);
    });

    testWidgets('Statistics display with formatted numbers',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());
      await tester.pumpAndSettle();

      // Look for the statistics box
      expect(find.text('Word Count (All)'), findsOneWidget);
      expect(find.text('Books Read'), findsOneWidget);
    });

    testWidgets('Search field filters books (UI only)',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MyApp());

      final searchField = find.widgetWithText(TextField, 'Search books');
      await tester.enterText(searchField, 'test search');
      await tester.pump();

      expect(find.text('test search'), findsOneWidget);
    });
  });
}
