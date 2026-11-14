
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import 'welcome_page.dart';
import 'book_details_page.dart';
import 'bookshelf_page.dart';
import 'favorites_page.dart';
import 'daily_quote_card.dart';
import 'surprise_me_page.dart';
import 'reading_statistics_page.dart';

class HomePage extends StatefulWidget {
  final String userName;

  const HomePage({
    super.key,
    required this.userName,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DBHelper dbHelper = DBHelper();

  final TextEditingController searchController =
      TextEditingController();

  List<Map<String, dynamic>> books = [];
  Set<int> favoriteIds = {};

  bool isLoading = true;
  String selectedCategory = 'All';
  int selectedIndex = 0;

  final List<String> categories = [
    'All',
    'Romance',
    'Classics',
    'Adventure',
    'Mystery',
    'Fantasy',
  ];

  static const Color cream = Color(0xFFFFF9F2);
  static const Color lavender = Color(0xFF8063A8);
  static const Color lightLavender = Color(0xFFEAE0F5);
  static const Color darkLavender = Color(0xFF49385F);

  @override
  void initState() {
    super.initState();
    loadBooks();
  }

  // LOAD BOOKS FROM SUPABASE

  Future<void> loadBooks({bool showLoading = true}) async {
    if (showLoading && mounted) {
      setState(() {
        isLoading = true;
      });
    }

    try {
      final loadedBooks = await dbHelper.getBooks(
        search: searchController.text,
        category: selectedCategory,
      );

      final library = await dbHelper.getMyLibrary();

      if (!mounted) return;

      setState(() {
        books = loadedBooks;

        favoriteIds = library
            .where((item) => item['is_favorite'] == true)
            .map((item) => item['book_id'] as int)
            .toSet();

        isLoading = false;
      });
    } catch (e) {
      debugPrint('BOOK LOADING ERROR: $e');

      if (!mounted) return;

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Could not load books: $e'),
        ),
      );
    }
  }

  // ADD OR EDIT BOOK

