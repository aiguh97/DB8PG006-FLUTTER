import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:pandai/auth/signin_screen.dart';
import 'package:pandai/constant/theme.dart';
import 'package:pandai/screens/level_screen.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  String _errorMessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
          );

      final uid = credential.user!.uid;

      // Simpan data awal user
      await FirebaseFirestore.instance.collection("users").doc(uid).set({
        'email': _emailController.text.trim(),
        'xp': 0,
        'streak': 0,
        'language': 'German',
        'lastActive': FieldValue.serverTimestamp(),
      });

      // Clone levels untuk user baru
      final levelsSnapshot = await FirebaseFirestore.instance
          .collection('levels')
          .get();

      for (final doc in levelsSnapshot.docs) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(uid)
            .collection('levels')
            .doc(doc.id)
            .set({
              'isUnlocked': doc['levelNumber'] == 1,
              'levelNumber': doc['levelNumber'],
              'title': doc['title'],
            });
      }

      // Navigasi setelah semua selesai
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const LevelScreen()),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _errorMessage = e.message ?? 'An error occurred';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppColors.backgroundGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 40),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "Create Account",
                        style: TextStyle(
                          color: AppColors.greenPrimary,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email
                      TextFormField(
                        controller: _emailController,
                        cursorColor: Colors.grey,
                        style: const TextStyle(color: Colors.black),
                        decoration: const InputDecoration(
                          labelText: 'Email',
                          border: AppColors.greyBorder,
                          enabledBorder: AppColors.greyBorder,
                          focusedBorder: AppColors.greyBorder,
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (v) => v == null || !v.contains('@')
                            ? 'Enter a valid email'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Password
                      TextFormField(
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
                        validator: (v) => v == null || v.length < 6
                            ? 'Min 6 characters'
                            : null,
                      ),
                      const SizedBox(height: 20),

                      // Error Message
                      if (_errorMessage.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text(
                            _errorMessage,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),

                      // Sign Up Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _signUp,
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
                                  'Sign Up',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sign In Button
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => SigninScreen()),
                          );
                        },
                        child: const Text(
                          "Already have an account? Please signin",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
