import 'package:flutter_test/flutter_test.dart';
import 'package:bookeep/main.dart'; // Adjust import path as needed

void main() {
  group('Book Model Unit Tests', () {
    test('Book.fromJson creates valid Book object', () {
      final json = {
        '_id': '123',
        'title': 'Test Book',
        'wordCount': 50000,
        'dateRead': '11-26-2025'
      };

      final book = Book.fromJson(json);

      expect(book.id, '123');
      expect(book.title, 'Test Book');
      expect(book.wordCount, 50000);
      expect(book.dateRead, '11-26-2025');
    });

    test('Book.fromJson handles missing fields gracefully', () {
      final json = {'title': 'Partial Book'};

      final book = Book.fromJson(json);

      expect(book.id, null);
      expect(book.title, 'Partial Book');
      expect(book.wordCount, 0);
      expect(book.dateRead, '');
    });

    test('Book.toJson creates valid JSON', () {
      final book = Book(
        id: '456',
        title: 'Flutter Guide',
        wordCount: 75000,
        dateRead: '12-1-2025',
      );

      final json = book.toJson();

      expect(json['title'], 'Flutter Guide');
      expect(json['wordCount'], 75000);
      expect(json['dateRead'], '12-1-2025');
      expect(json.containsKey('_id'), false); // ID not included in toJson
    });

    test('parseDate correctly parses valid date string', () {
      final book = Book(
        title: 'Test',
        wordCount: 1000,
        dateRead: '3-15-2024',
      );

      final date = book.parseDate();

      expect(date.year, 2024);
      expect(date.month, 3);
      expect(date.day, 15);
    });

    test('parseDate returns current date for invalid format', () {
      final book = Book(
        title: 'Test',
        wordCount: 1000,
        dateRead: 'invalid-date',
      );

      final date = book.parseDate();

      expect(date, isNotNull);
      expect(date.year, DateTime.now().year);
    });

    test('dateReadYear returns correct year', () {
      final book = Book(
        title: 'Test',
        wordCount: 1000,
        dateRead: '6-20-2023',
      );

      expect(book.dateReadYear(), 2023);
    });
  });

  group('Word Count Calculations', () {
    test('Calculate total words from book list', () {
      final books = [
        Book(title: 'Book 1', wordCount: 50000, dateRead: '1-1-2025'),
        Book(title: 'Book 2', wordCount: 75000, dateRead: '2-1-2025'),
        Book(title: 'Book 3', wordCount: 25000, dateRead: '3-1-2025'),
      ];

      final total = books.fold<int>(0, (sum, b) => sum + b.wordCount);

      expect(total, 150000);
    });

    test('Calculate year-specific words', () {
      final books = [
        Book(title: 'Book 1', wordCount: 50000, dateRead: '1-1-2025'),
        Book(title: 'Book 2', wordCount: 75000, dateRead: '2-1-2024'),
        Book(title: 'Book 3', wordCount: 25000, dateRead: '3-1-2025'),
      ];

      final year2025Words = books
          .where((b) => b.dateReadYear() == 2025)
          .fold<int>(0, (sum, b) => sum + b.wordCount);

      expect(year2025Words, 75000);
    });

    test('Calculate points from word count', () {
      final wordCount = 50000;
      final points = wordCount / 10000.0;

      expect(points, 5.0);
    });
  });
}
