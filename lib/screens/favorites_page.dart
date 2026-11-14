
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'book_details_page.dart';

class FavoritesPage extends StatefulWidget {
  const FavoritesPage({super.key});

  @override
  State<FavoritesPage> createState() => _FavoritesPageState();
}

class _FavoritesPageState extends State<FavoritesPage> {
  final DBHelper dbHelper = DBHelper();

  List<Map<String, dynamic>> favorites = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    setState(() {
      isLoading = true;
    });

    try {
      final result = await dbHelper.getMyLibrary(
        favoritesOnly: true,
      );

      if (!mounted) return;

      setState(() {
        favorites = result;
        isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load favorites: $e')),
      );
    }
  }

  Future<void> removeFavorite(int bookId) async {
    try {
      await dbHelper.setFavorite(bookId, false);
      await loadFavorites();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Removed from Favorites.'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update favorite: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Favorites'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : favorites.isEmpty
                ? const Center(
                    child: Text(
                      'No favorite books yet.\n'
                      'Tap the heart icon on a book to add it here.',
                      textAlign: TextAlign.center,
                    ),
                  )
                : ListView.builder(
                    itemCount: favorites.length,
                    itemBuilder: (context, index) {
                      final item = favorites[index];
                      final book = item['books'];

                      if (book == null || book is! Map) {
                        return const SizedBox.shrink();
                      }

                      final int bookId = item['book_id'] as int;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: ListTile(
                          leading: const Icon(
                            Icons.menu_book_rounded,
                            color: Color(0xFF7B5EA7),
                            size: 32,
                          ),
                          title: Text(
                            book['title'] ?? 'Unknown Book',
                          ),
                          subtitle: Text(
                            '${book['author'] ?? 'Unknown Author'}'
                            ' • ${book['category'] ?? ''}',
                          ),
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () => removeFavorite(bookId),
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
                      );
                    },
                  ),
      ),
    );
  }
}
