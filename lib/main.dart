import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui';

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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepOrange,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: const Color(0xFFF5E9D3),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFFCC8B4A),
          foregroundColor: Colors.white,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFE29A58),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          ),
        ),
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

String _cleanNumberString(String input) {
  return input.replaceAll(RegExp(r'[^0-9]'), '');
}

String _formatNumberString(String input) {
  final digits = _cleanNumberString(input);
  if (digits.isEmpty) return '';
  String s = digits;
  final reg = RegExp(r'(\d+)(\d{3})');
  while (reg.hasMatch(s)) {
    s = s.replaceAllMapped(reg, (m) => '${m[1]},${m[2]}');
  }
  return s;
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

    _wordCountController.addListener(() {
      final raw = _wordCountController.text;
      final formatted = _formatNumberString(raw);
      if (formatted != raw) {
        _wordCountController
          ..text = formatted
          ..selection = TextSelection.collapsed(offset: formatted.length);
      }
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _wordCountController.dispose();
    super.dispose();
  }

  Future<void> _fetchBooks() async {
    try {
      final resp = await http.get(Uri.parse(apiUrl));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        setState(() {
          _books = data.map((e) => Book.fromJson(e)).toList();
        });
      }
    } catch (e) {
      debugPrint('Error fetching books: $e');
    }
  }

  Future<void> _addBook() async {
    if (_titleController.text.isEmpty ||
        _wordCountController.text.isEmpty ||
        _selectedDate == null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Fill all fields")));
      return;
    }

    final cleaned = _cleanNumberString(_wordCountController.text);
    final wordCountParsed = int.tryParse(cleaned) ?? 0;

    final book = Book(
      id: null,
      title: _titleController.text,
      wordCount: wordCountParsed,
      dateRead:
          "${_selectedDate!.month}-${_selectedDate!.day}-${_selectedDate!.year}",
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
        _selectedDate = null;
        _fetchBooks();
      } else {
        debugPrint('Add book returned status: ${resp.statusCode} ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("Error saving: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error saving book')),
      );
    }
  }

  Future<void> _pickDate(BuildContext context, Function(DateTime) onSelect) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      onSelect(picked);
    }
  }

  Future<void> _updateBook(Book book) async {
    try {
      final resp = await http.put(
        Uri.parse("$apiUrl/${book.id}"),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(book.toJson()),
      );
      if (resp.statusCode == 200) {
        _fetchBooks();
      } else {
        debugPrint('Update returned ${resp.statusCode}: ${resp.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Update failed: ${resp.statusCode}')),
        );
      }
    } catch (e) {
      debugPrint("Update error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error updating book')),
      );
    }
  }

  Future<void> _deleteBook(Book book) async {
    try {
      final resp = await http.delete(Uri.parse("$apiUrl/${book.id}"));
      if (resp.statusCode == 200) {
        _fetchBooks();
      } else {
        debugPrint('Delete returned ${resp.statusCode}: ${resp.body}');
      }
    } catch (e) {
      debugPrint("Delete error: $e");
    }
  }

  int _yearWordCount() {
    int currentYear = DateTime.now().year;
    return _books
        .where((b) => b.dateReadYear() == currentYear)
        .fold(0, (sum, b) => sum + b.wordCount);
  }

  @override
  Widget build(BuildContext context) {
    final totalBooks = _books.length;

    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    decoration: const InputDecoration(
                      labelText: "Book Title",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _wordCountController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: "Word Count",
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(_selectedDate == null
                            ? "No date selected"
                            : "Finished: ${_selectedDate!.month}-${_selectedDate!.day}-${_selectedDate!.year}"),
                      ),
                      ElevatedButton(
                        onPressed: () =>
                            _pickDate(context, (d) => setState(() => _selectedDate = d)),
                        child: const Text("Select Date"),
                      )
                    ],
                  ),
                  const SizedBox(height: 18),
                  ElevatedButton(
                    onPressed: _addBook,
                    child: const Text("Submit"),
                  ),
                  const SizedBox(height: 25),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3E0),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.brown),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Books Read: $totalBooks",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          "Word Count This Year (${DateTime.now().year}): ${_formatNumberString(_yearWordCount().toString())}",
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const Text("Books Entered",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: _books.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return EditableBookTile(
                        key: ValueKey(_books[index].id),
                        book: _books[index],
                        onDelete: _deleteBook,
                        onSave: _updateBook,
                        onDatePick: (fn) => _pickDate(context, fn),
                      );
                    },
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class EditableBookTile extends StatefulWidget {
  final Book book;
  final Function(Book) onSave;
  final Function(Book) onDelete;
  final Function(Function(DateTime)) onDatePick;

  const EditableBookTile({
    super.key,
    required this.book,
    required this.onSave,
    required this.onDelete,
    required this.onDatePick,
  });

  @override
  State<EditableBookTile> createState() => _EditableBookTileState();
}

