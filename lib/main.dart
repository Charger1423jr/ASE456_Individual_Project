import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:ui' as ui;
import 'package:google_fonts/google_fonts.dart';

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
        textTheme: GoogleFonts.nunitoTextTheme(Theme.of(context).textTheme),
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

Widget _totalsBox(String title, String value) {
  return Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      margin: const EdgeInsets.symmetric(horizontal: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Column(
        children: [
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold)),
          const SizedBox(height: 6),
          Text(value,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  );
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _wordCountController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();
  DateTime? _selectedDate;

  List<Book> _books = [];
  List<Book> _filteredBooks = [];

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

    _searchController.addListener(() {
      _filterBooks();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _wordCountController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _filterBooks() {
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredBooks = _books;
      } else {
        _filteredBooks = _books
            .where((book) => book.title
                .toLowerCase()
                .contains(_searchController.text.toLowerCase()))
            .toList();
      }
    });
  }

  Future<void> _fetchBooks() async {
    try {
      final resp = await http.get(Uri.parse(apiUrl));
      if (resp.statusCode == 200) {
        final List<dynamic> data = json.decode(resp.body);
        setState(() {
          _books = data.map((e) => Book.fromJson(e)).toList();
          _filteredBooks = _books;
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

  void _showWrapped() async {
    final currentYear = DateTime.now().year;
    
    try {
      final resp = await http.get(
        Uri.parse("http://localhost:5000/api/wrapped/$currentYear")
      );
      
      if (resp.statusCode == 200) {
        final data = json.decode(resp.body);
        if (!mounted) return;
        
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => WrappedScreen(wrappedData: data),
          ),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error loading wrapped data')),
        );
      }
    } catch (e) {
      debugPrint("Wrapped error: $e");
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Network error loading wrapped')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final int totalWords = _books.fold(0, (sum, b) => sum + b.wordCount);
    final int yearWords = _yearWordCount();
    final double points = yearWords / 10000.0;
    final int totalBooks = _books.length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.auto_awesome),
            onPressed: _showWrapped,
            tooltip: "My ${DateTime.now().year} Wrapped",
          ),
        ],
      ),
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
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _totalsBox("Word Count (All)", _formatNumberString(totalWords.toString())),
                            _totalsBox("Word Count (${DateTime.now().year})", _formatNumberString(yearWords.toString())),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _totalsBox("Books Read", totalBooks.toString()),
                            _totalsBox("Points (${DateTime.now().year})", points.toStringAsFixed(2)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  const Divider(),
                  const Text("Book Shelf",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      labelText: "Search books",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListView.builder(
                    itemCount: _filteredBooks.length,
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return EditableBookTile(
                        key: ValueKey(_filteredBooks[index].id),
                        book: _filteredBooks[index],
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

class WrappedScreen extends StatefulWidget {
  final Map<String, dynamic> wrappedData;

  const WrappedScreen({super.key, required this.wrappedData});

  @override
  State<WrappedScreen> createState() => _WrappedScreenState();
}

class _WrappedScreenState extends State<WrappedScreen> {
  final GlobalKey _wrappedKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final year = widget.wrappedData['year'];
    final totalBooks = widget.wrappedData['totalBooks'];
    final totalWords = widget.wrappedData['totalWords'];
    final points = widget.wrappedData['points'];
    final topBooks = widget.wrappedData['topBooks'] as List<dynamic>;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Text('$year Wrapped'),
        actions: [
          IconButton(
            icon: const Icon(Icons.screenshot),
            onPressed: () {
              // Note: Take a screenshot using your device's screenshot function
              // Android: Power + Volume Down
              // iOS: Side Button + Volume Up
              // Desktop: Use your OS screenshot tool
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Use your device screenshot function to save this image'),
                  duration: Duration(seconds: 3),
                ),
              );
            },
            tooltip: "Screenshot to Save",
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: RepaintBoundary(
              key: _wrappedKey,
              child: Container(
                width: 400,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF1E3A8A),
                      Color(0xFF7C3AED),
                      Color(0xFFDB2777),
                      Color(0xFFF59E0B),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome,
                        color: Colors.white, size: 50),
                    const SizedBox(height: 16),
                    Text(
                      '$year',
                      style: GoogleFonts.montserrat(
                        fontSize: 48,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'WRAPPED',
                      style: GoogleFonts.montserrat(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: Colors.white70,
                        letterSpacing: 4,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _wrappedStat('Books Read', totalBooks.toString()),
                    const SizedBox(height: 24),
                    _wrappedStat(
                        'Total Words', _formatNumberString(totalWords.toString())),
                    const SizedBox(height: 24),
                    _wrappedStat('Points Earned', points.toString()),
                    const SizedBox(height: 40),
                    if (topBooks.isNotEmpty) ...[
                      Text(
                        'TOP READS',
                        style: GoogleFonts.montserrat(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 16),
                      ...topBooks.take(3).map((book) => Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    book['title'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${_formatNumberString(book['wordCount'].toString())} words',
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 14,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )),
                    ],
                    const SizedBox(height: 40),
                    Text(
                      '📚 Bookeep',
                      style: GoogleFonts.nunito(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrappedStat(String label, String value) {
    return Column(
      children: [
        Text(
          label.toUpperCase(),
          style: GoogleFonts.montserrat(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.white70,
            letterSpacing: 2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: GoogleFonts.montserrat(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
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
          filter: ui.ImageFilter.blur(sigmaX: 6, sigmaY: 6),
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
