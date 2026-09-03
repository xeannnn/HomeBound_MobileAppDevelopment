import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'screens/dashboard_shell.dart';
import 'screens/login_screen.dart';
import 'shared/theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

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
      home: const AuthGate(),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasData) {
          return const DashboardShell();
        }

        return const LoginScreen();
      },
    );
  }
}