
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'theme/app_theme.dart';
import 'screens/welcome_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://kojbsyvmjurjuenxqgor.supabase.co',
    publishableKey: 'sb_publishable_HboypZA1eBc6q1o8ERzjTQ_rKU_w9fM',
  );

  runApp(const BookNestApp());
}

class BookNestApp extends StatelessWidget {
  const BookNestApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BookNest',
      theme: AppTheme.light,
      home: const WelcomePage(),
    );
  }
}
