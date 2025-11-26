import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:bookeep/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Bookeep Integration Tests', () {
    testWidgets('Full workflow: Add, Search, Edit, and Delete book',
        (WidgetTester tester) async {
      // Launch app
      app.main();
      await tester.pumpAndSettle();

      // Verify app loads with correct title
      expect(find.text('Bookeep'), findsOneWidget);

      // Test adding a new book
      await tester.enterText(
          find.byType(TextField).at(0), 'The Great Gatsby');
      await tester.enterText(find.byType(TextField).at(1), '47094');

      // Select date
      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      // Submit book
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify book appears in list
      expect(find.text('The Great Gatsby'), findsOneWidget);
      expect(find.textContaining('Words: 47,094'), findsOneWidget);

      // Test search functionality
      await tester.enterText(
          find.widgetWithText(TextField, 'Search books'), 'Gatsby');
      await tester.pumpAndSettle();

      expect(find.text('The Great Gatsby'), findsOneWidget);

      // Clear search
      await tester.enterText(
          find.widgetWithText(TextField, 'Search books'), '');
      await tester.pumpAndSettle();

      // Test editing a book
      await tester.tap(find.byIcon(Icons.edit).first);
      await tester.pumpAndSettle();

      final editTitleField = find.widgetWithText(TextField, 'Edit Title');
      await tester.enterText(editTitleField, 'The Great Gatsby (Revised)');

      final editWordCountField =
          find.widgetWithText(TextField, 'Edit Word Count');
      await tester.enterText(editWordCountField, '50000');

      await tester.tap(find.text('Save'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify edit was successful
      expect(find.text('The Great Gatsby (Revised)'), findsOneWidget);
      expect(find.textContaining('Words: 50,000'), findsOneWidget);

      // Test delete confirmation dialog
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();

      expect(find.text('Delete Book?'), findsOneWidget);
      expect(find.textContaining('Are you sure'), findsOneWidget);

      // Cancel deletion
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();

      // Verify book still exists
      expect(find.text('The Great Gatsby (Revised)'), findsOneWidget);

      // Delete the book
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify book is removed
      expect(find.text('The Great Gatsby (Revised)'), findsNothing);
    });

    testWidgets('Statistics update when books are added',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Get initial stats
      final initialBooksCount =
          find.textContaining('Books Read').evaluate().isNotEmpty;

      // Add a book
      await tester.enterText(find.byType(TextField).at(0), '1984');
      await tester.enterText(find.byType(TextField).at(1), '88942');

      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify statistics updated
      expect(find.textContaining('Words: 88,942'), findsOneWidget);
      expect(find.text('Books Read'), findsOneWidget);

      // Clean up - delete the test book
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Wrapped screen displays year statistics',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Add a test book first
      await tester.enterText(find.byType(TextField).at(0), 'Test Wrapped Book');
      await tester.enterText(find.byType(TextField).at(1), '100000');

      await tester.tap(find.text('Select Date'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navigate to Wrapped screen
      await tester.tap(find.byIcon(Icons.auto_awesome));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verify Wrapped screen elements
      expect(find.text('WRAPPED'), findsOneWidget);
      expect(find.text('BOOKS READ'), findsOneWidget);
      expect(find.text('TOTAL WORDS'), findsOneWidget);
      expect(find.text('POINTS EARNED'), findsOneWidget);

      // Go back
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Clean up
      await tester.tap(find.byIcon(Icons.delete).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Delete'));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Form validation prevents incomplete submissions',
        (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Try to submit with empty fields
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Should show snackbar error
      expect(find.text('Fill all fields'), findsOneWidget);

      // Fill only title
      await tester.enterText(find.byType(TextField).at(0), 'Incomplete Book');
      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      // Should still show error
      expect(find.text('Fill all fields'), findsOneWidget);
    });
  });
}
