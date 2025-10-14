import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

const String apiUrl = "http://localhost:5000/api/books";

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bookeep',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Bookeep'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _wordCountController = TextEditingController();
  DateTime? _selectedDate;

  List<Book> _books = [];

  @override
  void initState() {
    super.initState();
    _fetchBooks();
  }

  Future<void> _fetchBooks() async {
    try {
      final resp = await http.get(Uri.parse(apiUrl));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        setState(() {
          _books = data.map((e) => Book.fromJson(e)).toList();
        });
      } else {
        debugPrint('Failed to load books: ${resp.statusCode}');
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
    }
  }

  Future<void> _addBook() async {
    if (_titleController.text.trim().isEmpty ||
        _wordCountController.text.trim().isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }

    final formattedDate =
        '${_selectedDate!.month}-${_selectedDate!.day}-${_selectedDate!.year}';

    final book = Book(
      title: _titleController.text.trim(),
      wordCount: int.tryParse(_wordCountController.text.trim()) ?? 0,
      dateRead: formattedDate,
    );

    try {
      final resp = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      );

      if (resp.statusCode == 200 || resp.statusCode == 201) {
        _titleController.clear();
        _wordCountController.clear();
        setState(() => _selectedDate = null);
        await _fetchBooks();
      } else {
        debugPrint('Error saving book: ${resp.statusCode} ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint('Exception saving book: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error saving book')),
      );
    }
  }

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalBooks = _books.length;
    final totalWordCount = _books.fold<int>(0, (s, b) => s + b.wordCount);
    final points = totalWordCount / 10000.0;
    final pointsDisplay = points.toStringAsFixed(2).padLeft(5, '0');

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    labelText: 'Book Title',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _wordCountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Word Count',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _selectedDate == null
                            ? 'No date selected'
                            : 'Date Read: ${_selectedDate!.month}-${_selectedDate!.day}-${_selectedDate!.year}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () => _pickDate(context),
                      child: const Text('Select Date'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _addBook,
                  child: const Text('Submit'),
                ),
                const SizedBox(height: 30),

                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Total Books Read: $totalBooks',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                        Text('Total Word Count: $totalWordCount',
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.deepPurple),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Points Total: $pointsDisplay',
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                const Divider(),
                const SizedBox(height: 8),
                const Text('Books Entered',
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),

                _books.isEmpty
                    ? const Text('No books yet.')
                    : ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _books.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final b = _books[index];
                          return ListTile(
                            title: Text(b.title),
                            subtitle: Text('Words: ${b.wordCount}  •  Date: ${b.dateRead}'),
                          );
                        },
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Book {
  final String title;
  final int wordCount;
  final String dateRead;

  Book({
    required this.title,
    required this.wordCount,
    required this.dateRead,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      title: json['title']?.toString() ?? '',
      wordCount: (json['wordCount'] is int)
          ? json['wordCount'] as int
          : int.tryParse(json['wordCount']?.toString() ?? '0') ?? 0,
      dateRead: json['dateRead']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'title': title,
        'wordCount': wordCount,
        'dateRead': dateRead,
      };
}