  Future<void> showBookForm({
    Map<String, dynamic>? book,
  }) async {
    final bool isEditing = book != null;

    final titleController = TextEditingController(
      text: book?['title']?.toString() ?? '',
    );

    final authorController = TextEditingController(
      text: book?['author']?.toString() ?? '',
    );

    final categoryController = TextEditingController(
      text: book?['category']?.toString() ?? '',
    );

    final descriptionController = TextEditingController(
      text: book?['description']?.toString() ?? '',
    );

    final yearController = TextEditingController(
      text: book?['year']?.toString() ?? '',
    );

    final pagesController = TextEditingController(
      text: book?['pages']?.toString() ?? '',
    );

    final coverController = TextEditingController(
      text: book?['cover_url']?.toString() ?? '',
    );

    final formKey = GlobalKey<FormState>();

    try {
      await showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: Text(
              isEditing ? 'Edit Book' : 'Add New Book',
              style: const TextStyle(
                color: darkLavender,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(
                          labelText: 'Book Title',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter book title';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        controller: authorController,
                        decoration: const InputDecoration(
                          labelText: 'Author',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter author name';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        controller: categoryController,
                        decoration: const InputDecoration(
                          labelText: 'Category',
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'Enter category';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        controller: descriptionController,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        maxLines: 3,
                      ),

                      TextFormField(
                        controller: yearController,
                        decoration: const InputDecoration(
                          labelText: 'Publication Year',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              int.tryParse(value.trim()) == null) {
                            return 'Enter a valid year';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        controller: pagesController,
                        decoration: const InputDecoration(
                          labelText: 'Number of Pages',
                        ),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value != null &&
                              value.trim().isNotEmpty &&
                              int.tryParse(value.trim()) == null) {
                            return 'Enter a valid page number';
                          }
                          return null;
                        },
                      ),

                      TextFormField(
                        controller: coverController,
                        decoration: const InputDecoration(
                          labelText: 'Cover Image URL',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () async {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  final int? year =
                      yearController.text.trim().isEmpty
                          ? null
                          : int.tryParse(
                              yearController.text.trim(),
                            );

                  final int? pages =
                      pagesController.text.trim().isEmpty
                          ? null
                          : int.tryParse(
                              pagesController.text.trim(),
                            );

                  try {
                    if (isEditing) {
                      await dbHelper.updateBook(
                        id: book['id'] as int,
                        title: titleController.text.trim(),
                        author: authorController.text.trim(),
                        category: categoryController.text.trim(),
                        description:
                            descriptionController.text.trim(),
                        year: year,
                        pages: pages,
                        coverUrl:
                            coverController.text.trim().isEmpty
                                ? null
                                : coverController.text.trim(),
                      );
                    } else {
                      await dbHelper.addBook(
                        title: titleController.text.trim(),
                        author: authorController.text.trim(),
                        category: categoryController.text.trim(),
                        description:
                            descriptionController.text.trim(),
                        year: year,
                        pages: pages,
                        coverUrl:
                            coverController.text.trim().isEmpty
                                ? null
                                : coverController.text.trim(),
                      );
                    }

                    if (!mounted) return;

                    Navigator.pop(dialogContext);

                    await loadBooks();

                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          isEditing
                              ? 'Book updated successfully!'
                              : 'Book added successfully!',
                        ),
                      ),
                    );
                  } catch (e) {
                    if (!mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Operation failed: $e'),
                      ),
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: lavender,
                  foregroundColor: Colors.white,
                ),
                child: Text(
                  isEditing ? 'Update Book' : 'Add Book',
                ),
              ),
            ],
          );
        },
      );
    } finally {
      titleController.dispose();
      authorController.dispose();
      categoryController.dispose();
      descriptionController.dispose();
      yearController.dispose();
      pagesController.dispose();
      coverController.dispose();
    }
  }

  // DELETE BOOK

  Future<void> confirmDeleteBook(
    Map<String, dynamic> book,
  ) async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Delete Book?'),
          content: Text(
            'Are you sure you want to delete '
            '"${book['title']}"?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    try {
      await dbHelper.deleteBook(book['id'] as int);

      await loadBooks();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Book deleted successfully!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Delete failed: $e'),
        ),
      );
    }
  }

  // ADD OR REMOVE FAVORITE

  Future<void> toggleFavorite(int bookId) async {
    final wasFavorite = favoriteIds.contains(bookId);

    setState(() {
      if (wasFavorite) {
        favoriteIds.remove(bookId);
      } else {
        favoriteIds.add(bookId);
      }
    });

    try {
      await dbHelper.setFavorite(bookId, !wasFavorite);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFavorite
                ? 'Removed from Favorites'
                : 'Added to Favorites',
          ),
          duration: const Duration(seconds: 1),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        if (wasFavorite) {
          favoriteIds.add(bookId);
        } else {
          favoriteIds.remove(bookId);
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Favorite update failed: $e'),
        ),
      );
    }
  }

  // OPEN BOOK DETAILS

  void openBookDetails(Map<String, dynamic> book) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => BookDetailsPage(book: book),
      ),
    );
  }

  // OPEN SURPRISE ME

  void openSurpriseMe() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const SurpriseMePage(),
      ),
    );
  }

  // OPEN READING STATISTICS

  void openReadingStatistics() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ReadingStatisticsPage(),
      ),
    );
  }

  // LOGOUT

  Future<void> logout() async {
    try {
      await dbHelper.signOut();

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomePage(),
        ),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Logout failed. Please try again.'),
        ),
      );
    }
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // FEATURE CARD

  Widget featureCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cream,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: lightLavender),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                color: lavender,
                size: 28,
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: darkLavender,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                subtitle,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // BOOK COVER PLACEHOLDER

  Widget bookCover() {
    return Container(
      width: 52,
      height: 66,
      decoration: BoxDecoration(
        color: lightLavender,
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Icon(
        Icons.menu_book_rounded,
        color: lavender,
        size: 29,
      ),
    );
  }

  // BOOK CARD

  Widget bookCard(Map<String, dynamic> book) {
    final int bookId = book['id'] as int;
    final bool isFavorite = favoriteIds.contains(bookId);

    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      elevation: 1,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        leading: bookCover(),
        title: Text(
          book['title']?.toString() ?? 'Unknown Book',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: darkLavender,
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Text(
            '${book['author'] ?? 'Unknown Author'}'
            ' • ${book['category'] ?? ''}',
          ),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: isFavorite
                  ? 'Remove Favorite'
                  : 'Add Favorite',
              icon: Icon(
                isFavorite
                    ? Icons.favorite
                    : Icons.favorite_border,
                color: isFavorite ? Colors.red : Colors.grey,
              ),
              onPressed: () => toggleFavorite(bookId),
            ),

            PopupMenuButton<String>(
              tooltip: 'Book options',
              onSelected: (value) {
                if (value == 'edit') {
                  showBookForm(book: book);
                } else if (value == 'delete') {
                  confirmDeleteBook(book);
                }
              },
              itemBuilder: (context) => const [
                PopupMenuItem(
                  value: 'edit',
                  child: Row(
                    children: [
                      Icon(Icons.edit_outlined),
                      SizedBox(width: 10),
                      Text('Edit Book'),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                      ),
                      SizedBox(width: 10),
                      Text('Delete Book'),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        onTap: () => openBookDetails(book),
      ),
    );
  }

  // HOME PAGE

  Widget buildHomePage() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 30),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // TOP BAR

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    color: lavender,
                    size: 27,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'BookNest',
                    style: TextStyle(
                      color: darkLavender,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              IconButton(
                tooltip: 'Profile',
                onPressed: () {
                  setState(() {
                    selectedIndex = 4;
                  });
                },
                icon: const Icon(
                  Icons.account_circle_outlined,
                  color: lavender,
                  size: 29,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // WELCOME

          Text(
            'Hello, ${widget.userName}! 👋',
            style: const TextStyle(
              fontSize: 25,
              fontWeight: FontWeight.bold,
              color: darkLavender,
            ),
          ),

          const SizedBox(height: 7),

          const Text(
            'Find your next favourite book.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.black54,
            ),
          ),

          const SizedBox(height: 24),

          // DAILY QUOTE

          const DailyQuoteCard(),

          const SizedBox(height: 26),

          // FEATURE CARDS

          const Text(
            'Explore BookNest',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkLavender,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              featureCard(
                icon: Icons.auto_awesome_rounded,
                title: 'Surprise Me',
                subtitle: 'Discover a random book',
                onTap: openSurpriseMe,
              ),

              const SizedBox(width: 12),

              featureCard(
                icon: Icons.auto_graph_rounded,
                title: 'Reading Stats',
                subtitle: 'Track your reading',
                onTap: openReadingStatistics,
              ),
            ],
          ),

          const SizedBox(height: 25),

          // BROWSE BOOKS

          InkWell(
            onTap: () {
              setState(() {
                selectedIndex = 1;
              });
            },
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: lightLavender,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: darkLavender,
                    size: 30,
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Browse Books',
                          style: TextStyle(
                            color: darkLavender,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Explore books and discover new stories.',
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    color: lavender,
                    size: 18,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // SHORTCUTS

          const Text(
            'Your Reading Space',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: darkLavender,
            ),
          ),

          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 2;
                    });
                  },
                  icon: const Icon(Icons.favorite_border),
                  label: const Text('Favorites'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: lavender,
                    side: const BorderSide(color: lavender),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    setState(() {
                      selectedIndex = 3;
                    });
                  },
                  icon: const Icon(Icons.bookmark_border),
                  label: const Text('Bookshelf'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: lavender,
                    side: const BorderSide(color: lavender),
                    padding: const EdgeInsets.symmetric(
                      vertical: 13,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // SEARCH PAGE

  Widget buildSearchPage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // SEARCH HEADING AND ADD BUTTON

        Padding(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Discover Books',
                style: TextStyle(
                  fontSize: 23,
                  fontWeight: FontWeight.bold,
                  color: darkLavender,
                ),
              ),

              ElevatedButton.icon(
                onPressed: () => showBookForm(),
                icon: const Icon(
                  Icons.add,
                  size: 18,
                ),
                label: const Text('Add Book'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: lavender,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),

        // SEARCH FIELD

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18),
          child: TextField(
            controller: searchController,
            onChanged: (_) {
              loadBooks(showLoading: false);
            },
            decoration: InputDecoration(
              hintText: 'Search books or authors...',
              prefixIcon: const Icon(
                Icons.search,
                color: lavender,
              ),
              suffixIcon: IconButton(
                tooltip: 'Clear search',
                icon: const Icon(Icons.close),
                onPressed: () {
                  searchController.clear();
                  loadBooks();
                },
              ),
              filled: true,
              fillColor: cream,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // CATEGORY FILTERS

        SizedBox(
          height: 43,
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            scrollDirection: Axis.horizontal,
            children: categories.map((category) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(category),
                  selected: selectedCategory == category,
                  selectedColor: lightLavender,
                  backgroundColor: cream,
                  labelStyle: TextStyle(
                    color: selectedCategory == category
                        ? darkLavender
                        : Colors.black54,
                    fontWeight: selectedCategory == category
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                  onSelected: (_) {
                    setState(() {
                      selectedCategory = category;
                    });
                    loadBooks();
                  },
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Text(
            '${books.length} books found',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
        ),

        const SizedBox(height: 8),

        // BOOK LIST

        Expanded(
          child: isLoading
              ? const Center(
                  child: CircularProgressIndicator(
                    color: lavender,
                  ),
                )
              : books.isEmpty
                  ? const Center(
                      child: Text('No books found.'),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(
                        18,
                        4,
                        18,
                        20,
                      ),
                      itemCount: books.length,
                      itemBuilder: (context, index) {
                        return bookCard(books[index]);
                      },
                    ),
        ),
      ],
    );
  }

  // PROFILE PAGE

  Widget buildProfilePage() {
    final email =
        dbHelper.supabase.auth.currentUser?.email ??
            'Not available';

    return SingleChildScrollView(
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const SizedBox(height: 35),

          CircleAvatar(
            radius: 48,
            backgroundColor: lightLavender,
            child: const Icon(
              Icons.person_rounded,
              size: 55,
              color: lavender,
            ),
          ),

          const SizedBox(height: 16),

          Text(
            widget.userName,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
              color: darkLavender,
            ),
          ),

          const SizedBox(height: 6),

          Text(
            email,
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 35),

          Card(
            color: cream,
            child: ListTile(
              leading: const Icon(
                Icons.favorite_border,
                color: lavender,
              ),
              title: const Text('My Favorites'),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                setState(() {
                  selectedIndex = 2;
                });
              },
            ),
          ),

          Card(
            color: cream,
            child: ListTile(
              leading: const Icon(
                Icons.bookmark_border,
                color: lavender,
              ),
              title: const Text('My Bookshelf'),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                setState(() {
                  selectedIndex = 3;
                });
              },
            ),
          ),

          Card(
            color: cream,
            child: ListTile(
              leading: const Icon(
                Icons.auto_graph_rounded,
                color: lavender,
              ),
              title: const Text('Reading Statistics'),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: openReadingStatistics,
            ),
          ),

          const SizedBox(height: 25),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: logout,
              icon: const Icon(Icons.logout),
              label: const Text('Logout'),
              style: ElevatedButton.styleFrom(
                backgroundColor: lavender,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  vertical: 14,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // MAIN BUILD

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      buildHomePage(),
      buildSearchPage(),
      const FavoritesPage(),
      const BookshelfPage(),
      buildProfilePage(),
    ];

    return Scaffold(
      backgroundColor: cream,

      body: SafeArea(
        child: IndexedStack(
          index: selectedIndex,
          children: pages,
        ),
      ),

      // BOTTOM NAVIGATION

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });

          if (index == 1) {
            loadBooks();
          }
        },
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: lavender,
        unselectedItemColor: Colors.grey,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home_rounded),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_rounded),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite_border),
            activeIcon: Icon(Icons.favorite),
            label: 'Favorites',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            activeIcon: Icon(Icons.bookmark),
            label: 'Bookshelf',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}