class _EditableBookTileState extends State<EditableBookTile> {
  bool editing = false;
  late TextEditingController titleC;
  late TextEditingController wcC;
  late DateTime selectedDate;

  @override
  void initState() {
    super.initState();
    titleC = TextEditingController(text: widget.book.title);
    wcC = TextEditingController(text: _formatNumberString(widget.book.wordCount.toString()));
    selectedDate = widget.book.parseDate();

    wcC.addListener(() {
      final raw = wcC.text;
      final formatted = _formatNumberString(raw);
      if (formatted != raw) {
        wcC
          ..text = formatted
          ..selection = TextSelection.collapsed(offset: formatted.length);
      }
    });
  }

  @override
  void dispose() {
    titleC.dispose();
    wcC.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: AlertDialog(
            title: const Text("Delete Book?"),
            content: Text("Are you sure you want to delete '${widget.book.title}'?"),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              ElevatedButton(
                onPressed: () {
                  widget.onDelete(widget.book);
                  Navigator.pop(context);
                },
                child: const Text("Delete"),
              )
            ],
          ),
        );
      },
    );
  }

  void _save() {
    final cleaned = _cleanNumberString(wcC.text);
    final wc = int.tryParse(cleaned) ?? 0;

    widget.onSave(
      Book(
        id: widget.book.id,
        title: titleC.text,
        wordCount: wc,
        dateRead:
            "${selectedDate.month}-${selectedDate.day}-${selectedDate.year}",
      ),
    );
    setState(() => editing = false);
  }

  @override
  Widget build(BuildContext context) {
    if (!editing) {
      return ListTile(
        title: Text(widget.book.title),
        subtitle: Text(
            "Words: ${_formatNumberString(widget.book.wordCount.toString())} • Date: ${widget.book.dateRead}"),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.orange),
              onPressed: () => setState(() => editing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red),
              onPressed: _confirmDelete,
            ),
          ],
        ),
      );
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: titleC,
              decoration: const InputDecoration(
                labelText: "Edit Title",
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: wcC,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Edit Word Count",
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: Text(
                      "Finished: ${selectedDate.month}-${selectedDate.day}-${selectedDate.year}"),
                ),
                ElevatedButton(
                  onPressed: () =>
                      widget.onDatePick((d) => setState(() => selectedDate = d)),
                  child: const Text("Pick Date"),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _save,
                    child: const Text("Save"),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => setState(() => editing = false),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[500]),
                    child: const Text("Cancel"),
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

class Book {
  final String? id;
  final String title;
  final int wordCount;
  final String dateRead;

  Book({
    this.id,
    required this.title,
    required this.wordCount,
    required this.dateRead,
  });

  factory Book.fromJson(Map<String, dynamic> json) {
    return Book(
      id: json["_id"]?.toString(),
      title: json["title"] ?? "",
      wordCount: json["wordCount"] is int
          ? json["wordCount"]
          : int.tryParse(json["wordCount"]?.toString() ?? "0") ?? 0,
      dateRead: json["dateRead"] ?? "",
    );
  }

  Map<String, dynamic> toJson() => {
        "title": title,
        "wordCount": wordCount,
        "dateRead": dateRead,
      };

  DateTime parseDate() {
    try {
      final parts = dateRead.split("-");
      if (parts.length != 3) return DateTime.now();
      final month = int.parse(parts[0]);
      final day = int.parse(parts[1]);
      final year = int.parse(parts[2]);
      return DateTime(year, month, day);
    } catch (_) {
      return DateTime.now();
    }
  }

  int dateReadYear() => parseDate().year;
}
