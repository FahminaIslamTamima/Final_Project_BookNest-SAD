
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'book_details_page.dart';

class BookshelfPage extends StatefulWidget {
  const BookshelfPage({super.key});

  @override
  State<BookshelfPage> createState() => _BookshelfPageState();
}

class _BookshelfPageState extends State<BookshelfPage> {
  final DBHelper dbHelper = DBHelper();

  List<Map<String, dynamic>> library = [];
  bool isLoading = true;

  final List<String> readingStatuses = [
    'Want to Read',
    'Currently Reading',
    'Completed',
  ];

  @override
  void initState() {
    super.initState();
    loadLibrary();
  }

  Future<void> loadLibrary() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await dbHelper.getMyLibrary();

      if (!mounted) return;

      setState(() {
        library = result;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('BOOKSHELF ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load bookshelf: $e')),
      );
    }
  }

  Future<void> updateStatus(int bookId, String status) async {
    try {
      await dbHelper.updateReadingStatus(bookId, status);

      if (!mounted) return;

      setState(() {
        final index = library.indexWhere(
          (item) => item['book_id'] == bookId,
        );

        if (index != -1) {
          library[index]['reading_status'] = status;
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Reading status updated: $status'),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Status update failed: $e')),
      );
    }
  }

  Future<void> removeBook(int bookId) async {
    try {
      await dbHelper.removeFromBookshelf(bookId);
      await loadLibrary();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book removed from your bookshelf.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not remove book: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookshelf'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : library.isEmpty
                ? const Center(
                    child: Text(
                      'Your bookshelf is empty.\n'
                      'Add books from the Home page.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: library.length,
                    itemBuilder: (context, index) {
                      final item = library[index];
                      final book = item['books'];

                      if (book == null || book is! Map) {
                        return const SizedBox.shrink();
                      }

                      final int bookId = item['book_id'] as int;

                      final String currentStatus =
                          readingStatuses.contains(item['reading_status'])
                              ? item['reading_status']
                              : 'Want to Read';

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ListTile(
                                contentPadding: EdgeInsets.zero,
                                leading: const Icon(
                                  Icons.menu_book_rounded,
                                  color: Color(0xFF7B5EA7),
                                  size: 30,
                                ),
                                title: Text(
                                  book['title'] ?? 'Unknown Book',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                subtitle: Text(
                                  book['author'] ?? 'Unknown Author',
                                ),
                                trailing: IconButton(
                                  tooltip: 'Remove from Bookshelf',
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => removeBook(bookId),
                                ),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => BookDetailsPage(
                                        book: Map<String, dynamic>.from(book),
                                      ),
                                    ),
                                  );
                                },
                              ),
                              const Divider(),
                              const Text(
                                'Reading Status',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 6),
                              DropdownButtonFormField<String>(
                                initialValue: currentStatus,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  prefixIcon: Icon(Icons.auto_stories),
                                  border: OutlineInputBorder(),
                                  contentPadding: EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                ),
                                items: readingStatuses.map((status) {
                                  return DropdownMenuItem<String>(
                                    value: status,
                                    child: Text(status),
                                  );
                                }).toList(),
                                onChanged: (newStatus) {
                                  if (newStatus != null) {
                                    updateStatus(bookId, newStatus);
                                  }
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}
