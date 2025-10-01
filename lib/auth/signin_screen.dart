import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandai/auth/signup_screen.dart';
import 'package:pandai/constant/theme.dart';
import 'package:pandai/screens/level_screen.dart';
// import 'package:pandai/screens/signup_screen.dart'; // nanti buat screen ini

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LevelScreen()),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'Sign in failed';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Logo / Header
                  const Icon(
                    Icons.lock_outline,
                    size: 80,
                    color: AppColors.greenPrimary,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      color: AppColors.greenPrimary,
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Email Input
                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: AppColors.greyBorder,
                      enabledBorder: AppColors.greyBorder,
                      focusedBorder: AppColors.greyBorder,
                      prefixIcon: Icon(Icons.email),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Password Input
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.black),
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: AppColors.greyBorder,
                      enabledBorder: AppColors.greyBorder,
                      focusedBorder: AppColors.greyBorder,
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Error Message
                  if (_errorMessage.isNotEmpty)
                    Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),

                  const SizedBox(height: 20),

                  // Sign In Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.greenPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: _isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Sign In',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Sign Up Button
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => SignupScreen()),
                      );
                    },
                    child: const Text(
                      "Don't have an account? Sign Up",
                      style: TextStyle(color: Colors.black54),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
