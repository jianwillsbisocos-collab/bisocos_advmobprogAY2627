import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import 'login_screen.dart';
import 'profile_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) => const AuthGate();
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    if (auth.isInitializing) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return auth.isAuthenticated ? const ProfileScreen() : const LoginScreen();
  }
}
