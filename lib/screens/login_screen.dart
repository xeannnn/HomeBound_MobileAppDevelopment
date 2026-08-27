import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../shared/theme/app_theme.dart';
import 'dashboard_shell.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  final AuthService _authService = AuthService();

  bool _obscurePassword = true;
  bool _loading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _goToDashboard() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => const DashboardShell(),
      ),
    );
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      _showMessage(
        'Please enter your email and password.',
      );
      return;
    }

    try {
      setState(() {
        _loading = true;
      });

      await _authService.login(
        email: email,
        password: password,
      );

      if (!mounted) return;

      _goToDashboard();
    } on FirebaseAuthException catch (e) {
      String message = 'Unable to log in.';

      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'user-disabled') {
        message = 'This account has been disabled.';
      } else if (e.code == 'user-not-found' ||
          e.code == 'wrong-password' ||
          e.code == 'invalid-credential') {
        message = 'Incorrect email or password.';
      } else if (e.code == 'too-many-requests') {
        message =
        'Too many login attempts. Please try again later.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage(
        'Something went wrong. Please try again.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _googleLogin() async {
    try {
      setState(() {
        _loading = true;
      });

      final user = await _authService.signInWithGoogle();

      if (!mounted) return;

      if (user != null) {
        _goToDashboard();
      }
    } on FirebaseAuthException catch (e) {
      _showMessage(
        e.message ?? 'Google Sign-In failed.',
      );
    } catch (e) {
      _showMessage(
        'Google Sign-In was cancelled or failed.',
      );
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      _showMessage(
        'Enter your email address first.',
      );
      return;
    }

    try {
      await _authService.resetPassword(email);

      _showMessage(
        'Password reset email sent. Check your inbox.',
      );
    } on FirebaseAuthException catch (e) {
      String message =
          'Unable to send password reset email.';

      if (e.code == 'invalid-email') {
        message = 'Please enter a valid email address.';
      } else if (e.code == 'user-not-found') {
        message =
        'No account found with this email address.';
      }

      _showMessage(message);
    } catch (e) {
      _showMessage(
        'Something went wrong. Please try again.',
      );
    }
  }

  void _openRegister() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => const RegisterScreen(),
      ),
    );
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
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 24),

                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                        BorderRadius.circular(16),
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
                    'Homebound',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),

                  const SizedBox(height: 6),

                  const Text(
                    'Never miss your last ride home',
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
                    keyboardType:
                    TextInputType.emailAddress,
                    decoration:
                    const InputDecoration(
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
                        icon: Icon(
                          _obscurePassword
                              ? Icons
                              .visibility_off_rounded
                              : Icons
                              .visibility_rounded,
                          color:
                          AppColors.textSecondary,
                          size: 20,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscurePassword =
                            !_obscurePassword;
                          });
                        },
                      ),
                    ),
                  ),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: _forgotPassword,
                      child: const Text(
                        'Forgot password?',
                        style: TextStyle(
                          color:
                          AppColors.textSecondary,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed:
                    _loading ? null : _login,
                    child: _loading
                        ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                      CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                        : const Text('Log In'),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton.icon(
                    onPressed:
                    _loading ? null : _googleLogin,
                    icon: const Icon(
                      Icons.g_mobiledata_rounded,
                      size: 30,
                    ),
                    label: const Text(
                      'Sign in with Google',
                    ),
                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(
                    onPressed: _loading
                        ? null
                        : _goToDashboard,
                    child: const Text(
                      'Continue as Guest',
                    ),
                  ),

                  const SizedBox(height: 24),

                  Row(
                    mainAxisAlignment:
                    MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Don't have an account?",
                        style: TextStyle(
                          color:
                          AppColors.textSecondary,
                        ),
                      ),
                      TextButton(
                        onPressed: _openRegister,
                        child: const Text(
                          'Register',
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