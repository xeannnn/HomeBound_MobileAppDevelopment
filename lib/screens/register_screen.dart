import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../shared/theme/app_theme.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _loading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      _showMessage('Please fill in all fields.');
      return;
    }

    if (!email.contains('@')) {
      _showMessage('Please enter a valid email address.');
      return;
    }

    if (password.length < 6) {
      _showMessage('Password must be at least 6 characters.');
      return;
    }

    if (password != confirmPassword) {
      _showMessage('Passwords do not match.');
      return;
    }

    try {
      setState(() {
        _loading = true;
      });

      await _authService.register(
        email: email,
        password: password,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Account created successfully. Please log in.'),
        ),
      );

      Navigator.pop(context);
    } on FirebaseAuthException catch (e) {
      String message = 'Registration failed.';

      if (e.code == 'email-already-in-use') {
        message = 'This email is already registered.';
      } else if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'weak-password') {
        message = 'The password is too weak.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 28,
              vertical: 24,
            ),
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 420,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(
                        Icons.home_rounded,
                        color: AppColors.gold,
                        size: 32,
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Create Account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Create your Homebound account',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 36),

                  const Text(
                    'Email Address',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'you@example.com',
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscurePassword = !_obscurePassword;
                          });
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  const Text(
                    'Confirm Password',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),

                  const SizedBox(height: 6),

                  TextField(
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    decoration: InputDecoration(
                      hintText: '••••••••',
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            _obscureConfirmPassword =
                            !_obscureConfirmPassword;
                          });
                        },
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_off_rounded
                              : Icons.visibility_rounded,
                          color: AppColors.textSecondary,
                          size: 20,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 28),

                  ElevatedButton(
                    onPressed: _loading ? null : _register,
                    child: _loading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Register'),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Already have an account?',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        child: const Text(
                          'Log In',
                          style: TextStyle(
                            color: AppColors.gold,
                          ),
                        ),
                      ),
                    ],
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