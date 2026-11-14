 
import 'dart:math';

import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'book_details_page.dart';

class SurpriseMePage extends StatefulWidget {
  const SurpriseMePage({super.key});

  @override
  State<SurpriseMePage> createState() => _SurpriseMePageState();
}

class _SurpriseMePageState extends State<SurpriseMePage> {
  final DBHelper dbHelper = DBHelper();

  Map<String, dynamic>? selectedBook;

  bool isLoading = false;
  String? errorMessage;

  final Random random = Random();

  Future<void> pickRandomBook() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final allBooks = await dbHelper.getBooks();

      if (!mounted) return;

      if (allBooks.isEmpty) {
        setState(() {
          selectedBook = null;
          errorMessage = 'No books available right now.';
          isLoading = false;
        });
        return;
      }

      Map<String, dynamic> newBook;

      if (allBooks.length > 1 && selectedBook != null) {
        final previousId = selectedBook!['id'];

        final otherBooks = allBooks
            .where((book) => book['id'] != previousId)
            .toList();

        newBook = otherBooks[random.nextInt(otherBooks.length)];
      } else {
        newBook = allBooks[random.nextInt(allBooks.length)];
      }

      setState(() {
        selectedBook = newBook;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not find a book. Please try again.';
        isLoading = false;
      });

      debugPrint('SURPRISE ME ERROR: $e');
    }
  }

  void openBookDetails() {
    if (selectedBook == null) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsPage(
          book: selectedBook!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const lavender = Color(0xFF8063A8);
    const lightLavender = Color(0xFFEAE0F5);
    const cream = Color(0xFFFFF9F2);
    const darkText = Color(0xFF49385F);

    return Scaffold(
      backgroundColor: cream,
      appBar: AppBar(
        title: const Text('Surprise Me'),
        backgroundColor: cream,
        foregroundColor: darkText,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.auto_awesome,
                size: 55,
                color: lavender,
              ),

              const SizedBox(height: 16),

              const Text(
                'A Little Reading Surprise!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: darkText,
                ),
              ),

              const SizedBox(height: 10),

              const Text(
                'Not sure what to read next? '
                'Let BookNest choose a book for you!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Colors.black54,
                ),
              ),

              const SizedBox(height: 35),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: lightLavender,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: isLoading
                    ? const SizedBox(
                        height: 220,
                        child: Center(
                          child: CircularProgressIndicator(
                            color: lavender,
                          ),
                        ),
                      )
                    : errorMessage != null
                        ? SizedBox(
                            height: 220,
                            child: Center(
                              child: Text(
                                errorMessage!,
                                textAlign: TextAlign.center,
                              ),
                            ),
                          )
                        : selectedBook == null
                            ? const SizedBox(
                                height: 220,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.menu_book_rounded,
                                        size: 75,
                                        color: lavender,
                                      ),
                                      SizedBox(height: 16),
                                      Text(
                                        'Your next favourite book '
                                        'is waiting!',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: darkText,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : Column(
                                children: [
                                  const Icon(
                                    Icons.menu_book_rounded,
                                    size: 85,
                                    color: lavender,
                                  ),

                                  const SizedBox(height: 20),

                                  Text(
                                    selectedBook!['title']?.toString()
                                        ?? 'Unknown Book',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 23,
                                      fontWeight: FontWeight.bold,
                                      color: darkText,
                                    ),
                                  ),

                                  const SizedBox(height: 10),

                                  Text(
                                    'By ${selectedBook!['author'] ?? 'Unknown Author'}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Colors.black54,
                                    ),
                                  ),

                                  const SizedBox(height: 15),

                                  Chip(
                                    label: Text(
                                      selectedBook!['category']
                                              ?.toString() ??
                                          'Other',
                                    ),
                                    backgroundColor: cream,
                                    side: BorderSide.none,
                                  ),

                                  const SizedBox(height: 12),

                                  const Text(
                                    'Maybe this is your next favourite read!',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: lavender,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                ],
                              ),
              ),

              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : pickRandomBook,
                  icon: const Icon(Icons.casino_rounded),
                  label: Text(
                    selectedBook == null
                        ? 'Find My Book'
                        : 'Pick Another Book',
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: lavender,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),

              if (selectedBook != null) ...[
                const SizedBox(height: 14),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: OutlinedButton(
                    onPressed: openBookDetails,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: lavender,
                      side: const BorderSide(color: lavender),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text('View Book Details'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
