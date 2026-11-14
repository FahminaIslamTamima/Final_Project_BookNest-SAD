
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/db_helper.dart';
import 'home_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final DBHelper dbHelper = DBHelper();

  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> login() async {
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    // CHECK EMPTY FIELDS
    if (email.isEmpty || password.isEmpty) {
      showMessage('Please enter your email and password.');
      return;
    }

    // EMAIL REGEX VALIDATION
    final emailRegex = RegExp(
      r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
    );

    if (!emailRegex.hasMatch(email)) {
      showMessage('Please enter a valid email.');
      return;
    }

    // PASSWORD REGEX VALIDATION
    final passwordRegex = RegExp(
      r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[!@#$%^&*(),.?":{}|<>_\-+=/\\]).{6,}$',
    );

    if (!passwordRegex.hasMatch(password)) {
      showMessage(
        'Password must contain at least one letter, '
        'one number, one special character and at least 6 characters.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final user = await dbHelper.loginUser(email, password);

      if (!mounted) return;

      if (user != null) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => HomePage(
              userName: user['name'],
            ),
          ),
        );
      } else {
        showMessage('Incorrect email or password.');
      }
    } on AuthException catch (e) {
      if (mounted) {
        showMessage(e.message);
      }
    } catch (e) {
      debugPrint('LOGIN ERROR: $e');

      if (mounted) {
        showMessage('Login failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),

              // BOOKNEST IMAGE
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.asset(
                  'assets/images/BookNest_ Lavender Reading Haven.png',
                  width: double.infinity,
                  height: 260,
                  fit: BoxFit.contain,
                ),
              ),

              const SizedBox(height: 28),

              // EMAIL FIELD
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email',
                ),
              ),

              const SizedBox(height: 16),

              // PASSWORD FIELD
              TextField(
                controller: passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                ),
              ),

              const SizedBox(height: 24),

              // LOGIN BUTTON
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isLoading ? null : login,
                  child: Text(
                    isLoading ? 'Please wait...' : 'Login',
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
