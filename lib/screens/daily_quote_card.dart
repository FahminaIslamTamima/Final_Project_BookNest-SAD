 
import 'package:flutter/material.dart';

class DailyQuoteCard extends StatelessWidget {
  const DailyQuoteCard({super.key});

  static const List<Map<String, String>> quotes = [
    {
      'quote': 'A reader lives a thousand lives before he dies.',
      'author': 'George R. R. Martin',
    },
    {
      'quote': 'Books are a uniquely portable magic.',
      'author': 'Stephen King',
    },
    {
      'quote': 'So many books, so little time.',
      'author': 'Frank Zappa',
    },
    {
      'quote': 'There is no friend as loyal as a book.',
      'author': 'Ernest Hemingway',
    },
    {
      'quote': 'Reading gives us someplace to go when we have to stay where we are.',
      'author': 'Mason Cooley',
    },
    {
      'quote': 'A book is a dream that you hold in your hands.',
      'author': 'Neil Gaiman',
    },
    {
      'quote': 'Today a reader, tomorrow a leader.',
      'author': 'Margaret Fuller',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final dayNumber = today.difference(DateTime(today.year, 1, 1)).inDays;
    final dailyQuote = quotes[dayNumber % quotes.length];

    return Card(
      color: const Color(0xFFF0EAF7),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(
                  Icons.auto_awesome,
                  color: Color(0xFF7B5EA7),
                ),
                SizedBox(width: 8),
                Text(
                  'DAILY READING QUOTE',
                  style: TextStyle(
                    color: Color(0xFF7B5EA7),
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                    letterSpacing: 1,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              '"${dailyQuote['quote']}"',
              style: const TextStyle(
                fontSize: 16,
                fontStyle: FontStyle.italic,
                fontWeight: FontWeight.w500,
                color: Color(0xFF443653),
              ),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '— ${dailyQuote['author']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: Color(0xFF7B5EA7),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
