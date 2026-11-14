 
import 'package:supabase_flutter/supabase_flutter.dart';

class DBHelper {
  final SupabaseClient supabase = Supabase.instance.client;

  String get userId {
    final user = supabase.auth.currentUser;
    if (user == null) {
      throw Exception('Please login first.');
    }
    return user.id;
  }

  // REGISTER USER

  Future<void> registerUser(
    String name,
    String email,
    String password,
  ) async {
    await supabase.auth.signUp(
      email: email.trim().toLowerCase(),
      password: password,
      data: {
        'name': name.trim(),
      },
    );
  }

  // LOGIN USER

  Future<Map<String, dynamic>?> loginUser(
    String email,
    String password,
  ) async {
    final response = await supabase.auth.signInWithPassword(
      email: email.trim().toLowerCase(),
      password: password,
    );

    final user = response.user;

    if (user == null) {
      return null;
    }

    return {
      'id': user.id,
      'name': user.userMetadata?['name'] ??
          user.email?.split('@').first ??
          'Reader',
      'email': user.email,
    };
  }

  // LOGOUT USER

  Future<void> signOut() async {
    await supabase.auth.signOut();
  }

  // GET BOOKS (READ)

  Future<List<Map<String, dynamic>>> getBooks({
    String search = '',
    String category = 'All',
  }) async {
    var query = supabase.from('books').select();

    if (category != 'All') {
      query = query.eq('category', category);
    }

    if (search.trim().isNotEmpty) {
      final term = search.trim();

      query = query.or(
        'title.ilike.%$term%,author.ilike.%$term%',
      );
    }

    final result = await query.order('title');

    return List<Map<String, dynamic>>.from(result);
  }

  // GET BOOK BY ID

  Future<Map<String, dynamic>?> getBookById(int id) async {
    final result = await supabase
        .from('books')
        .select()
        .eq('id', id)
        .maybeSingle();

    return result;
  }

  // CREATE: ADD NEW BOOK

  Future<void> addBook({
    required String title,
    required String author,
    required String category,
    String description = '',
    int? year,
    int? pages,
    String? coverUrl,
  }) async {
    await supabase.from('books').insert({
      'title': title,
      'author': author,
      'category': category,
      'description': description,
      'year': year,
      'pages': pages,
      'cover_url': coverUrl,
    });
  }

  // UPDATE: EDIT BOOK

  Future<void> updateBook({
    required int id,
    required String title,
    required String author,
    required String category,
    String description = '',
    int? year,
    int? pages,
    String? coverUrl,
  }) async {
    await supabase.from('books').update({
      'title': title,
      'author': author,
      'category': category,
      'description': description,
      'year': year,
      'pages': pages,
      'cover_url': coverUrl,
    }).eq('id', id);
  }

  // DELETE: DELETE BOOK

  Future<void> deleteBook(int id) async {
    await supabase.from('books').delete().eq('id', id);
  }

  // ADD BOOK TO BOOKSHELF

  Future<void> addToBookshelf(int bookId) async {
    await supabase.from('user_library').upsert(
      {
        'user_id': userId,
        'book_id': bookId,
      },
      onConflict: 'user_id,book_id',
    );
  }

  // GET MY BOOKSHELF

  Future<List<Map<String, dynamic>>> getMyLibrary({
    bool favoritesOnly = false,
  }) async {
    var query = supabase
        .from('user_library')
        .select('id, book_id, is_favorite, reading_status, books(*)')
        .eq('user_id', userId);

    if (favoritesOnly) {
      query = query.eq('is_favorite', true);
    }

    final result = await query.order(
      'created_at',
      ascending: false,
    );

    return List<Map<String, dynamic>>.from(result);
  }

  // ADD OR REMOVE FAVORITE

  Future<void> setFavorite(int bookId, bool isFavorite) async {
    if (isFavorite) {
      await supabase.from('user_library').upsert(
        {
          'user_id': userId,
          'book_id': bookId,
          'is_favorite': true,
        },
        onConflict: 'user_id,book_id',
      );
    } else {
      await supabase
          .from('user_library')
          .update({'is_favorite': false})
          .eq('user_id', userId)
          .eq('book_id', bookId);
    }
  }

  // UPDATE READING STATUS

  Future<void> updateReadingStatus(
    int bookId,
    String status,
  ) async {
    await supabase.from('user_library').upsert(
      {
        'user_id': userId,
        'book_id': bookId,
        'reading_status': status,
      },
      onConflict: 'user_id,book_id',
    );
  }

  // REMOVE BOOK FROM BOOKSHELF

  Future<void> removeFromBookshelf(int bookId) async {
    await supabase
        .from('user_library')
        .delete()
        .eq('user_id', userId)
        .eq('book_id', bookId);
  }
}
