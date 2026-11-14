 
import 'package:flutter/material.dart';

import '../database/db_helper.dart';

class ReadingStatisticsPage extends StatefulWidget {
  const ReadingStatisticsPage({super.key});

  @override
  State<ReadingStatisticsPage> createState() =>
      _ReadingStatisticsPageState();
}

class _ReadingStatisticsPageState
    extends State<ReadingStatisticsPage> {
  final DBHelper dbHelper = DBHelper();

  bool isLoading = true;
  String? errorMessage;

  int totalBooks = 0;
  int completedBooks = 0;
  int currentlyReading = 0;
  int wantToRead = 0;
  int otherStatus = 0;

  @override
  void initState() {
    super.initState();
    loadStatistics();
  }

  Future<void> loadStatistics() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final library = await dbHelper.getMyLibrary();

      int completed = 0;
      int reading = 0;
      int planned = 0;
      int other = 0;

      for (final book in library) {
        final status = (book['reading_status'] ?? '')
            .toString()
            .toLowerCase()
            .replaceAll('_', ' ')
            .replaceAll('-', ' ')
            .trim();

        if (status.contains('completed') ||
            status == 'complete' ||
            status == 'finished') {
          completed++;
        } else if (status.contains('want') ||
            status.contains('to read') ||
            status == 'planned') {
          planned++;
        } else if (status.contains('reading') ||
            status == 'currently reading') {
          reading++;
        } else {
          other++;
        }
      }

      if (!mounted) return;

      setState(() {
        totalBooks = library.length;
        completedBooks = completed;
        currentlyReading = reading;
        wantToRead = planned;
        otherStatus = other;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('READING STATISTICS ERROR: $e');

      if (!mounted) return;

      setState(() {
        errorMessage = 'Could not load reading statistics.';
        isLoading = false;
      });
    }
  }

  double get completionProgress {
    if (totalBooks == 0) return 0;
    return completedBooks / totalBooks;
  }

  Widget buildStatCard({
    required String title,
    required int count,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              icon,
              color: color,
              size: 27,
            ),
          ),

          const SizedBox(width: 16),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),

                const SizedBox(height: 5),

                Text(
                  count.toString(),
                  style: TextStyle(
                    fontSize: 25,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const cream = Color(0xFFFFF9F2);
    const lavender = Color(0xFF8063A8);
    const darkText = Color(0xFF49385F);

    return Scaffold(
      backgroundColor: cream,

      appBar: AppBar(
        title: const Text('Reading Statistics'),
        backgroundColor: cream,
        foregroundColor: darkText,
        elevation: 0,
        actions: [
          IconButton(
            tooltip: 'Refresh Statistics',
            onPressed: isLoading ? null : loadStatistics,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),

      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: lavender,
              ),
            )
          : errorMessage != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(errorMessage!),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: loadStatistics,
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: loadStatistics,
                  color: lavender,
                  child: SingleChildScrollView(
                    physics:
                        const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(20),

                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Your Reading Journey',
                          style: TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 8),

                        const Text(
                          'Every book takes you somewhere new.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 15,
                          ),
                        ),

                        const SizedBox(height: 25),

                        // TOTAL BOOKS CARD

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEAE0F5),
                            borderRadius:
                                BorderRadius.circular(22),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.auto_stories_rounded,
                                size: 45,
                                color: lavender,
                              ),

                              const SizedBox(height: 12),

                              const Text(
                                'Total Books in Your Shelf',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: darkText,
                                ),
                              ),

                              const SizedBox(height: 5),

                              Text(
                                totalBooks.toString(),
                                style: const TextStyle(
                                  fontSize: 42,
                                  fontWeight: FontWeight.bold,
                                  color: lavender,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Text(
                          'Your Reading Status',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 14),

                        buildStatCard(
                          title: 'Completed',
                          count: completedBooks,
                          icon: Icons.check_circle_rounded,
                          color: const Color(0xFF659B79),
                        ),

                        const SizedBox(height: 12),

                        buildStatCard(
                          title: 'Currently Reading',
                          count: currentlyReading,
                          icon: Icons.menu_book_rounded,
                          color: lavender,
                        ),

                        const SizedBox(height: 12),

                        buildStatCard(
                          title: 'Want to Read',
                          count: wantToRead,
                          icon: Icons.bookmark_rounded,
                          color: const Color(0xFFC18B54),
                        ),

                        if (otherStatus > 0) ...[
                          const SizedBox(height: 12),

                          buildStatCard(
                            title: 'Other / Not Set',
                            count: otherStatus,
                            icon: Icons.more_horiz,
                            color: Colors.blueGrey,
                          ),
                        ],

                        const SizedBox(height: 28),

                        // READING PROGRESS

                        const Text(
                          'Completion Progress',
                          style: TextStyle(
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            color: darkText,
                          ),
                        ),

                        const SizedBox(height: 15),

                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Books Completed',
                                    style: TextStyle(
                                      color: Colors.black54,
                                    ),
                                  ),

                                  Text(
                                    '${(completionProgress * 100).round()}%',
                                    style: const TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: lavender,
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 14),

                              ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(20),
                                child: LinearProgressIndicator(
                                  value: completionProgress,
                                  minHeight: 12,
                                  backgroundColor:
                                      const Color(0xFFEAE0F5),
                                  color: lavender,
                                ),
                              ),

                              const SizedBox(height: 12),

                              Text(
                                '$completedBooks out of $totalBooks books completed.',
                                style: const TextStyle(
                                  color: Colors.black54,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 25),

                        const Center(
                          child: Text(
                            'Keep reading, one page at a time. 💜',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: lavender,
                              fontStyle: FontStyle.italic,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
