import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'shared/theme/app_theme.dart';

void main() {
  runApp(const HomeboundApp());
}

class HomeboundApp extends StatelessWidget {
  const HomeboundApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Homebound',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const LoginScreen(),
    );
  }
}