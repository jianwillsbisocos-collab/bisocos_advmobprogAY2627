import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../widgets/auth_form_field.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;
    final success = await context.read<AuthProvider>().signIn(
      _emailController.text,
      _passwordController.text,
    );
    if (mounted && !success) _showError();
  }

  Future<void> _forgotPassword() async {
    if (!_formKey.currentState!.validate()) {
      if (_emailController.text.trim().isEmpty ||
          !_emailController.text.contains('@')) {
        return;
      }
    }
    final success = await context.read<AuthProvider>().resetPassword(
      _emailController.text,
    );
    if (!mounted) return;
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password reset email sent.')),
      );
    } else {
      _showError();
    }
  }

  void _showError() {
    final message = context.read<AuthProvider>().errorMessage;
    if (message != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(
                      Icons.lock_person_outlined,
                      size: 56,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Welcome back',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Sign in to your account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    AuthFormField(
                      controller: _emailController,
                      label: 'Email address',
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        if (email.isEmpty) return 'Email is required.';
                        if (!RegExp(
                          r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                        ).hasMatch(email)) {
                          return 'Enter a valid email.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    AuthFormField(
                      controller: _passwordController,
                      label: 'Password',
                      icon: Icons.password_outlined,
                      textInputAction: TextInputAction.done,
                      obscureText: _obscurePassword,
                      suffixIcon: IconButton(
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () => setState(
                          () => _obscurePassword = !_obscurePassword,
                        ),
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                      validator: (value) => value == null || value.isEmpty
                          ? 'Password is required.'
                          : value.length < 8
                          ? 'Use at least 8 characters.'
                          : null,
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: isLoading ? null : _forgotPassword,
                        child: const Text('Forgot password?'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    FilledButton(
                      onPressed: isLoading ? null : _login,
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Log in'),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton(
                      onPressed: isLoading
                          ? null
                          : () => Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) => const SignupScreen(),
                              ),
                            ),
                      child: const Text('Create account'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
