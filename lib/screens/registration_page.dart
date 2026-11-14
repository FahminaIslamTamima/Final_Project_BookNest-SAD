
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../database/db_helper.dart';
import 'home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final DBHelper dbHelper = DBHelper();

  bool isLoading = false;

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> register() async {
    final name = nameController.text.trim();
    final email = emailController.text.trim().toLowerCase();
    final password = passwordController.text;

    // CHECK EMPTY FIELDS

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      showMessage('Please fill in all fields.');
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
      r'^(?=.*[A-Za-z])(?=.*\d).{6,}$',
    );

    if (!passwordRegex.hasMatch(password)) {
      showMessage(
        'Password must contain at least one letter, '
        'one number and at least 6 characters.',
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      await dbHelper.registerUser(name, email, password);

      if (!mounted) return;

      showMessage('Account created successfully!');

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => HomePage(userName: name),
        ),
      );
    } on AuthException catch (e) {
      if (!mounted) return;

      if (e.message.toLowerCase().contains('already registered')) {
        showMessage('This email is already registered.');
      } else {
        showMessage(e.message);
      }
    } catch (e) {
      debugPrint('REGISTRATION ERROR: $e');

      if (mounted) {
        showMessage('Something went wrong. Please try again.');
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
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Account'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: emailController,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
              ),
            ),

            const SizedBox(height: 16),

            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Password',
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoading ? null : register,
                child: Text(
                  isLoading ? 'Please wait...' : 'Create Account',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
