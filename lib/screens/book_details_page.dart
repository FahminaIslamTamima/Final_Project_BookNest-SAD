
import 'package:flutter/material.dart';

import 'pdf_reader_page.dart';

class BookDetailsPage extends StatelessWidget {
  final Map<String, dynamic> book;

  const BookDetailsPage({
    super.key,
    required this.book,
  });

  @override
  Widget build(BuildContext context) {
    final String title =
        book['title']?.toString() ?? 'Unknown Book';

    // PDF reading is available only for Wuthering Heights.
    final bool hasPdf =
        title.trim().toLowerCase() == 'wuthering heights';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Details'),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Icon(
                Icons.menu_book_rounded,
                size: 100,
                color: Color(0xFF7B5EA7),
              ),
            ),

            const SizedBox(height: 25),

            Text(
              title,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            Text(
              'By ${book['author'] ?? 'Unknown Author'}',
            ),

            const SizedBox(height: 16),

            Text(
              'Category: ${book['category'] ?? 'N/A'}',
            ),

            Text(
              'Year: ${book['year'] ?? 'N/A'}',
            ),

            Text(
              'Pages: ${book['pages'] ?? 'N/A'}',
            ),

            const SizedBox(height: 20),

            const Text(
              'About this book',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              book['description'] ??
                  'No description available.',
            ),

            // READ BOOK BUTTON
            if (hasPdf) ...[
              const SizedBox(height: 28),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            const PdfReaderPage(),
                      ),
                    );
                  },

                  icon: const Icon(
                    Icons.menu_book_rounded,
                  ),

                  label: const Text('Read Book'),

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF7B5EA7),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      vertical: 15,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
